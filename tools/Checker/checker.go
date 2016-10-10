package main

import (
	"bytes"
	"crypto/md5"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/headzoo/surf/agent"

	_ "github.com/lib/pq"
	"github.com/uber-go/zap"
)

type Nishi struct {
	db        *sql.DB
	useragent string
	referer   string
	cpu       int
	logger    zap.Logger
	URLs      []string
}

type Response struct {
	Status string
	Reason string
}

func main() {
	Service, err := Setup(os.Stdout)
	if err != nil {
		Service.logger.Fatal(err.Error())
		os.Exit(1) // Failed to connect Database
	}
	defer Service.Close()

	if err := Service.Run(); err != nil {
		Service.logger.Fatal(err.Error())
		os.Exit(1) // Failed to fetch row
	}

	if len(Service.URLs) > 0 {
		response := new(Response)
		if err := Service.Notification(response); err != nil {
			Service.logger.Fatal(err.Error())
			os.Exit(1)
		}

		if response.Status != "OK" {
			Service.logger.Fatal("Notification failed: " + response.Reason)
			os.Exit(1)
		}
	}
}

func (Service *Nishi) Notification(target interface{}) error {
	b, err := Service.CreateJSON()
	if err != nil {
		return err
	}
	req, err := Service.BuildRequest("POST", "http://localhost:5001/notification", bytes.NewBuffer(b))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	return json.NewDecoder(res.Body).Decode(target)
}

func (Service *Nishi) CreateJSON() ([]byte, error) {
	byteJSON, err := json.Marshal(Service)
	if err != nil {
		return nil, err
	}

	return byteJSON, nil
}

func (Service *Nishi) Close() {
	Service.db.Close()
}

func Setup(Out zap.WriteSyncer) (*Nishi, error) {
	db, err := sql.Open("postgres", "dbname=nishi_service host=localhost sslmode=disable")
	if err != nil {
		return &Nishi{}, err
	}

	return &Nishi{
		db:        db,
		useragent: agent.Chrome(),
		referer:   "https://google.com/",
		cpu:       runtime.NumCPU(),
		logger: zap.New(
			zap.NewTextEncoder(zap.TextTimeFormat(time.ANSIC)),
			zap.AddCaller(), // Add line number option
			zap.Output(Out),
		),
	}, nil
}

// lock
func p(semaphore chan bool) {
	semaphore <- true
}

// unlock
func v(semaphore chan bool) {
	<-semaphore
}

func (Service *Nishi) Run() error {
	rows, err := Service.db.Query("select url, html_hash from website")
	if err != nil {
		return err
	}

	var wg sync.WaitGroup
	semaphore := make(chan bool, Service.cpu)

	for rows.Next() {
		var url []byte
		var htmlhash []byte
		if err := rows.Scan(&url, &htmlhash); err != nil {
			return err
		}

		wg.Add(1)
		go func(urlString string, hashdata []byte) {
			defer wg.Done()
			p(semaphore)
			boolean, err := validationCheck(urlString)
			if err != nil {
				Service.logger.Error(err.Error())
			}

			if boolean {
				if err := Service.Request(urlString, hashdata); err != nil {
					Service.logger.Error(err.Error())
				}
			}
			v(semaphore)
		}(string(url), htmlhash)
	}
	wg.Wait()

	close(semaphore)

	return nil
}

func (Service *Nishi) BuildRequest(method, url string, body io.Reader) (*http.Request, error) {
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", Service.useragent)
	req.Header.Set("Referer", Service.referer)

	return req, nil
}

func (Service *Nishi) Request(url string, htmlhash []byte) error {

	req, err := Service.BuildRequest("Get", url, nil)
	if err != nil {
		return err
	}

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	Bodyhash := getMD5Hash(res.Body)

	if len(htmlhash) == 0 {
		return Service.Insert(url, Bodyhash)
	}

	if Bodyhash != string(htmlhash) {
		return Service.Insert(url, Bodyhash)
	}

	return nil
}

func (Service *Nishi) Insert(url, hash string) error {
	Service.URLs = append(Service.URLs, url)
	stmt := fmt.Sprintf("update website SET (html_hash, updated_at) = ('%s', now()) where url = '%s'", hash, url)
	_, err := Service.db.Exec(stmt)

	return err
}

func validationCheck(url string) (bool, error) {
	res, err := http.Head(url)
	if err != nil {
		return false, err
	}

	return isValid(res), nil
}

func getMD5Hash(body io.ReadCloser) string {
	buf := new(bytes.Buffer)
	buf.ReadFrom(body)
	return fmt.Sprintf("%x", md5.Sum(buf.Bytes()))
}

func isValid(res *http.Response) bool {
	ctype := res.Header.Get("Content-Type")
	return res.StatusCode == 200 &&
		(strings.Contains(ctype, "text/html") || strings.Contains(ctype, "application/xml"))
}
