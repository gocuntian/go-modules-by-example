<!-- __JSON: egrunner script.sh # LONG ONLINE

## Using submodules

Go modules supports nesting of modules, which gives us submodules. This example shows you how.

### Walkthrough

Initialise a directory as a git repo, and add an appropriate remote:


```
{{PrintBlock "setup" -}}
```

Define a root module, at the root of the repo, commit and push:

```
{{PrintBlock "define repo root module" -}}
```

Create a sub package `b` and test that it builds:

```
{{PrintBlock "create package b" -}}
```

Commit, tag and push our new package:

```
{{PrintBlock "commit and tag b" -}}
```

Create a `main` package that will use `b`:

```
{{PrintBlock "create package a" -}}
```

Build and run that main package:

```
{{PrintBlock "run package a" -}}
```

Notice how we resolve to the tagged version of `package b`.


Commit, tag and push our `main` package:


```
{{PrintBlock "commit and tag a" -}}
```

Create another random module and use our `a` command from there:

```
{{PrintBlock "use a" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using submodules

Go modules supports nesting of modules, which gives us submodules. This example shows you how.

### Walkthrough

Initialise a directory as a git repo, and add an appropriate remote:


```
$ mkdir go-modules-by-example-submodules
$ cd go-modules-by-example-submodules
$ git init -q
$ git remote add origin https://github.com/$GITHUB_USERNAME/go-modules-by-example-submodules
```

Define a root module, at the root of the repo, commit and push:

```
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-submodules
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-submodules
$ git add go.mod
$ git commit -q -am 'Initial commit'
$ git push -q
remote: 
remote: Create a pull request for 'master' on GitHub by visiting:        
remote:      https://github.com/myitcv/go-modules-by-example-submodules/pull/new/master        
remote: 
```

Create a sub package `b` and test that it builds:

```
$ mkdir b
$ cd b
$ cat <<EOD >b.go
package b

const Name = "Gopher"
EOD
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/b
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-submodules/b
$ go test
?   	github.com/myitcv/go-modules-by-example-submodules/b	[no test files]
```

Commit, tag and push our new package:

```
$ cd ..
$ git add b
$ git commit -q -am 'Add package b'
$ git push -q
$ git tag b/v0.1.1
$ git push -q origin b/v0.1.1
```

Create a `main` package that will use `b`:

```
$ mkdir a
$ cd a
$ cat <<EOD >.gitignore
/a
EOD
$ cat <<EOD >a.go
package main

import (
	"github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/b"
	"fmt"
)

const Name = b.Name

func main() {
	fmt.Println(Name)
}
EOD
$ go mod init github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/a
go: creating new go.mod: module github.com/myitcv/go-modules-by-example-submodules/a
```

Build and run that main package:

```
$ go run .
go: finding github.com/myitcv/go-modules-by-example-submodules/b v0.1.1
go: downloading github.com/myitcv/go-modules-by-example-submodules/b v0.1.1
Gopher
$ go list -m github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/b
github.com/myitcv/go-modules-by-example-submodules/b v0.1.1
```

Notice how we resolve to the tagged version of `package b`.


Commit, tag and push our `main` package:


```
$ cd ..
$ git add a
$ git commit -q -am 'Add package a'
$ git push -q
$ git tag a/v1.0.0
$ git push -q origin a/v1.0.0
```

Create another random module and use our `a` command from there:

```
$ cd $(mktemp -d)
$ export GOBIN=$PWD/.bin
$ export PATH=$GOBIN:$PATH
$ go mod init example.com/blah
go: creating new go.mod: module example.com/blah
$ go get github.com/$GITHUB_USERNAME/go-modules-by-example-submodules/a@v1.0.0
go: finding github.com/myitcv/go-modules-by-example-submodules/a v1.0.0
go: downloading github.com/myitcv/go-modules-by-example-submodules/a v1.0.0
$ a
Gopher
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
