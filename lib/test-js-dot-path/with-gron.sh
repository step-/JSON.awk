#!/bin/bash

die () { echo "$@" >&2; exit 1; }

json_awk () {
	awk -v _JS_VAR_VAR=null -f ../js-dot-path.awk -f ../../JSON.awk -v STREAM=0 "$@"
}

REDIR=/dev/null

case $1 in
	--show-stderr ) shift; REDIR=/dev/stderr ;;
esac

! [ -f "$1" ] && die "usage: ${BASH_SOURCE##*/} [--show-stderr] JSON_FILE"

gron --no-sort "$@" | sort > /tmp/gron.out

json_awk "$@" 2> $REDIR | sort > /tmp/json_awk.out

diff -y /tmp/{gron,json_awk}.out
status=$?

#meld /tmp/{gron,json_awk}.out &

[ 0 != ${PIPESTATUS[0]} ] && less "$@"

exit $status

