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

# block: setup
mkdir /tmp/go-modules-by-example-tools
cd /tmp/go-modules-by-example-tools
go mod init example.com/blah/painkiller

# block: set bin target
export GOBIN=$PWD/bin
export PATH=$GOBIN:$PATH

cat <<EOD > tools.go
// +build tools

package tools

import (
        _ "golang.org/x/tools/cmd/stringer"
)
EOD
gofmt -w tools.go

# block: add tool dependency
cat tools.go

# block: install tool dependency
go install golang.org/x/tools/cmd/stringer

# block: module deps
go mod edit -json

# block: tool on path
which stringer

cat <<EOD > painkiller.go
package main

import "fmt"

//go:generate stringer -type=Pill

type Pill int

const (
	Placebo Pill = iota
	Aspirin
	Ibuprofen
	Paracetamol
	Acetaminophen = Paracetamol
)

func main() {
	fmt.Printf("For headaches, take %v\n", Ibuprofen)
}
EOD
gofmt -w painkiller.go

# block: painkiller.go
cat painkiller.go

# block: go generate and run
go generate
go run .


# block: version details
go version
