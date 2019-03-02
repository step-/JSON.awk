<a name="0"></a>
## Embedding JSON.awk in another awk program

Normally JSON.awk is used stand-alone to output so-called jpaths that describe
an input JSON object.  However, a custom applications can embed JSON.awk in
another awk program to process the jpaths directly.

An awk program that embeds JSON.awk must satisfy two conditions:
* Set global variable `STREAM=0` before JSON.awk runs its main loop.
* Define callback functions `cb_jpaths` and `cb_fails`.

When `STREAM=0` JSON.awk assumes that it is running embedded and modifies
its behavior as follows:

* JSON.awk will not output jpaths to stdout.

* JSON.awk's main loop will call function `cb_jpaths(JPATHS, NJPATHS)`, where
  `JPATHS` is an array of jpaths that represent the input JSON object, and
  `NJPATHS` is the array length. `JPATHS` will include non-leaf nodes when
  global variable `BRIEF=0`.

* JSON.awk's END action will call function `cb_fails(FAILS, NFAILS)`, where
  `FAILS` is an associative array of error messages, if any, that JSON.awk
  prints to stderr while it parses JSON input, and `NFAILS` is the array length.

<a name="notes"></a>
**Notes**

1. JSON.awk prints error messages to stderr regardless of the value of variable
   `STREAM`.

2. If you run JSON.awk stand-alone (non-embedded) you don't need to define
   callbacks except if you run JSON.awk from mawk because mawk's parser
   requires definitions of all the function symbols it finds in the program.
   Practically, to run JSON.awk stand-alone with mawk use the following stanza:

```sh
mawk -f callbacks.awk -f JSON.awk file1.json [file2.json...]
```

File callbacks.awk defines the required callback functions, which are never
called because by default global variable `STREAM=1`.

<a name="examples"></a>
**Examples**

```sh
for i in 1 2 3; do echo "]$i" > /tmp/$i; done
for i in a b c; do echo "[\"$i\"]" > /tmp/$i; done

awk '
  BEGIN { STREAM = 0; BRIEF = 0 }
  function cb_jpaths(a,b){ print "jpaths",a[1],b }
  function cb_fails(a, b){ for(b in a){ print "fail",b,a[b] }}
  function cb_fail1(a){ }
  '"`cat ./JSON.awk`" /tmp/{1,a,2,b,3,c} 2>/dev/null
echo status = $?
```

Output:

```
jpaths [0]	"a" 2
jpaths [0]	"b" 2
jpaths [0]	"c" 2
fail /tmp/1 expected <value> but got <]> at input token 1
<<]>> 1  
fail /tmp/2 expected <value> but got <]> at input token 1
<<]>> 2  
fail /tmp/3 expected <value> but got <]> at input token 1
<<]>> 3  
status = 0
```

If you want for your program to exit immediately with non-zero status when
JSON.awk finds an error modify the previous example:

```sh
  function cb_fail1(m) { print m; STATUS=1; exit }
  END { exit(STATUS) }
```


**See also:**

* File callbacks.awk

[top](#0)

