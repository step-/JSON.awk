JSON.awk
========

A practical JSON parser written in awk.

Quick Start
-----------

JSON.awk is a self-contained, single-file program with no external dependencies.
It is similar to [JSON.sh](https://github.com/dominictarr/JSON.sh), a JSON
parser written in Bash -- retrieved on 2013-03-13 to form the basis for
JSON.awk. Since then, the two projects have taken separate paths, so you
will not find all of JSON.sh features in JSON.awk, and viceversa.

Features
--------

* JSON.sh compatible output format (as of 2013-03-13)
* Can parse one or multiple input files in a single invocation
* Captures invalid JSON input and processes it on exit
* Written for awk; does not require gawk extensions;
  works with mawk 1.3.4 20150503 and higher [&raquo;6](https://github.com/step-/JSON.awk/issues/6);
* Single file, does not depend on external programs
* Your choice of MIT or Apache 2 license 

Supported Platforms
-------------------

All OS platforms where a modern implementation of awk is available. Special cases:

* FreeBSD [&raquo;10](https://github.com/step-/JSON.awk/issues/10)

Setup
-----

Just drop the file JSON.awk in your project folder and run it as an awk
script.

Usage Examples
--------------

For full usage instructions and command-line options please read [FAQ 1](FAQ.md).

Passing file names as command arguments:

```sh
awk -f JSON.awk file1.json file2.json...

awk -f JSON.awk - < file.json

cat file.json | awk -f JSON.awk -
```

Passing file names on stdin:
```sh
echo -e "file1.json\nfile2.json" > filenames && awk -f JSON.awk < filenames

echo -e "file1.json\nfile2.json" | awk -f JSON.awk
```

Projects that use JSON.awk
--------------------------

* [KindleLauncher](https://bitbucket.org/ixtab/kindlelauncher/overview)
  a.k.a. KUAL, an application launcher for the Kindle e-ink models, uses
  JSON.awk to parse menu descriptions.

License
-------

This software is available under the following licenses:

* MIT
* Apache 2

Credits
=======

Without [JSON.sh](https://github.com/dominictarr/JSON.sh) this software
would not exist.
