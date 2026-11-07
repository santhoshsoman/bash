# ~/.bashrc: Executed by bash(1) for non-login shells.

# ==============================================================================
# 1. SHELL CONFIGURATION & ENVIRONMENT
# ==============================================================================
# Set strict permissions for new files (rwxr-xr-x)
umask 022

# Use Vi mode for command line editing (Power user move)
set -o vi

# Set Locale to avoid weird character issues
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


# ==============================================================================
# 2. PATH MANAGEMENT
# ==============================================================================
# Helper function to cleanly add to PATH only if directory exists
# This prevents cluttering your PATH with broken links.
path_prepend() {
    if [ -d "$1" ]; then
        PATH="$1:$PATH"
    fi
}

# Default PATH setup (Priority: Local Bin > System > Scripts)
path_prepend "$HOME/santhoshsnair/scripts/sf"
path_prepend "$HOME/santhoshsnair/scripts/zb"
path_prepend "$HOME/santhoshsnair/scripts"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

export PATH

export DVC_SITE_CACHE_DIR="$HOME/.cache/dvc/site"
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SSN_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
if [[ "$SSN_ROOT" == "$HOME" && -d "$HOME/santhoshsnair" ]]; then
  SSN_ROOT="$HOME/santhoshsnair"
fi

export SSN_ROOT
export PATH="${SSN_ROOT}/scripts:${PATH}"
export VIMINIT="source ${SSN_ROOT}/.vimrc"

# ==============================================================================
# 1. INTERACTIVE CHECK
# ==============================================================================
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ==============================================================================
# 2. SHELL SETTINGS & HISTORY
# ==============================================================================
export EDITOR=vim
export TERM=xterm-256color

# Check window size after each command (good for resizing windows)
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ==============================================================================
# 3. EXTERNAL COMPLETIONS & GIT INTEGRATION
# ==============================================================================
# Load system bash completion first
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Load Git Completion (Priority to specific Google/Local versions)
if [ -f /usr/local/git/current/share/git-core/git-completion.bash ]; then
    . /usr/local/git/current/share/git-core/git-completion.bash
    . /usr/local/git/current/share/git-core/git-prompt.sh
elif [ -f /etc/bash_completion.d/git-prompt ]; then
    . /etc/bash_completion.d/git-prompt
fi

# Configure Git Prompt Behavior
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"

# Custom Git Status Function
function git_human_status {
    # 1. Get git directory. If not in a repo, exit.
    local GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
    [ -z "$GIT_DIR" ] && return

    # 2. Get Branch Name OR Commit Hash (Detached HEAD)
    local BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -z "$BRANCH" ]; then
        # If no branch name, we are in Detached HEAD. Get the short hash.
        BRANCH="DETACHED @ $(git rev-parse --short HEAD)"
    fi

    local STATUS=""

    # --- PART A: "Scary Modes" (Operation State) ---
    # check for specific files inside the .git folder that indicate an active operation
    if [ -d "$GIT_DIR/rebase-merge" ] || [ -d "$GIT_DIR/rebase-apply" ]; then
        STATUS="$STATUS | ⚠️ REBASING"
    elif [ -f "$GIT_DIR/MERGE_HEAD" ]; then
        STATUS="$STATUS | ⚠️ MERGING"
    elif [ -f "$GIT_DIR/CHERRY_PICK_HEAD" ]; then
        STATUS="$STATUS | 🍒 CHERRY-PICKING"
    elif [ -f "$GIT_DIR/BISECT_LOG" ]; then
        STATUS="$STATUS | 🔍 BISECTING"
    elif [ -f "$GIT_DIR/REVERT_HEAD" ]; then
        STATUS="$STATUS | ↩️ REVERTING"
    fi

    # --- PART B: File Status ---
    if ! git diff --quiet 2>/dev/null; then
        STATUS="$STATUS | 📝 MODIFIED"
    fi
    if ! git diff --cached --quiet 2>/dev/null; then
        STATUS="$STATUS | 📦 STAGED"
    fi
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        STATUS="$STATUS | ❓ NEW"
    fi
    if git rev-parse --verify refs/stash &>/dev/null; then
        STATUS="$STATUS | 📎 STASHED"
    fi

    # --- PART C: Upstream Status ---
    # Only check upstream if we are on a real branch (not detached)
    if [[ "$BRANCH" != "DETACHED"* ]]; then
        local COUNTS=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
        if [ -n "$COUNTS" ]; then
            read -r AHEAD BEHIND <<< "$COUNTS"
            if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
                STATUS="$STATUS | 🔀 DIVERGED"
            elif [ "$AHEAD" -gt 0 ]; then
                STATUS="$STATUS | ⬆ AHEAD $AHEAD"
            elif [ "$BEHIND" -gt 0 ]; then
                STATUS="$STATUS | ⬇ BEHIND $BEHIND"
            else
                # Optional: If you want to see "Synced", keep this. 
                # If you prefer silence when everything is clean, remove this line.
                STATUS="$STATUS | ✔ SYNCED"
            fi
        else
             STATUS="$STATUS | 🚫 NO REMOTE"
        fi
    fi

    # Output final string
    printf " (%s%s)" "$BRANCH" "$STATUS"
}

# ==============================================================================
# 4. THE PROMPT (PS1)
# ==============================================================================
# Define Colors for the prompt
# Define Colors for the prompt
PS_RESET="\[\033[0m\]"
PS_BOLD="\[\033[1m\]"
PS_YELLOW="\[\033[01;33m\]"   # Time
PS_CYAN="\[\033[38;5;36m\]"   # Mac Color
PS_BLUE="\[\033[38;5;39m\]"   # Google Color
PS_LAB="\[\033[0;94m\]"       # Lab Color

# Detect Host and assign color
HOSTNAME_FULL=$(hostname)
if [[ "$HOSTNAME_FULL" == *"santhoshsnair-mac"* ]]; then
    HOST_COLOR=$PS_CYAN
elif [[ "$HOSTNAME_FULL" == *"santhoshsnair.c.googlers.com"* ]]; then
    HOST_COLOR=$PS_BLUE
else
    HOST_COLOR=$PS_LAB
fi

# Construct the Prompt
# Format: [Date - Time] Path (Git Branch)
#         User@Host$ 
PS1="${HOST_COLOR}[\d - \@] \w${PS_RESET}${PS_YELLOW}\$(git_human_status)${PS_RESET}\n${HOST_COLOR}\u@\h${PS_RESET}$ "

# Handle chroot indication if present
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
    PS1="${debian_chroot:+($debian_chroot)}$PS1"
fi

# ==============================================================================
# 5. ALIASES & FUNCTIONS
# ==============================================================================
# Alert alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history 1|sed '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias sss='unalias -a; unset _SSN_COMMON_SH_LOADED _SSN_SF_COMMON_SH_LOADED; [ -f "$HOME/santhoshsnair/.bashrc" ] && source "$HOME/santhoshsnair/.bashrc" || source "$HOME/.bashrc"'

[ -f "${SSN_ROOT}/.bash_aliases" ] && . "${SSN_ROOT}/.bash_aliases"
[ -f "${SSN_ROOT}/.aliases" ]      && . "${SSN_ROOT}/.aliases"
[ -f "${SSN_ROOT}/.sf_aliases" ]   && . "${SSN_ROOT}/.sf_aliases"

# ==============================================================================
# 6. MACOS / DARWIN SPECIFIC CONFIGURATION
# ==============================================================================
if [[ "$(uname -s)" == "Darwin" ]]; then
    
    # --- Pyenv Configuration ---
    export PYENV_ROOT="$HOME/.pyenv"
    if [[ -d "$PYENV_ROOT" ]]; then
        [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
        if command -v pyenv 1>/dev/null 2>&1; then
            eval "$(pyenv init -)"
            eval "$(pyenv virtualenv-init -)"
        fi
    fi

    # --- Homebrew Configuration ---
    # Cleaner way to add Homebrew without temporary variables
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
        export MANPATH="/opt/homebrew/share/man:$MANPATH"
    fi
fi

# Kill fix-port on login if it's running or enabled
if [[ "$(uname -s)" != "Darwin" ]]; then
    if systemctl --user is-active --quiet fix-port.path || systemctl --user is-enabled --quiet fix-port.path; then
	systemctl --user disable --now fix-port.path
    fi
fi

# Added by Jetski
alias jetski='/google/bin/releases/jetski-devs/tools/cli'
