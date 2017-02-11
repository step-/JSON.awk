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
  works with mawk 1.3.4 20150503 and higher
* Single file, does not depend on external programs
* Your choice of MIT or Apache 2 license 

Setup
-----

Just drop the file JSON.awk in your project folder and run it as an awk
script.

Usage Examples
--------------

For full usage instructions and command-line options please read [FAQ 1](FAQ.md).

```sh
awk -f JSON.awk -v file1.json file2.json

echo -e "file1.json\nfile2.json\n" > filenames && awk -f JSON.awk < filenames

echo -e "file1.json\nfile2.json\n" | awk -f JSON.awk

# pipe JSON data from stdin

cat file1.json file2.json | awk -f JSON.awk

{ echo -; echo; cat file1.json file2.json; } | awk -f JSON.awk
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
