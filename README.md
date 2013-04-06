JSON.awk
========

A practical JSON parser written in awk.

Quick Start
-----------

This software is based on [JSON.sh](https://github.com/dominictarr/JSON.sh), a pipeable JSON parser written in Bash, retrieved on 2013-03-13 and herein ported to awk.  JSON.awk is a self-contained script with no external dependencies.

Features
--------

* JSON.sh compatible output format (as of 2013-03-13)
* Can parse one or multiple input files in a single invocation
* Captures invalid JSON input and processes it upon exiting
* Written for awk, does not require gawk extensions
* Does not depend on external programs
* Choice of MIT or Apache 2 license 

Setup
-----

Just drop the file JSON.awk in your project folder and run it as an awk script. You need to specify input arguments in a slightly unconventional way, so pay attention to usage notes.

Usage
-----

JSON.awk takes no input arguments on the command-line. Instead it reads a list of input filenames from stdin, one filename per line. An empty line marks the end of the list:
```sh
echo -e "file1\nfile2\n" | awk -f JSON.awk
```

Of course you can use redirection instead of piping:
```sh
echo -e "file1\nfile2\n" > list && awk -f JSON.awk < list
```

To pass JSON from stdin you can use:
```sh
{ echo -; echo; cat; } | awk -f JSON.awk
```

Real-Life Examples
------------------

* [KindleLauncher](https://bitbucket.org/ixtab/kindlelauncher/overview) a.k.a. KUAL, an application launcher for the Kindle e-ink models, uses JSON.awk to parse menu descriptions.

Application Notes
-----------------

Within a single invocation JSON.awk processes each input file separately from all other input files.  This means that it resets internal data structures upon reading each input file.  However your application may need to process all files as a single lump. To enable such mode please read the comments in function reset() in the source code.

License
-------

This software is available under the following licenses:

* MIT
* Apache 2

Credits
=======

Without [JSON.sh](https://github.com/dominictarr/JSON.sh) this software would not exist. It owes JSON.sh its entire tokenizer and parser logic.
