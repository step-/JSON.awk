# Callbacks that translate JSON to javascript statements
# Mawk must always define all callbacks.
# Gawk and busybox awk must define callbacks when STREAM=1 only.
# More info in FAQ.md#5.

# Usage:
# awk -f lib/js-dot-path.awk -f JSON.awk -v STREAM=0 [JS_CONTAINER] FILE.json...
# JS_CONTAINER: -v _JS_VAR="json" [-v _JS_VAR_VAR="file"]

#-------------------------------- START / END ----------------------------------

# _JS_VAR: name of the javascript root container variable. Default: `json'.
# _JS_VAR_VAR : name of an array in `json'. Default: `file'. Each element of
# `file' corresponds to an input JSON file. Setting _JS_VAR_VAR = "null" omits
# `file' therefore `json' ends up holding javascript for all input files.
BEGIN {
	if (0 == STREAM) {

		# Default javascript container variable
		if ("" == _JS_VAR) { _JS_VAR = "json" }
		if ("" == _JS_VAR_VAR) {
			_JS_VAR_VAR = "file"
		} else if ("null" == _JS_VAR_VAR) {
			_JS_VAR_VAR = ""
		}

		printf "%s", get_js_container()

		# Make parse() send us  "", [] and {}
		BRIEF = 7
	}
}

END {
	if (0 == STREAM)
		exit(STATUS) # set in cb_fail1
}

#---------------------------------- HELPERS ------------------------------------

# stash_js_code - insert javascript code into output stream
function stash_js_code(key, code) {
	_JS_CODE[key] = _JS_CODE[key] code
}

# print_js_code - print inserted javascript code
function print_js_code(key) {
	if (key in _JS_CODE) {
		printf "%s", _JS_CODE[key]
		delete _JS_CODE[key]
	}
}

# print_js_dot_path - print javascript dot path
function print_js_dot_path(path) {
	if (! index(path, "[empty]") && ! index(path, "{empty}"))
		print path
}

# get_jpath_fmt - return main javascript container variable to start a jpath
function get_jpath_fmt() {
	if("" == _JS_VAR_VAR)
		return sprintf("%s%%s", _JS_VAR)
	return sprintf("%s.%s[%d]%%s", _JS_VAR, _JS_VAR_VAR, FILEINDEX - 1)
}

# get_js_container - return root javascript container variable to begin output
function get_js_container() {
	if ("" == _JS_VAR_VAR)
		return ""
	return sprintf("%s\n%s\n", _JS_VAR " = {};", _JS_VAR "." _JS_VAR_VAR " = [];")
}

#--------------------------------- CALLBACKS -----------------------------------

# cb_parse_array_empty - parse an empty JSON array.
# Called in JSON.awk's main loop when STREAM=0 only.
# This example returns a unique symbol for an empty array.
function cb_parse_array_empty(jpath) {

#	print "parse_array_empty("jpath")" >"/dev/stderr"
	return "[empty]"
}

# cb_parse_object_empty - parse an empty JSON object.
# Called in JSON.awk's main loop when STREAM=0 only.
# This example returns a unique symbol for an empty object.
function cb_parse_object_empty(jpath) {

#	print "parse_object_empty("jpath")" >"/dev/stderr"
	return "{empty}"
}

# cb_parse_array_enter - begin parsing an array.
# Called in JSON.awk's main loop when STREAM=0 only.
# This example outputs javascript initialization code for an array variable.
function cb_parse_array_enter(jpath) {

#	print "cb_parse_array_enter("jpath") token("TOKEN")" >"/dev/stderr"
	stash_js_code(NJPATHS + 1, jpath" = [];\n")
}

# cb_parse_array_exit - end parsing an array.
# Called in JSON.awk's main loop when STREAM=0 only.
# If status == 0 then global CB_VALUE holds the JSON text of the parsed array.
function cb_parse_array_exit(jpath, status) {

#	print "cb_parse_array_exit("jpath") status("status") token("TOKEN") value("CB_VALUE")" >"/dev/stderr"
}

# cb_parse_object_enter - begin parsing an object.
# Called in JSON.awk's main loop when STREAM=0 only.
# This example outputs javascript initialization code for an object.
function cb_parse_object_enter(jpath) {

#	print "cb_parse_object_enter("jpath") token("TOKEN")" >"/dev/stderr"
	stash_js_code(NJPATHS + 1, jpath" = {};\n")
}

# cb_parse_object_exit - end parsing an object.
# Called in JSON.awk's main loop when STREAM=0 only.
# If status == 0 then global CB_VALUE holds the JSON text of the parsed object.
function cb_parse_object_exit(jpath, status) {

#	print "cb_parse_object_exit("jpath") status("status") token("TOKEN") value("CB_VALUE")" >"/dev/stderr"
}

# cb_append_jpath_component - format jpath components
# Called in JSON.awk's main loop when STREAM=0 only.
# This example formats jpaths as javascript dot paths including array indices.
function cb_append_jpath_component (jpath, component,   sep) {

	# A null component marks the beginning of the JSON text stream
	if ("" == component) {

		# Insert _JS_VAR/_JS_VAR_VAR
		return sprintf(get_jpath_fmt(), "")

	} else if (component ~ /^[[:digit:]]+$/) {

		# Rewrite JSON integer as javascript array `[integer]'
		return jpath "[" component "]"

	} else if (component ~ /^"[$_[:alnum:]][_[:alnum:]]*"$/) {

		# Rewrite JSON string as a dotted javascript identifier.
		# We enter here only if the string is a valid javascript
		# identifier. Strip exterior quotes.
		component = substr(component, 2, length(component) - 2)
		return jpath "." component

	} else {

		# JSON string with invalid characters. Rewrite it as an element of a
		# javascript array.
		return jpath "[" component "]"
	}
}

# cb_append_jpath_value - format a jpath / value pair
# Called in JSON.awk's main loop when STREAM=0 only.
# This example formats the jpath / value pair as a javascript assignment.
function cb_append_jpath_value (jpath, value) {

#	print "cb_append_jpath_value("jpath") ("jpath") value("value")" >"/dev/stderr"
	return sprintf("%s = %s;", jpath, value)
}

# cb_jpaths - process cb_append_jpath_value outputs
# Called in JSON.awk's main loop when STREAM=0 only.
# This example illustrates printing jpaths to stdout formatted as elements of
# javascript array _JS_VAR,
# See also cb_parse_array_enter and cb_parse_object_enter.
function cb_jpaths (ary, size,   i, type, p, q, d, s) {

	# Print ary - array of size jpaths and their values.
	for(i = 1; i <= size; i++) {
		print_js_code(i)
		print_js_dot_path(ary[i])
	}
}

# cb_fails - process all error messages at once after parsing
# has completed. Called in JSON.awk's END action when STREAM=0 only.
# This example illustrates printing parsing errors to stdout,
function cb_fails (ary, size,   k) {

	# Print ary - associative array of parsing failures.
	# ary's keys are the size input file names that JSON.awk read.
	for(k in ary) {
		print "cb_fails: invalid input file:", k
		print FAILS[k]
	}
}

# cb_fail1 - process a single parse error as soon as it is
# encountered.  Called in JSON.awk's main loop when STREAM=0 only.
# Return non-zero to let JSON.awk also print the message to stderr.
# This example illustrates printing the error message to stdout only.
function cb_fail1 (message) {

	print "cb_fail1: invalid input file:", FILENAME
	print message
	STATUS = 1
}

