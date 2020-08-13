JSON.awk
========

A practical JSON parser written in awk.

Introduction
------------

JSON.awk is a self-contained, single-file program with no external dependencies.
It is similar to [JSON.sh](https://github.com/dominictarr/JSON.sh), a JSON
parser written in Bash -- retrieved on 2013-03-13 to form the basis for
JSON.awk. Since then, the two projects have taken separate paths, so you
will not find all of JSON.sh features in JSON.awk, and viceversa.

Features
--------

* Single file without external dependencies
* Can parse one or multiple input files within a single invocation
* [Callback interface](doc/callbacks.md) (awk) to hook into parser and output events
* [Library](doc/library.md) of practical callbacks (optional)
* Capture invalid JSON input for further processing
* JSON.sh compatible (as of 2013-03-13) default output format
* Written for POSIX awk; does not require GNU gawk extensions;
  works with mawk 1.3.4 20150503 and higher (some limitations)
* Choice of MIT or Apache 2 license

Supported Platforms
-------------------

All OS platforms for which a POSIX awk implementation is available. Special cases:

* FreeBSD [&raquo;10](https://github.com/step-/JSON.awk/issues/10)
* mac OSX [&raquo;15](https://github.com/step-/JSON.awk/issues/15)

Installing
----------

Add files JSON.awk and optionally callbacks.awk to your project and follow the
examples.

Usage Examples
--------------

For full instructions please [read the docs](doc/usage.md).
If you use mawk please read FAQs [6](doc/FAQ.md#6) and [7](doc/FAQ.md#7).

Passing file names as command arguments:

```sh
awk -f JSON.awk file1.json [file2.json...]

awk -f JSON.awk - < file.json

cat file.json | awk -f JSON.awk -
```

Passing file names on stdin:

```sh
echo -e "file1.json\nfile2.json" | awk -f JSON.awk
```

Using callbacks to build a custom application ([FAQ 5](doc/FAQ.md#5)):

```
awk -f your-callbacks.awk -f JSON.awk file.json
```

Applications
------------

* [Opera-bookmarks.awk](https://github.com/step-/opera-bookmarks.awk)
  Extract (Chromium) Opera bookmarks and QuickDial thumbnails.
  Convert bookmark data to SQLite database and CSV file.

Projects known to use JSON.awk
------------------------------

* [Awk for JSON](https://github.com/mohd-akram/jawk) makes available JSON
  nested objects as the awk array variable `_`, e.g. awk's `_["person","name"]`
  evaluates to `Jason` for the JSON object `{"person":{"name":"Jason"}}`.
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

* [JSON.sh](https://github.com/dominictarr/JSON.sh)'s source code, retrieved on
  2013-03-13, more than inspired version 1.0 of JSON.awk; without JSON.sh this
  project would not exist.

* [gron](https://github.com/tomnomnom/gron) for inspiration leading to
  library module [js-dot-path.awk](doc/library.md#js_dot_path), and for some
  test files.

