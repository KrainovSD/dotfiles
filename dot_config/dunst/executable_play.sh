#!/usr/bin/env bash

app=$(echo "$1" | tr '[:upper:]' '[:lower:]')
summary=$(echo "$2" | tr '[:upper:]' '[:lower:]')
urgency=$(echo "$5" | tr '[:upper:]' '[:lower:]')

SOUND_DIR="/usr/share/sounds/freedesktop/stereo"

RULES=(
    "spotify" "" "" "IGNORE"
    "telegram|discord|whatsapp|signal" "call|звонок" "" "phone-incoming-call.oga"
    "telegram|discord|webcord|whatsapp|signal" "" "" "message-new-instant.oga"
    "thunderbird|geary|evolution|mail|outlook" "" "" "message.oga"
    "" "error|ошибка|fail|failed|critical" "" "dialog-warning.oga"
    "" "battery|batareya|заряд|разряд" "normal" "power-unplug.oga"
    "" "complete|finished|готово|завершено" "" "complete.oga"
    "" "" "critical" "bell.oga"
    "" "" "" "dialog-information.oga"
)

check_rule() {
    local rule_app="$1"
    local rule_summary="$2"
    local rule_urgency="$3"

    if [[ -n "$rule_app" ]] && [[ ! "$app" =~ $rule_app ]]; then
        return 1
    fi

    if [[ -n "$rule_summary" ]] && [[ ! "$summary" =~ $rule_summary ]]; then
        return 1
    fi

    if [[ -n "$rule_urgency" ]] && [[ "$urgency" != "$rule_urgency" ]]; then
        return 1
    fi

    return 0
}

sound=""

for ((i = 0; i < ${#RULES[@]}; i += 4)); do
    rule_app="${RULES[i]}"
    rule_summary="${RULES[i + 1]}"
    rule_urgency="${RULES[i + 2]}"
    rule_sound="${RULES[i + 3]}"

    if check_rule "$rule_app" "$rule_summary" "$rule_urgency"; then
        sound="$rule_sound"
        break
    fi
done

if [[ "$sound" == "IGNORE" ]]; then
    exit 0
fi

if [[ -f "$SOUND_DIR/$sound" ]]; then
    pw-play "$SOUND_DIR/$sound" >/dev/null 2>&1 &
else
    pw-play "$SOUND_DIR/dialog-information.oga" >/dev/null 2>&1 &
fi
