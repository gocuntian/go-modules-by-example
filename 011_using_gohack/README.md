<!-- __JSON: egrunner script.sh # LONG ONLINE

## Using `github.com/rogpeppe/gohack`

`gohack` is a tool that makes it easy to make temporary edits to your Go modules dependencies. This example shows how to
use it.

### Walkthrough

Ceate an example module:

```
{{PrintBlock "setup" -}}
```

Depend on some module:

```
{{PrintBlockOut "simple example" -}}
```

In this case, we will use a specific version of our dependency:

```
{{PrintBlock "use a specific version of quote" -}}
```

Run the example:

```
{{PrintBlock "run example" -}}
```

Now let's assume we want to tweak the `rsc.io/quote` package, in particular we want to tweak the `Hello` function we are
using. We will use `gohack` to do this.

Install `gohack`:


```
{{PrintBlock "install gohack" -}}
```

"Hack" on `rsc.io/quote`:

```
{{PrintBlock "gohack quote" -}}
```

Verify our module is using the local "hack" copy:

```
{{PrintBlock "see replace" -}}
```

`gohack` puts "hacks" in `$HOME/$module`; we make our changes there:


```
{{PrintBlock "make edit" -}}
```

Rerun our example:


```
{{PrintBlock "rerun" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using `github.com/rogpeppe/gohack`

`gohack` is a tool that makes it easy to make temporary edits to your Go modules dependencies. This example shows how to
use it.

### Walkthrough

Ceate an example module:

```
$ mkdir /tmp/using-gohack
$ cd /tmp/using-gohack
$ go mod init example.com/blah
go: creating new go.mod: module example.com/blah
```

Depend on some module:

```
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
```

In this case, we will use a specific version of our dependency:

```
$ go get rsc.io/quote@v1.5.1
go: finding rsc.io/quote v1.5.1
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: downloading rsc.io/quote v1.5.1
go: downloading rsc.io/sampler v1.3.0
go: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
```

Run the example:

```
$ go run .
Hello, world.
```

Now let's assume we want to tweak the `rsc.io/quote` package, in particular we want to tweak the `Hello` function we are
using. We will use `gohack` to do this.

Install `gohack`:


```
$ echo -e "***\nSee https://github.com/golang/go/issues/24250\n\nThis should really be a 'global' install\n***\n"
***
See https://github.com/golang/go/issues/24250

This should really be a 'global' install
***

$ go install github.com/rogpeppe/gohack
go: finding github.com/rogpeppe/gohack latest
go: downloading github.com/rogpeppe/gohack v0.0.0-20180824061119-102d9ffcbb7f
go: finding golang.org/x/tools v0.0.0-20180803180156-3c07937fe18c
go: finding gopkg.in/errgo.v2 v2.0.1
go: finding github.com/kr/pretty v0.1.0
go: finding gopkg.in/check.v1 v1.0.0-20180628173108-788fd7840127
go: finding github.com/kr/text v0.1.0
go: finding github.com/kr/pty v1.1.1
go: downloading golang.org/x/tools v0.0.0-20180803180156-3c07937fe18c
go: downloading gopkg.in/errgo.v2 v2.0.1
```

"Hack" on `rsc.io/quote`:

```
$ gohack rsc.io/quote
creating rsc.io/quote@v1.5.1
rsc.io/quote => /root/gohack/rsc.io/quote
```

Verify our module is using the local "hack" copy:

```
$ go mod edit -json
{
	"Module": {
		"Path": "example.com/blah"
	},
	"Require": [
		{
			"Path": "github.com/rogpeppe/gohack",
			"Version": "v0.0.0-20180824061119-102d9ffcbb7f",
			"Indirect": true
		},
		{
			"Path": "rsc.io/quote",
			"Version": "v1.5.1"
		}
	],
	"Exclude": null,
	"Replace": [
		{
			"Old": {
				"Path": "rsc.io/quote"
			},
			"New": {
				"Path": "/root/gohack/rsc.io/quote"
			}
		}
	]
}
```

`gohack` puts "hacks" in `$HOME/$module`; we make our changes there:


```
$ cd $HOME/gohack/rsc.io/quote
$ cat <<EOD >quote.go
package quote

func Hello() string {
	return "My hello"
}
EOD
```

Rerun our example:


```
$ cd /tmp/using-gohack
$ go run .
My hello
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
