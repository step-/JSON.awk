#!/usr/bin/awk -f
# Note on she-bang: /usr/bin/awk is usually much faster than /bin/awk,
# if you have both binaries installed in your system. Reason, the latter
# is likely to be the under-powered busybox widget. You can use either
# program, the difference is just in the wall clock time.
#
# Software: JSON.awk - a practical JSON parser written in awk
# Version: 1.11a
# Author: step- on github.com
# License: This software is licensed under the MIT or the Apache 2 license.
# Project home: https://github.com/step-/JSON.awk.git
# Credits: This software includes major portions of JSON.sh, a pipeable JSON
#   parser written in Bash, retrieved on 20130313
#   https://github.com/dominictarr/JSON.sh
#

# See README.md for extended usage instructions.
# Usage:
#   printf "%s\n" Filepath [Filepath...] "" | awk [-v Option="value"] [-v Option="value"...] -f JSON.awk
# Options: (default value in braces)
#   BRIEF=0  don't print non-leaf nodes {1}
#   STREAM=0  don't print to stdout, and store jpaths in JPATHS[] {1}

BEGIN { #{{{
  if (BRIEF == "") BRIEF=1 # parse() omits printing non-leaf nodes
  if (STREAM == "") STREAM=1; # parse() omits stdout and stores jpaths in JPATHS[]
	# for each input file:
	#   TOKENS[], NTOKENS, ITOKENS - tokens after tokenize()
	#   JPATHS[], NJPATHS - parsed data (when STREAM=0)
	# at script exit:
	#   FAILS[] - maps names of invalid files to logged error lines
	delete FAILS

	# filepathnames from stdin
	# usage: echo -e "file1\nfile2\n" | awk -f JSON.awk
	# usage: { echo -; echo; cat; } | awk -f JSON.awk
	while (getline ARGV[++ARGC] < "/dev/stdin") {
		if (ARGV[ARGC] == "")
			break
	}
	# set file slurping mode
	srand(); RS="n/o/m/a/t/c/h" rand()
}
#}}}

{ # main loop: process each file in turn {{{
	reset() # See important application note in reset()

	tokenize($0) # while(get_token()) {print TOKEN}
	if (0 == parse()) {
		apply(JPATHS, NJPATHS)
	}
}
#}}}

END { # process invalid files {{{
	for(name in FAILS) {
		print "invalid: " name
		print FAILS[name]
	}
}
#}}}

function apply (ary, size,   i) { # stub {{{
	for (i=1; i<size; i++)
		print ary[i]
}
#}}}

function get_token() { #{{{
# usage: {tokenize($0); while(get_token()) {print TOKEN}}

	# return getline TOKEN # for external tokenizer

	TOKEN = TOKENS[++ITOKENS] # for internal tokenize()
	return ITOKENS < NTOKENS
}
#}}}

function parse_array(a1,   idx,ary,ret) { #{{{
	idx=0
	ary=""
	get_token()
#scream("parse_array(" a1 ") TOKEN=" TOKEN)
	if (TOKEN != "]") {
		while (1) {
			if (ret = parse_value(a1, idx)) {
				return ret
			}
			idx=idx+1
			ary=ary VALUE
			get_token()
			if (TOKEN == "]") {
				break
			} else if (TOKEN == ",") {
				ary = ary ","
			} else {
				report(", or ]", TOKEN ? TOKEN : "EOF")
				return 2
			}
			get_token()
		}
	}
	if (1 != BRIEF) {
		VALUE=sprintf("[%s]", ary)
	} else {
		VALUE=""
	}
	return 0
}
#}}}

function parse_object(a1,   key,obj) { #{{{
	obj=""
	get_token()
#scream("parse_object(" a1 ") TOKEN=" TOKEN)
	if (TOKEN != "}") {
		while (1) {
			if (TOKEN ~ /^".*"$/) {
				key=TOKEN
			} else {
				report("string", TOKEN ? TOKEN : "EOF")
				return 3
			}
			get_token()
			if (TOKEN != ":") {
				report(":", TOKEN ? TOKEN : "EOF")
				return 4
			}
			get_token()
			if (parse_value(a1, key)) {
				return 5
			}
			obj=obj key ":" VALUE
			get_token()
			if (TOKEN == "}") {
				break
			} else if (TOKEN == ",") {
				obj=obj ","
			} else {
				report(", or }", TOKEN ? TOKEN : "EOF")
				return 6
			}
			get_token()
		}
	}
	if (1 != BRIEF) {
		VALUE=sprintf("{%s}", obj)
	} else {
		VALUE=""
	}
	return 0
}
#}}}

function parse_value(a1, a2,   jpath,ret,x) { #{{{
	jpath=(a1!="" ? a1 "," : "") a2 # "${1:+$1,}$2"
#scream("parse_value(" a1 "," a2 ") TOKEN=" TOKEN ", jpath=" jpath)
	if (TOKEN == "{") {
		if (parse_object(jpath)) {
			return 7
		}
	} else if (TOKEN == "[") {
		if (ret = parse_array(jpath)) {
			return ret
		}
	} else if (TOKEN == "") { #test case 20150410 #4
		report("value", "EOF")
		return 9
	} else if (TOKEN ~ /^([^0-9])$/) {
		# At this point, the only valid single-character tokens are digits.
		report("value", TOKEN)
		return 9
	} else {
		VALUE=TOKEN
	}
	if (! (1 == BRIEF && ("" == jpath || "" == VALUE))) {
		x=sprintf("[%s]\t%s", jpath, VALUE)
		if(0 == STREAM) {
			JPATHS[++NJPATHS] = x
		} else {
			print x
		}
	}
	return 0
}
#}}}

function parse(   ret) { #{{{
	get_token()
	if (ret = parse_value()) {
		return ret
	}
	if (get_token()) {
		report("EOF", TOKEN)
		return 11
	}
	return 0
}
#}}}

function report(expected, got,   i,from,to,context) { #{{{
	from = ITOKENS - 10; if (from < 1) from = 1
	to = ITOKENS + 10; if (to > NTOKENS) to = NTOKENS
	for (i = from; i < ITOKENS; i++)
		context = context sprintf("%s ", TOKENS[i])
	context = context "<<" got ">> "
	for (i = ITOKENS + 1; i <= to; i++)
		context = context sprintf("%s ", TOKENS[i])
	scream("expected <" expected "> but got <" got "> at input token " ITOKENS "\n" context)
}
#}}}

function reset() { #{{{
# Application Note:
# If you need to build JPATHS[] incrementally from multiple input files:
# 1) Comment out below:        delete JPATHS; NJPATHS=0
#    otherwise each new input file would reset JPATHS[].
# 2) Move the call to apply() from the main loop to the END statement.
# 3) In the main loop consider adding code that deletes partial JPATHS[]
#    elements that would result from parsing invalid JSON files.

	TOKEN=""; delete TOKENS; NTOKENS=ITOKENS=0
	delete JPATHS; NJPATHS=0
	VALUE=""
}
#}}}

function scream(msg) { #{{{
	FAILS[FILENAME] = FAILS[FILENAME] (FAILS[FILENAME]!="" ? "\n" : "") msg
	msg = FILENAME ": " msg
	print msg >"/dev/stderr"
}
#}}}

function tokenize(a1,   pq,pb,ESCAPE,CHAR,STRING,NUMBER,KEYWORD,SPACE) { #{{{
# usage A: {for(i=1; i<=tokenize($0); i++) print TOKENS[i]}
# see also get_token()

	# POSIX character classes (gawk) - contact me for non-[:class:] notation
	# Replaced regex constant for string constant, see https://github.com/step-/JSON.awk/issues/1
#	ESCAPE="(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})"
#	CHAR="[^[:cntrl:]\\\"]"
#	STRING="\"" CHAR "*(" ESCAPE CHAR "*)*\""
#	NUMBER="-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?"
#	KEYWORD="null|false|true"
	SPACE="[[:space:]]+"

#        gsub(STRING "|" NUMBER "|" KEYWORD "|" SPACE "|.", "\n&", a1)
	gsub(/\"[^[:cntrl:]\"\\]*((\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})[^[:cntrl:]\"\\]*)*\"|-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?|null|false|true|[[:space:]]+|./, "\n&", a1)
        gsub("\n" SPACE, "\n", a1)
	sub(/^\n/, "", a1)
	ITOKENS=0 # get_token() helper
	return NTOKENS = split(a1, TOKENS, /\n/)
}
#}}}

# vim:fdm=marker:
