package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"runtime"
	"strings"
	"sync"

	_ "github.com/lib/pq"

	"github.com/labstack/echo"
	"github.com/labstack/echo/engine/standard"
	"github.com/labstack/echo/middleware"
	"github.com/pkg/errors"
)

type Data struct {
	URLs []string
}

func main() {
	port := ":5001"
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/healthcheck", healthcheck)
	e.POST("/notification", notification)

	fmt.Fprintf(os.Stdout, "Running notifier server: http://localhost%s/\n", port)
	e.Run(standard.New(port))
}

func healthcheck(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]string{
		"message": "I love the world :D",
	})
}

// MAIN
func notification(c echo.Context) error {
	decoder := json.NewDecoder(c.Request().Body())
	data := new(Data)
	if err := decoder.Decode(data); err != nil {
		return ErrorResponse(c, err)
	}

	if err := Notify(data.URLs); err != nil {
		return ErrorResponse(c, err)
	}

	return c.JSON(http.StatusOK, map[string]string{
		"Status": "OK",
	})
}

func ErrorResponse(c echo.Context, err error) error {
	return c.JSON(http.StatusInternalServerError, map[string]string{
		"Status": "Failed",
		"Reason": err.Error(),
	})
}

func Notify(urls []string) error {
	db, err := sql.Open("postgres", "dbname=nishi_service host=localhost sslmode=disable")
	if err != nil {
		return err
	}
	defer db.Close()

	// Create dictionary
	// key: token, values: [urls]
	dict := make(map[string][]string)
	for _, url := range urls {
		if err := makeDict(dict, url, db); err != nil {
			return err
		}
	}

	// Notify
	var wg sync.WaitGroup
	semaphore := make(chan bool, runtime.NumCPU())
	for token := range dict {
		wg.Add(1)
		go func(vals []string, token string) {
			defer wg.Done()
			p(semaphore)

			if err := ThrowMessage(token, vals); err != nil {
				fmt.Fprintf(os.Stderr, "Error - token: %s, reason: %s\n", token, err.Error())
			}

			v(semaphore)
		}(dict[token], token)
	}
	wg.Wait()

	return nil
}

func makeDict(dict map[string][]string, url string, db *sql.DB) error {
	rows, err := db.Query("select token from users where id in (select user_id from hang_url where do_notify = 1 and url = '" + url + "')")
	if err != nil {
		return err
	}

	for rows.Next() {
		var token []byte
		if err := rows.Scan(&token); err != nil {
			return err
		}

		tokenString := string(token)
		if _, ok := dict[tokenString]; ok {
			dict[tokenString] = append(dict[tokenString], url)
		} else {
			dict[tokenString] = []string{url}
		}
	}

	return nil
}

func ThrowMessage(token string, urls []string) error {
	vals := url.Values{}
	vals.Set("message", createMessage(urls))

	req, err := buildRequestForLINE(token, vals)
	if err != nil {
		return err
	}

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		return errors.Errorf("Response failed: %s", statusReason(res.StatusCode))
	}

	return nil
}

func statusReason(statusCode int) (reason string) {
	switch statusCode {
	case 400:
		reason = "400 - Unauthorized request"
	case 401:
		reason = "401 - Disabled access token"
	case 500:
		reason = "500 - Internal server error"
	default:
		reason = fmt.Sprintf("%d", statusCode)
	}
	return
}

func createMessage(urls []string) string {
	return strings.Join(urls, " と ") + " の更新を確認したよ♪"
}

func buildRequestForLINE(token string, data url.Values) (*http.Request, error) {
	req, err := http.NewRequest("POST", "https://notify-api.line.me/api/notify", strings.NewReader(data.Encode()))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("Authorization", "Bearer "+token)

	return req, nil
}

// lock
func p(semaphore chan bool) {
	semaphore <- true
}

// unlock
func v(semaphore chan bool) {
	<-semaphore
}
