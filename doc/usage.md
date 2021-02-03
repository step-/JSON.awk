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
JSON.awk [-v NAME=VALUE...]
```

**BRIEF**

VALUE can be 0 or a positive integer M, default 1.  Non-zero excludes non-leaf
elements, that is, arrays and objects, from stdout. Bit mask M selects which
"empty" values should be included when printing to stdout or passing such
elements to callback functions. It selectively censors the following "empty"
JSON elements (VALUE in brackets): `""` (1), `[]` (2) and `{}` (4). For
instance, to exclude arrays and objects but include empty arrays and empty
objects, `[]` and `{}`, use `-v BRIEF=6`.&dagger;

VALUE 8, which corresponds to bit 3, _excludes_ `""` and wins over bit 0 (VALUE
1). So, if you want to exclude array and objects, whether empty or non-empty,
and empty strings use `-v BRIEF=8`. VALUE 6 excludes empty strings. The default
VALUE (1) corresponds to excluding non-leaf elements while including empty
strings. This behavior is compatible with previous versions. VALUE 0 includes
all arrays, objects and strings whether empty or non-empty. To further tailor
output use callbacks.

&dagger; Added in version 1.3 - previous versions never output empty arrays and
empty objects at all.

The following table shows the output of the following command for `$i` in 0..8.

```sh
echo '["",{},[],10]' | awk -f JSON.awk -v BRIEF=$i
```

|    0   |    1   |    2   |    3   |    4   |    5   |    6   |    7   |    8   |
|--------|--------|--------|--------|--------|--------|--------|--------|--------|
| [0] "" | [0] "" |        | [0] "" |        | [0] "" |        | [0] "" |        |
| [1] {} |        |        |        | [1] {} | [1] {} | [1] {} | [1] {} |        |
| [2] [] |        | [2] [] | [2] [] |        |        | [2] [] | [2] [] |        |
| [3] 10 | [3] 10 | [3] 10 | [3] 10 | [3] 10 | [3] 10 | [3] 10 | [3] 10 | [3] 10 |
| _note_ |        |        |        |        |        |        |        |        |

_note_: `BRIEF=0` also prints `[] ["",{},[],10]`


**STREAM**

VALUE can be 0 or 1, default 1. Zero activates callbacks to hook into parse
events and print to stdout.

**STRICT**

VALUE can be 0, 1 or 2, default 1.  Zero disables strict enforcement of string
character escapes as defined in RFC8259 section 7. Other values enable strict
escapes.  The only difference between 1 and 2 is the solidus (forward slash)
character, which according to the specification may be escaped with a
backslash, i.e. `\/`.  When VALUE is 2, solidus must be escaped.  Note that the
default VALUE makes the parser reject all character escapes except `\"`, `\\`,
`\b`, `\f`, `\n`, `\r`, `\/`, `\t`, and the `\uXXXX` escape covering all
Unicode codepoints.

### Streaming JSON texts

JSON.awk support a single JSON text per input file.  If you need to process
a stream of JSON texts put each one into its own file.  Here is a contrived
example to make the point:

```bash
bash-4.4# JSON.awk -v BRIEF=0 <(echo '[1]') <(echo '[2]')
```
```
[0]     1
[]      [1]
[0]     2
[]      [2]
```

### Callbacks

```sh
awk -f callbacks.sh -f JSON.awk file.json ...
```

[Read more](./callbacks.md).

### Library

```sh
awk -f lib/<callback module>.awk -f JSON.awk -v STREAM=0 file.json ...
```

[Read more](./library.md).

[top](#0)

