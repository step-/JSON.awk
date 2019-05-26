#!/bin/sh

print_result() {
	printf "\033[32m%s\033[0m\n" "$@"
}

for j in 1 true null '""' '[]' '{}'; do
	echo === "$j" ===
	echo "$j" > /tmp/in.json
	./with-gron.sh --show-stderr /tmp/in.json
	res=$?
	status=$(($res +${status:-0}))
	[ 0 = $res ] && print_result "PASS $j" || print_result "FAIL $j"
done

exit $status

