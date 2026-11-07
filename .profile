# ~/.profile
# Executed by the command interpreter for login shells.

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
path_prepend "$HOME/santhoshsnair/scripts"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# ==============================================================================
# 3. OS-SPECIFIC CONFIGURATION (MacOS / Darwin)
# ==============================================================================
if [[ "$(uname -s)" == "Darwin" ]]; then

    # Python 3.8 (Mac)
    path_prepend "/Library/Frameworks/Python.framework/Versions/3.8/bin"

    # --- Completion Scripts ---
    # Homebrew Completion
    [ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
    # Internal Completion
    [ -f "/etc/bash_completion.d/hgd" ] && . "/etc/bash_completion.d/hgd"

    # --- SSH / Gnubby Agent ---
    # Wrapped in a function for safety. Checks if gnubby exists first.
    function start_gnubby_ssh_agent() {
        if ! command -v gnubby-ssh-agent &> /dev/null; then
            return # Exit if gnubby isn't installed
        fi

        # Only start if not already running
        if [ $(ps aux | grep -v grep | grep 'gnubby-ssh-agent -s' | wc -l) -eq 0 ]; then
             eval $(gnubby-ssh-agent -s)
        fi

        # Add keys if not already present (assuming 3 keys total is the target)
        if [ $(gnubby-ssh-add -l | wc -l) -ne 3 ]; then
            [ -f "${HOME}/.ssh/id_rsa" ] && ssh-add "${HOME}/.ssh/id_rsa"
            [ -f "${HOME}/.ssh/id_rsa_lab" ] && ssh-add "${HOME}/.ssh/id_rsa_lab"
        fi
    }

    start_gnubby_ssh_agent
fi

export PATH

# ==============================================================================
# 5. BASH HANDOFF
# ==============================================================================
# If running Bash, load the bashrc for interactive shell features
if [ -n "$BASH_VERSION" ]; then
    [ -f "${HOME}/santhoshsnair/.bashrc" ] && . "${HOME}/santhoshsnair/.bashrc"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
