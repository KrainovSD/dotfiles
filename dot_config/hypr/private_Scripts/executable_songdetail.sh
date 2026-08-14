#!/bin/bash

mapfile -t lines < <(playerctl --all-players metadata \
    --format $'{{status}}\t{{title}}\t{{artist}}' 2>/dev/null)

[[ ${#lines[@]} -eq 0 ]] && exit 0

pick=""
for l in "${lines[@]}"; do
    [[ "${l%%$'\t'*}" == "Playing" ]] && {
        pick="$l"
        break
    }
done
[[ -z "$pick" ]] && pick="${lines[0]}"

status="${pick%%$'\t'*}"
# comment for always display last media
[[ "$status" != "Playing" ]] && exit 0
rest="${pick#*$'\t'}"
title="${rest%%$'\t'*}"
artist="${rest#*$'\t'}"

[[ "$status" == "Playing" ]] && icon='▷' || icon='⏸'

if [[ -n "$artist" ]]; then
    echo "$icon $title ♪ $artist"
else
    echo "$icon $title"
fi
