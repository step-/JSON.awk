# Callbacks reserved for awk programs that embed JSON.awk.
# Mawk must always define all callbacks, see note #2 of doc/embed.md.
# Gawk and busybox awk must define callbacks when STREAM=1 only.
# For callback purpose, see FAQ.md#5.

# cb_jpaths - call back for processing jpath
# Called in JSON.awk's main loop when STREAM=0 only.
# This example illustrates printing jpaths to stdout,
# much like JSON.awk does when STREAM=1.
function cb_jpaths (ary, size,   i) {

	# Print ary - array of size jpaths.
	for(i=1; i <= size; i++) {
		print "cb_jpaths", ary[i]
	}
}

# cb_fails - call back for processing all error messages at once after parsing
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

# cb_fail1 - call back for processing a single parse error as soon as it is
# encountered.  Called in JSON.awk's main loop when STREAM=0 only.
# Return non-zero to let JSON.awk also print the message to stderr.
# This example illustrates printing the error message to stdout only.
function cb_fail1 (message) {

	print "cb_fail1: invalid input file:", FILENAME
	print message
}

