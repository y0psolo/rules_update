LD_FLAGS = "-s -w"
version ?= main

default: clean all

clean:
	rm -rf dist

update_http:
	GOOS=linux GOARCH=amd64 go build -o "./dist/update_http_linux_amd64" -ldflags=${LD_FLAGS} ./update_http/update_http.go
	GOOS=linux GOARCH=arm64 go build -o "./dist/update_http_linux_arm64" -ldflags=${LD_FLAGS} ./update_http/update_http.go
	GOOS=darwin GOARCH=amd64 go build -o "./dist/update_http_darwin_amd64" -ldflags=${LD_FLAGS} ./update_http/update_http.go
	GOOS=darwin GOARCH=arm64 go build -o "./dist/update_http_darwin_arm64" -ldflags=${LD_FLAGS} ./update_http/update_http.go
	GOOS=windows GOARCH=amd64 go build -o "./dist/update_http_windows_amd64.exe" -ldflags=${LD_FLAGS} ./update_http/update_http.go

update_version:
	GOOS=linux GOARCH=amd64 go build -o "./dist/update_version_linux_amd64" -ldflags=${LD_FLAGS} ./update_version/update_version.go
	GOOS=linux GOARCH=arm64 go build -o "./dist/update_version_linux_arm64" -ldflags=${LD_FLAGS} ./update_version/update_version.go
	GOOS=darwin GOARCH=amd64 go build -o "./dist/update_version_darwin_amd64" -ldflags=${LD_FLAGS} ./update_version/update_version.go
	GOOS=darwin GOARCH=arm64 go build -o "./dist/update_version_darwin_arm64" -ldflags=${LD_FLAGS} ./update_version/update_version.go
	GOOS=windows GOARCH=amd64 go build -o "./dist/update_version_windows_amd64.exe" -ldflags=${LD_FLAGS} ./update_version/update_version.go

rule:
	./release.sh ${version}
	tar --sort=name --numeric-owner --owner=0 --group=0  --mtime="$(git show --no-patch --no-notes --pretty='%cI' HEAD)" --create --gzip --directory=rules --file=dist/rules_update.tar.gz .

all: update_http update_version rule