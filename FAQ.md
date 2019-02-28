# Frequently Asked Questions

<a name="1"></a>
## 1. Usage: how do I run JSON.awk?

Any the following methods works to start JSON.awk. Each method has its own
merits.

### [A] Command-line filenames (since release 1.12.0)

Here you enter json filenames on the command line, the traditional \*nix way.

```sh
awk -f JSON.awk 1.json [2.json ...]
```

When method A is used, JSON.awk doesn't support the awk syntax `variable=value`
for setting variables in the _filename_ list.  Note that the `-v
variable=value` _option_ syntax _is supported_.

### [B] Filenames from stdin (since release 1.0.0)

Here you specify a list of filenames on stdin, one filename per line.

```sh
echo -e "1.json\n2.json" | awk -f JSON.awk
```

JSON.awk will process the files named in the standard input stream, each file
separately.

<a name="1-pipe"></a>
### Data from stdin (piping JSON data)

You can pipe JSON data to JSON.awk using several notations.

```sh
cat 1.json | awk -f JSON.awk "-" [2.json ...]
```

This is an extension of method [A].  JSON.awk reads "-" (stdin) first, which
brings in the contents of file `1.json` from the pipe, then reads the remaining
files, if any, file 2.json and so on. Here "-" denotes stdin and can be used as
its filename.

Note that the following notation is invalid because it sends JSON
data where a list of filenames is expected.

```sh
cat 1.json | awk -f JSON.awk
```

This is the correct notation:

```sh
cat 1.json | awk -f JSON.awk "-"
```

<a name="1-C"></a>
### [C] She-bang

If file JSON.awk has executable permission, and the she-bang line is valid
[see QA 2](#2), you can start JSON.awk directly:

```sh
JSON.awk file1 [file2...]
```

which is equivalent to method [A].

You can also pipe JSON data from stdin:

```sh
cat 1.json | JSON.awk "-"
```

Again, this is like method [A]. Note that the following notation is
invalid:

```sh
cat 1.json | JSON.awk
```

because JSON.awk expects a list of input files from stdin but gets JSON
data instead. This is the correct notation:

```sh
echo -e "file1\nfile2\n" | JSON.awk
```

which is equivalent to method [B].

<a name="1-options"></a>
### Options

To specify options that modify the behavior of JSON.awk use awk option `-v`
followed by the JSON.awk option name and value, like this (in method [C]
notation):

```sh
JSON.awk -v NAME=VALUE
```

`NAME` and `VALUE` can be

* `BRIEF`: `0` or `1` - default `BRIEF=1` - When 1 internal function `parse()`
  will not print non-leaf nodes.
* `STREAM`: `0` or `1` - default `STREAM=1` - When 0 internal function
  `parse()` will not print to stdout and will store jpaths in array `JPATHS[]`
  for stub function `apply()` to process. This can be useful if you need to embed
  JSON.awk in a larger awk program. Your program would set `STREAM=0` and
  _change_ stub function `apply()` to do something useful with the values stored
  in array `JPATHS`. In its default stub form, function `apply()` simply prints
  `JPATHS` elements to stdout. See also this
  [discussion](https://github.com/step-/JSON.awk/pull/11).

<a name="2"></a>
## 2. Do I need to care about the she-bang?

Only if you intend to run JSON.awk using method [C](#1-C) or with permanent
[options](#1-options).
The she-bang is the first line of file JSON.awk, which by default is

```sh
#!/usr/bin/awk -f
```

but could also be

```sh
#!/bin/awk -f
```

or several other forms.

The default value was chosen for performance reasons.  Both binaries could be
installed on your system.  Many Linux distributions link `/bin/awk` to
`/bin/busybox`, and `/usr/bin/awk` to either `/usr/bin/gawk` or
`/usr/bin/mawk`.  Busybox awk is under-powered and takes much longer to run
JSON.awk than gawk and mawk do on identical data.

<a name="3"></a>
## 3. Is mawk 1.3.3 supported (Debian/Ubuntu)?

JSON.awk is reported to work with mawk 1.3.4 20150503 and 20161120.
Version 1.3.3 is [known not to work](http://github.com/step-/JSON.awk/issues/6).
Please upgrade mawk to a newer version.

<a name="4"></a>
## 4. How to parse multiple JSON data files as a single unit?

By default, JSON.awk parses each input file separately from all other input
files.  Therefore, for each input file it resets its internal data structures,
and restarts from zero all ouput array indices.  If your application needs to
parse all data files as a single JSON object, you have two options:
* Pipe all data as a single JSON object as illustrated by the last notation
  shown at the end of [QA 1](#1) section *Piping Data*.
* Modify function `reset()` in file JSON.awk. 

