# Zsh port of the bash git_prompt (create_prompt).
# Faithful two-line prompt with git-status counts. Colors are wrapped in
# %{...%} so zsh measures prompt width correctly (line editing/wrapping).

# Colors (pre-wrapped for use inside PROMPT)
NOC=$'%{\e[0m%}'
WHITE=$'%{\e[1m%}'
GREY=$'%{\e[2m%}'
RED=$'%{\e[31m%}'
GREEN=$'%{\e[32m%}'
YELOW=$'%{\e[33m%}'
AZURE=$'%{\e[36m%}'
HRED=$'%{\e[91m%}'
HGREEN=$'%{\e[92m%}'
HYELOW=$'%{\e[93m%}'
HBLUE=$'%{\e[94m%}'

create_prompt() {
    local gitpart="" GIT_DATA=""

    if [[ "$(git config --get prompt.hide)" != "true" ]]; then
        GIT_DATA=$(git status -b --porcelain 2>/dev/null)
    else
        git rev-parse --is-inside-work-tree >/dev/null 2>&1 && gitpart="${GREEN}(GIT: prompt.hide = true) "
    fi

    if [[ -n "$GIT_DATA" ]]; then
        local SYMBOL_AHEAD=$'⬆ ' SYMBOL_BEHIND=$'⬇ '
        local SYMBOL_STASHED="S: " SYMBOL_MODIFIED="M: " SYMBOL_DELETED="D: "
        local SYMBOL_STAGED="S: " SYMBOL_UNTRACKED="U: "
        local SYMBOL_CONFLICTED=$'❎ ' SYMBOL_UNCOUNTED=$'❕ '

        local -a glines
        glines=("${(@f)GIT_DATA}")
        local FIRST_LINE="${glines[1]}"

        local stash
        stash=$(git stash list 2>/dev/null | wc -l | tr -d ' ')

        local status_str
        status_str=$(print -r -- "$FIRST_LINE" | grep -oE "\[.*\]")

        local rstat="" num
        if print -r -- "$status_str" | grep -q 'ahead'; then
            num=$(print -r -- "$status_str" | grep -oE "ahead [0-9]+" | grep -oE "[0-9]+")
            rstat="$rstat ${HYELOW}${SYMBOL_AHEAD}${HRED}${num}${GREEN}"
        fi
        if print -r -- "$status_str" | grep -q 'behind'; then
            num=$(print -r -- "$status_str" | grep -oE "behind [0-9]+" | grep -oE "[0-9]+")
            rstat="$rstat ${HYELOW}${SYMBOL_BEHIND}${HRED}${num}${GREEN}"
        fi

        local modified=0 deleted=0 staged=0 untracked=0 conflicts=0 uncounted=0
        local -a CONFLICT_CODES=(DD AU UD UA DU AA UU)
        local i L STAT X Y uncountedRow
        for (( i = 2; i <= ${#glines}; i++ )); do
            L="${glines[i]}"
            STAT="${L[1,2]}"
            X="${STAT[1]}"; Y="${STAT[2]}"
            if [[ "$STAT" == "??" ]]; then ((untracked++)); continue; fi
            if (( ${CONFLICT_CODES[(Ie)$STAT]} )); then ((conflicts++)); continue; fi
            uncountedRow=1
            if [[ "$Y" == "D" ]]; then ((deleted++)); uncountedRow=0
            elif [[ "$Y" == "M" ]]; then ((modified++)); uncountedRow=0; fi
            if [[ "$X" != " " ]]; then ((staged++)); uncountedRow=0; fi
            (( uncountedRow )) && ((uncounted++))
        done

        (( modified  > 0 )) && modified="${HRED}${modified}${GREEN}"  || modified="${NOC}${modified}${GREEN}"
        (( staged    > 0 )) && staged="${RED}${staged}${GREEN}"       || staged="${NOC}${staged}${GREEN}"
        (( deleted   > 0 )) && deleted="${HRED}${deleted}${GREEN}"    || deleted="${NOC}${deleted}${GREEN}"
        (( untracked > 0 )) && untracked=" ${GREEN}${SYMBOL_UNTRACKED}${YELOW}${untracked}${GREEN}" || untracked=""
        (( conflicts > 0 )) && conflicts=" ${RED}${SYMBOL_CONFLICTED}${RED}${conflicts}${GREEN}"    || conflicts=""
        (( uncounted > 0 )) && uncounted=" ${YELOW}${SYMBOL_UNCOUNTED}${uncounted}${GREEN}"         || uncounted=""
        (( stash     > 0 )) && stash=" ${AZURE}${SYMBOL_STASHED}${RED}${stash}${GREEN}"             || stash=""

        local repoR repo
        repoR=$(print -r -- "$FIRST_LINE" | sed -e 's/## \(.*\)\.\.\..*/\1/g')
        repo=$(print -r -- "$repoR" | sed -e 's/^## //g')
        repo="${HBLUE}${repo}"
        if print -r -- "$repoR" | grep -q '^##'; then
            repo="${RED}LB ${repo}"
        fi
        gitpart="${GREEN}(GIT: ${repo}${GREEN} | ${SYMBOL_MODIFIED}${modified} ${SYMBOL_DELETED}${deleted} ${SYMBOL_STAGED}${staged}${untracked}${conflicts}${uncounted}${stash}${rstat}) "
    fi

    local COLORPS
    if [[ "$USER" == "root" ]]; then COLORPS="${NOC}${HRED}"; else COLORPS="${NOC}"; fi

    local venv_part=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv_part="-[${HRED}$(basename "$VIRTUAL_ENV")${NOC}${HGREEN}]"
    fi

    PROMPT=$'\n'"${WHITE}${HGREEN}%m${NOC}${HGREEN}[${COLORPS}%n${NOC}${HGREEN}](${NOC}${GREY}%D{%T}${NOC}${HGREEN})${venv_part}-(${COLORPS}%~${NOC}${HGREEN})"$'\n'"${gitpart}${COLORPS}->${NOC} "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd create_prompt
