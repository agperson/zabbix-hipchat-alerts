#!/bin/bash

to="$1"
subject="$2"
body="$3"

line=( $subject )
status="${line[0]}" # first element
severity="${line[${#line[@]}-1]}" # last element
name="${line[@]:1:${#line[@]}-2}" # in between

if [[ "$status" == "PROBLEM:" ]]; then
	case $severity in
		'(Warning)'  ) color="yellow" ;;
		'(Average)'  ) color="purple" ;;
		'(High)'     ) color="red"    ;;
		'(Disaster)' ) color="red"    ;;
		*            ) color="gray"   ;;
	esac
	./hipchat/notify.rb --color $color --notify --message "<strong>$status $name</strong> $severity<br>$body"
else
	./hipchat/notify.rb --color green --message "<strong>$status $name</strong> $severity<br>$body"
fi
