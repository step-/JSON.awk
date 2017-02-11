# Frequently Asked Questions

## 1. Usage: how do I run JSON.awk?  <a name="1"></a>

Before getting into command-line [options](#1-options) that modify the behavior of JSON.awk, let's review how to start just the script.

All the following methods work to start JSON.awk. Each method has its
own merits.

### [A] Command-line filenames (since release 1.12.0)

Here you enter json filenames on the command-line, the traditional \*nix
way.

```sh
awk -f JSON.awk 1.json [2.json ...]
```

In this method, JSON.awk doesn't support the `variable=value` _filename_
syntax that awk provides.  Note: the `-v variable=value` _option_ syntax
_is supported_.

### [B] Filenames from stdin (since release 1.0.0)

Here you specify a list of filenames on stdin, one filename per line,
and append a blank line to mark the end of the list.

```sh
echo -e "1.json\n2.json\n" | awk -f JSON.awk
```

JSON.awk will process the files named in the standard input stream.

### Data from stdin (piping JSON data)  <a name="1-pipe"></a>

You can pipe JSON data to JSON.awk with several notations.

```sh
cat 1.json | awk -f JSON.awk "-" 2.json [...]
```

This is an extension of method [A].  JSON.awk reads `stdin` first, which
brings the contents of file `1.json`, then reads file 2.json and so
on. Use "-" as the conventional name for stdin.

Note that the following notation _isn't_ supported.

```sh
cat 1.json | awk -f JSON.awk
```

Re-write it into the equivalent, supported notation:

```sh
cat 1.json | awk -f JSON.awk "-"
```

This is an extension of method [B]:

```sh
{ echo -e "-\n"; cat 1.json; } | awk -f JSON.awk
```

Note that specifying file names from stdin requires for the input stream to be
line-buffered.
See this [open issue](https://github.com/step-/JSON.awk/issues/7).

A useful short form of the above is:

```sh
{ echo; cat 1.json; } | awk -f JSON.awk
```

which you can use to combine several JSON data files into a single unit:

```sh
{ echo; cat 1-partial.json 2-partial.json; } | awk -f JSON.awk
```

Combining JSON data is further discussed in [QA 4](#4).

### [C] She-bang  <a name="1-C"></a>

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

Again, this is like method [A], and note that the following notation _isn't_
supported:

```sh
cat 1.json | JSON.awk
```

because JSON.awk is expecting a list of input files from stdin but gets JSON
data instead. Of course, this notation is supported:

```sh
echo -e "file1\nfile2\n" | JSON.awk
```

which is equivalent to method [B].

### Options  <a name="1-options"></a>

To specify options that modify the behavior of JSON.awk use awk option `-v`
followed by the JSON.awk option name and value, like this (in method [C]
notation):

```sh
JSON.awk -v NAME=VALUE
```

`NAME` and `VALUE` can be

* `BRIEF=0` - default `BRIEF=1` - Does not print non-leaf nodes.
* `STREAM=1` - default `STREAM=0` - Internal function `parse()` does not print
  to stdout and stores jpaths in array `JPATHS[]`. This is useful if you need
  to embed JSON.awk is a larger awk program.

## 2. Do I need to care about the she-bang?  <a name="2"></a>

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

## 3. Is mawk 1.3.3 supported (Debian/Ubuntu)?  <a name="3"></a>

JSON.awk is reported to work with mawk 1.3.4 20150503 and 20161120.
Version 1.3.3 is [known not to work](http://github.com/step-/JSON.awk/issues/6).
Please upgrade mawk to a newer version.

## 4. How to parse multiple JSON data files as a single unit?  <a name="4"></a>

By default, JSON.awk parses each input file separately from all other input
files.  Therefore, for each input file it resets its internal data structures,
and restarts from zero all ouput array indices.  If your application needs to
parse all data files as a single unit, you have to options.
Either modify function `reset()` in file JSON.awk, or pipe all data as a single
unit, using the last notation shown at the end of [QA 1](#1) section on *Piping
Data*.

