package main

import (
	"flag"
	"io/ioutil"
	"log"
	"os"

	"github.com/bazelbuild/buildtools/build"
	"github.com/goccy/go-yaml"
)

func updateVersion(key string, value string, dict *build.DictExpr) {
	for _, kv := range dict.List {
		k, ok := kv.Key.(*build.StringExpr)
		if !ok {
			return
		}
		_, ok = kv.Value.(*build.StringExpr)
		if !ok {
			return
		}
		if key == k.Value {
			kv.Value = &build.StringExpr{Value: value}
			return
		}
	}
}

type Version struct {
	Name  string
	Key   string
	Value string
}

func main() {
	var config string
	var bazel string
	var yamlRule map[string]Version

	flag.StringVar(&config, "config", "versions.yaml", "YAML config file to parse")
	flag.StringVar(&bazel, "bazel", "versions.bzl", "Bazel file to be updated")
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

	f, err := build.Parse(".bzl", wscontent)
	if err != nil {
		log.Fatal(err)
	}

	var dictassign []*build.AssignExpr

	for _, stmt := range f.Stmt {
		build.Walk(stmt, func(x build.Expr, stk []build.Expr) {
			assign, ok := x.(*build.AssignExpr)
			if !ok {
				return
			}
			_, ok = assign.LHS.(*build.Ident)
			if !ok {
				return
			}
			dictassign = append(dictassign, assign)
		})
	}

	for _, kv := range dictassign {
		key, ok := kv.LHS.(*build.Ident)
		if !ok {
			continue
		}
		for _, y := range yamlRule {
			if key.Name == y.Name {

				if y.Key == "" {
					_, ok := kv.RHS.(*build.StringExpr)
					if !ok {
						continue
					}
					kv.RHS = &build.StringExpr{Value: y.Value}
				} else {
					dict, ok := kv.RHS.(*build.DictExpr)
					if !ok {
						continue
					}
					updateVersion(y.Key, y.Value, dict)
				}

			}
		}
	}

	err = ioutil.WriteFile(bazel, []byte(build.Format(f)), 0644)
	if err != nil {
		log.Fatal(err)
	}

}
