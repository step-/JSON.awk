<a name="0"></a>
# Frequently Asked Questions

**Usage**

* [Usage: how to run JSON.awk?](#1)
* [Do I need to care about the she-bang?](#2)
* [How to parse multiple JSON data files as a single unit?](#4)

**Applications**

* [How to use JSON.awk in my application?](#5)

**Mawk**

* [Is mawk supported (Debian/Ubuntu)?](#3)
* [It doesn't work with mawk (large input file)](#6)
* [How to fix error: mawk: JSON.awk: line NNN: function cb\_somename never defined?](#7)

[top](#0)

<a name="1"></a>
## 1. Usage: how do I run JSON.awk?

TL;DR

```sh
awk  -f JSON.awk 1.json [2.json ...]
gawk -f JSON.awk 1.json [2.json ...]
mawk -f callbacks.awk -f JSON.awk 1.json [2.json ...]

echo -e "1.json\n2.json" | awk -f JSON.awk

cat 1.json | awk -f JSON.awk "-" [2.json ...]

awk -v BRIEF=0 -f JSON.awk 1.json
```

Read [the docs](usage.md)

[top](#0)

<a name="2"></a>
## 2. Do I need to care about the she-bang?

The she-bang is the first line of file JSON.awk and reads

```sh
#!/usr/bin/awk -f
```

but could also be changed to

```sh
#!/bin/awk -f
```

or one of several other forms supported by your operating system.

The default value was chosen for performance reasons.  Both binaries could be
installed on your system.  Many Linux distributions link `/bin/awk` to
`/bin/busybox`, and `/usr/bin/awk` to either `/usr/bin/gawk` or
`/usr/bin/mawk`.  Busybox awk is under-powered and takes much longer to run
JSON.awk than gawk and mawk do on identical data.

[top](#0)

<a name="3"></a>
## 3. Is mawk supported (Debian/Ubuntu)?

Yes. JSON.awk is reported to work with mawk 1.3.4 20150503 and 20161120.
Version 1.3.3 is [known not to work](http://github.com/step-/JSON.awk/issues/6).
Please upgrade mawk to a supported version.

[top](#0)

<a name="4"></a>
## 4. How to parse multiple JSON data files as a single unit?

By default, JSON.awk parses each input file separately from all other input
files.  Therefore, for each input file it resets its internal data structures,
and restarts from zero all ouput array indices.  If your application needs to
parse all data files as a single JSON object, you have two options:
* Pipe all data as a single JSON object as illustrated by the last notation
  shown at the end of [QA 1](#1) section *Piping Data*.
* Modify function `reset()` in file JSON.awk. 

[top](#0)

<a name="5"></a>
## 5. How to use JSON.awk in my application?

TL;DR

```sh
awk -v STREAM=0 -f my-callbacks.awk -f JSON.awk 1.json
```

Read [the docs](callbacks.md)

[top](#0)

<a name="6"></a>
## 6. It doesn't work with mawk (large input file)

I do not recommend running JSON.awk with mawk on large input files (1+ MB)
because mawk shows serious limitations on my Linux test system (mawk 1.3.4
20171017, sprintf buffer size 8192). I noticed at least two issues:

* Mawk complains that its internal sprintf buffer is too small.
  Solution: `mawk -Wsprintf=<new size>...`.
* Mawk seems stuck. It isn't. It just takes a _very_ long time to process some
  regular expressions. When this happens, eventually mawk will silently drop
  the ball, which then results in a parse error message.
  Solution: use gawk (recommended) or busybox awk. They both can handle large
  input files (tested with 3+ MB JSON text input).

## 7. How to fix error: mawk: JSON.awk: line NNN: function cb_somename never defined?

Nothing's wrong with mawk nor JSON.awk.  This error message is just an
unfortunate consequence of mawk's parser design. Run

```sh
mawk -f callbacks.awk -f JSON.awk 1.json
```

to shut off the error message. Read section _Mawk_ of [the docs](callbacks.md)
to know why this works.

[top](#0)

