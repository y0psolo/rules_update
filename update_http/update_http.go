package main

import (
	"crypto/sha256"
	"encoding/hex"
	"flag"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/bazelbuild/buildtools/build"
	"github.com/goccy/go-yaml"
)

func convert(e build.Expr) []build.Expr {
	return []build.Expr{e}
}

func updatebazelRule(url_val string, prefix_val string, encodedSha string, rule *build.Rule) {
	url := &build.StringExpr{Value: url_val}

	rule.SetAttr("urls", &build.ListExpr{List: convert(url)})
	http.Get(url_val)

	log.Print(url_val)
	resp, err := http.Get(url_val)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	var sha string
	if encodedSha == "" {
		h := sha256.New()
		_, err = io.Copy(h, resp.Body)
		if err != nil {
			log.Fatal(err)
		}
		sha = hex.EncodeToString(h.Sum(nil))
	} else {
		sha = encodedSha
	}
	rule.SetAttr("sha256", &build.StringExpr{Value: sha})

	if prefix_val != "" {
		rule.SetAttr("strip_prefix", &build.StringExpr{Value: prefix_val})
	}
}

type Rule struct {
	Name   string
	Sha256 string
	Prefix string
	Url    string
}

func main() {
	var config string
	var bazel string
	var yamlRule map[string]Rule

	flag.StringVar(&config, "config", "rules.yaml", "YAML config file to parse")
	flag.StringVar(&bazel, "bazel", "WORKSPACE", "WORKSPACE to be updated")
	flag.Parse()

	configFile, err := os.Open(config)
	if err != nil {
		log.Fatal(err)
	}
	defer configFile.Close()

	dec := yaml.NewDecoder(configFile, yaml.Strict())
	if err := dec.Decode(&yamlRule); err != nil {
		log.Fatal(err)
	}

	bazelfile, err := os.Open(bazel)
	if err != nil {
		log.Fatal(err)
	}

	wscontent, err := ioutil.ReadAll(bazelfile)
	if err != nil {
		log.Fatal(err)
	}
	bazelfile.Close()

	f, err := build.Parse("bazel", wscontent)
	if err != nil {
		log.Fatal(err)
	}

	for _, r := range f.Rules("") {
		for _, y := range yamlRule {
			if r.Name() == y.Name {
				updatebazelRule(y.Url, y.Prefix, y.Sha256, r)
			}
		}
	}

	err = ioutil.WriteFile(bazel, []byte(build.Format(f)), 0644)
	if err != nil {
		log.Fatal(err)
	}

}
