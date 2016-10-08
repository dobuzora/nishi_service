package main

import (
	"bytes"
	"crypto/md5"
	"database/sql"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/headzoo/surf/agent"

	_ "github.com/lib/pq"
	"github.com/uber-go/zap"
)

type Nishi struct {
	db        *sql.DB
	useragent string
	referer   string
	logger    zap.Logger
	urls      []string
}

func main() {
	Service, err := Setup(os.Stdout)
	if err != nil {
		panic(err) // Failed to connect Database
	}
	defer Service.Close()

	if err := Service.Run(); err != nil {
		panic(err) // Failed to fetch row
	}
}

func (Service *Nishi) Run() error {
	rows, err := Service.db.Query("select url, html_hash from website")
	if err != nil {
		return err
	}

	for rows.Next() {
		var url []byte
		var htmlhash []byte
		if err := rows.Scan(&url, &htmlhash); err != nil {
			return err
		}

		urlString := string(url)

		boolean, err := validationCheck(urlString)
		if err != nil {
			Service.logger.Error(err.Error())
		}

		if boolean {
			if err := Service.Request(urlString, htmlhash); err != nil {
				Service.logger.Error(err.Error())
			}
		}
	}

	return nil
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
		logger: zap.New(
			zap.NewTextEncoder(zap.TextTimeFormat(time.ANSIC)),
			zap.AddCaller(), // Add Line number option
			zap.Output(Out),
		),
	}, nil
}

func (Service *Nishi) Close() {
	Service.db.Close()
}

func (Service *Nishi) buildRequest(method, url string) (*http.Request, error) {
	req, err := http.NewRequest(method, url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", Service.useragent)
	req.Header.Set("Referer", Service.referer)

	return req, nil
}

func (Service *Nishi) Request(url string, htmlhash []byte) error {

	req, err := Service.buildRequest("Get", url)
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
	Service.urls = append(Service.urls, url)
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
