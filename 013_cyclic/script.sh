#!/usr/bin/env bash

set -u
set -x

assert()
{
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  if [ -z "$2" ]
  then
    exit $E_PARAM_ERR
  fi

  lineno=$2

  if [ ! $1 ]
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"
    exit $E_ASSERT_FAILED
  fi
}

# **START**

export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH
echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@example.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false
git config --global push.default current

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists go-modules-by-example-cyclic go-modules-by-example-cyclic_$now
assert "$? -eq 0" $LINENO
githubcli repo create go-modules-by-example-cyclic
assert "$? -eq 0" $LINENO

# block: repo
echo https://github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic

# block: module
echo github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic

# block: moduleb
echo github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic/b

# block: setup
mkdir go-modules-by-example-cyclic
cd go-modules-by-example-cyclic
git init -q
assert "$? -eq 0" $LINENO
git remote add origin https://github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic
assert "$? -eq 0" $LINENO

# prepare module
mkdir a b
cat <<EOD > a/a.go
package a

import "github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic/b"

const AName = b.BName
EOD
cat <<EOD > b/b.go
package b

const BName = "B"
EOD
cat <<EOD > b/b_test.go
package b_test

import (
		"github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic/a"
		"fmt"
		"testing"
)

func TestUsingA(t *testing.T) {
		fmt.Printf("Here is A: %v\n", a.AName)
}
EOD
gofmt -w a/a.go b/b.go b/b_test.go

# block: define repo root module
go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic
assert "$? -eq 0" $LINENO
cat a/a.go
cat b/b.go
cat b/b_test.go
assert "$? -eq 0" $LINENO
go test -v ./...
assert "$? -eq 0" $LINENO
git add -A
assert "$? -eq 0" $LINENO
git commit -q -am "Commit 1: initial commit of parent module github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic"
assert "$? -eq 0" $LINENO
git rev-parse HEAD
assert "$? -eq 0" $LINENO
git push -q
assert "$? -eq 0" $LINENO

# block: create submodule from b
cd b
go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic/b
assert "$? -eq 0" $LINENO
cd ..
git add -A
assert "$? -eq 0" $LINENO
git commit -q -am "Commit 2: create github.com/$GITHUB_USERNAME/go-modules-by-example-cyclic/b"
assert "$? -eq 0" $LINENO
git rev-parse HEAD
assert "$? -eq 0" $LINENO
git push -q
assert "$? -eq 0" $LINENO

# block: create mutual dependency
go test -v ./...
assert "$? -eq 0" $LINENO
cd b
assert "$? -eq 0" $LINENO
go test -v ./...
assert "$? -eq 0" $LINENO

# block: list root dependencies
cd ..
assert "$? -eq 0" $LINENO
go list -m all
assert "$? -eq 0" $LINENO

# block: list b dependencies
cd b
go list -m all
assert "$? -eq 0" $LINENO

# block: commit mutual dependency
cd ..
git add -A
assert "$? -eq 0" $LINENO
git commit -q -am "Commit 3: the mutual dependency"
assert "$? -eq 0" $LINENO
git rev-parse HEAD
assert "$? -eq 0" $LINENO
git push -q
assert "$? -eq 0" $LINENO

# block: version details
go version
