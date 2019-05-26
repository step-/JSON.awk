<a name="0"></a>
## Building applications with JSON.awk

At a simple level JSON.awk can be used stand-alone to output so-called "jpaths"
that describe an input JSON text. Then JSON.awk's output is piped through some
text filter, which will arrange it in some way and realize an application.

However, with JSON.awk it is also possible to build applications by defining
and including a set of callback functions that hook into parser and output
events. With this callback interface writing applications that transform JSON
text into some other programming language or data format can be more accurate
and controlled but it requires writing bits of awk code.

Finally, more complex awk applications can embed JSON.awk source code to access
the parser and process jpaths directly.

This document describes the callback interface. Note that if you run JSON.awk
as a stand-alone filter you don't need to define or include callbacks (unless
your platform uses mawk, see below).

<name a="library"></a>
## Library

This repository includes a [library](doc/library.md) of awk callbacks that were
developed to solve various practical problems, and are fully worked-out source
code examples of how to use the callback interface.

<name a="callbacks"></a>
## Callbacks

To use callbacks an application must:

1. set global variable `STREAM=0` before JSON.awk runs its main loop

2. define the callback functions.

File [callbacks.awk](callbacks.awk) implements stubs of all required
callback functions that your application can reuse or redefine as needed.

When `STREAM=0` JSON.awk will modify its behavior as follows:

* It will call callbacks for each JSON array, object or simple value that
  it is parsing.
* It will not output jpaths to stdout but instead it will call callbacks
  to do so.
* It will not report errors but instead it will call callbacks to do so.

More specifically, for an input JSON array the parser will call function
`cb_parse_array_enter` on token `[`, followed by function `cb_parse_array`, and
finally function `cb_parse_array_exit` on token `]`. If the input array is
empty, that is `[]`, JSON.awk will call `cb_parse_array_empty` instead of
`cb_parse_array`.

Similarly, for an input JSON object the parser will call four functions with
`_object` replacing `_array` in the function names, and `{`,`}` replacing
`[`,`]`.

For printing output, JSON.awk will call functions `cb_jpaths(JPATHS, NJPATHS)`,
where `JPATHS` is an awk array of jpaths that represent the input JSON text,
and `NJPATHS` is the array length. `JPATHS` will include non-leaf nodes when
global variable `BRIEF=0`.

As the parser progresses through the parsing tree, JSON.awk will call function
`cb_append_jpath_component` to format jpaths, and function
`cb_append_jpath_value` when a JSON value for a given jpath is parsed.
These two functions provide entry points for an application to generate a
custom output syntax, e.g., translating the input JSON text into statements of
any programming language, such as javascript, etc.

On encountering an error, JSON.awk will call function `cb_fail1`, If `cb_fail1`
returns a non-zero value then JSON.awk will print the error message to stderr,
which is what JSON.awk does when `STREAM=1`.  Note that JSON.awk prints error
messages to stderr regardless of the value of variable `STREAM`.

JSON.awk's `END` action will call function `cb_fails(FAILS, NFAILS)`, where
`FAILS` is an awk associative array of error messages, if any, that JSON.awk
accumulates while it parses JSON input, and `NFAILS` is the array length.

Callbacks can reference the following global variables:

* `FILEINDEX` the integer index of the current input file (starts at 1)
* `CB_VALUE` the JSON text of the parsed array or object
* Any other global variable (see the awk source files).

<a name="mawk"></a>
**Mawk**

If you use mawk to run JSON.awk then you must always define callbacks even if
you will not use them due to the way the mawk parser works.  Practically, to
run JSON.awk stand-alone with mawk use the following stanza:

```sh
mawk -f callbacks.awk -f JSON.awk file1.json [file2.json...]
```

This way callbacks will be defined to satisfy mawk's parser but they will not
be called (unless you set `STREAM=0`).

<a name="examples"></a>
**Examples**

Include and use the default callbacks as follows:

```sh
awk -f callbacks.awk -f JSON.awk -v STREAM=1 some-text.json
```

To define your own callbacks, copy file callbacks.awk to my-callbacks.awk, then
edit the latter replacing the following function definitions:

```awk
function cb_jpaths(a,b){ print "jpaths",a[1],b }
function cb_fails(a, b){ for(b in a){ print "fail",b,a[b] }}
function cb_fail1(a){ }
BEGIN { BRIEF=0; STREAM=0 }
```

then run:

```sh
for i in 1 2 3; do echo "]$i" > /tmp/$i; done
for i in a b c; do echo "[\"$i\"]" > /tmp/$i; done

awk -f my-callbacks.awk -f JSON.awk /tmp/{1,a,2,b,3,c} 2>/dev/null

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

```awk
  function cb_fail1(m) { print m; STATUS=1; exit }
  END { exit(STATUS) }
```

[top](#0)

