package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestMetadata(t *testing.T) {
	w := httptest.NewRecorder()
	projectName := "projecttest"
	buildTime := time.Now().Format("20180102_03:04:05")
	commit := "testcommit"
	release := "0.6"
	m := metadata(projectName, buildTime, commit, release)
	m(w, nil)

	resp := w.Result()
	if have, want := resp.StatusCode, http.StatusOK; have != want {
		t.Errorf("Status code is wrong. Have: %d, want: %d.", have, want)
	}

	data, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		t.Fatal(err)
	}

	info := struct {
		ProjectName string `json:projectName`
		BuildTime   string `json:"buildTime"`
		Commit      string `json:"commit"`
		Release     string `json:"release"`
	}{}

	err = json.Unmarshal(data, &info)
	if err != nil {
		t.Fatal(err)
	}
	if info.ProjectName != projectName {
		t.Errorf("Project name is wrong. Have: %s, want: %s", info.ProjectName, projectName)
	}
	if info.Release != release {
		t.Errorf("Release version is wrong. Have: %s, want: %s", info.Release, release)
	}
	if info.BuildTime != buildTime {
		t.Errorf("Build time is wrong. Have: %s, want: %s", info.BuildTime, buildTime)
	}
	if info.Commit != commit {
		t.Errorf("Commit is wrong. Have: %s, want: %s", info.Commit, commit)
	}
}
