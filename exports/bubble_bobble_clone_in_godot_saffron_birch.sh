#!/bin/sh
printf '\033c\033]0;%s\a' bubble_bobble_clone_in_godot_saffron_birch
base_path="$(dirname "$(realpath "$0")")"
"$base_path/bubble_bobble_clone_in_godot_saffron_birch.x86_64" "$@"
