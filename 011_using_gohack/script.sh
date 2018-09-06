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
mkdir /tmp/using-gohack
cd /tmp/using-gohack
assert "$? -eq 0" $LINENO
go mod init example.com/blah
assert "$? -eq 0" $LINENO

cat <<EOD > blah.go
package main

import (
		"fmt"
        "rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
EOD
gofmt -w blah.go
assert "$? -eq 0" $LINENO

# block: simple example
cat blah.go

# block: use a specific version of quote
go get rsc.io/quote@v1.5.1

# block: run example
go run .

# block: install gohack
echo -e "***\nSee https://github.com/golang/go/issues/24250\n\nThis should really be a 'global' install\n***\n"
go install github.com/rogpeppe/gohack

# block: gohack quote
gohack rsc.io/quote

# block: see replace
go mod edit -json

# block: make edit
cd $HOME/gohack/rsc.io/quote
cat <<EOD > quote.go
package quote

func Hello() string {
	return "My hello"
}
EOD

# block: rerun
cd /tmp/using-gohack
go run .

# block: version details
go version
