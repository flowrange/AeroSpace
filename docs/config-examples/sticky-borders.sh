#!/bin/zsh
# Synchronize JankyBorders with this build's window-is-sticky format variable.
# Call after changing sticky/floating/tiling mode and from on-focus-changed.
# Run with "reset" to restore normal colors before removing the integration.
emulate -LR zsh
setopt errexit nounset pipefail
umask 077

normal_active=0xff5ea567
normal_inactive=0xff494d64
sticky_active=0xffffb454
sticky_inactive=0xffb87a32

aerospace=${AEROSPACE_BIN:-aerospace}
borders=${BORDERS_BIN:-borders}
cache_dir=${XDG_CACHE_HOME:-$HOME/Library/Caches}/aerospace-sticky-borders
action=${1:-sync}
if [[ $action != sync && $action != reset ]]; then
    print -u2 'Usage: sticky-borders.sh [sync|reset]'
    exit 2
fi

# Do not accidentally launch another daemon when Borders is stopped.
/usr/bin/pgrep -u "$UID" -x borders >/dev/null || exit 0

mkdir -p "$cache_dir"
: >> "$cache_dir/lock"
zmodload zsh/system
# Serialize rapid focus/layout events; query the current state after locking.
zsystem flock -t 5 -i 0.02 -f lock_fd "$cache_dir/lock" || exit 1

snapshot=$("$aerospace" list-windows --all --format '%{window-id}|%{window-is-sticky}')
typeset -A previous
typeset -a marked
if [[ -f $cache_dir/marked ]]; then
    while IFS= read -r window_id; do
        [[ $window_id == <-> ]] && previous[$window_id]=1
    done < "$cache_dir/marked"
fi

while IFS='|' read -r window_id sticky; do
    [[ $window_id == <-> ]] || continue
    if [[ $sticky == true && $action == sync ]]; then
        # Reapply on focus changes, including after Borders recreates a border.
        "$borders" "apply-to=$window_id" \
            "active_color=$sticky_active" "inactive_color=$sticky_inactive"
        marked+=("$window_id")
    elif [[ $sticky == true || ${previous[$window_id]:-0} == 1 ]]; then
        "$borders" "apply-to=$window_id" \
            "active_color=$normal_active" "inactive_color=$normal_inactive"
    fi
done <<< "$snapshot"

# Drop closed windows from the cache so reused system IDs are not styled later.
if (( ${#marked} )); then
    print -rl -- "${marked[@]}" > "$cache_dir/marked"
else
    : > "$cache_dir/marked"
fi
