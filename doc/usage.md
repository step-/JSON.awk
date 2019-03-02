<a name="0"></a>
## Usage

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

<a name="pipe"></a>
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

<a name="C"></a>
### [C] She-bang

If file JSON.awk has executable permission, and a valid she-bang line, e.g.,
`#!/usr/bin/awk`, you can start JSON.awk directly:

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

<a name="options"></a>
### Options

Options that enable specific features of JSON.awk are implemented as global
variables.  To set global variables when running JSON.awk use awk option `-v`
followed by global variable name `=` value, like this (in method [C] notation):

```sh
JSON.awk -v NAME=VALUE
```

`NAME` and `VALUE` can be

* `BRIEF`: `0` or `1` - default `BRIEF=1` - When 1 internal function `parse()`
  will not print non-leaf nodes.
* `STREAM`: `0` or `1` - default `STREAM=1` - When 0 JSON.awk runs in
  "embedded" mode: internal function `parse()` does not print to stdout;
  JSON.awk calls externally-defined callback function - see [FAQ 5](#5).

[top](#0)

