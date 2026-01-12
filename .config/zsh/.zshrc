# Looking to get something done in zsh? Have a look at:
#       man zshall and ofcourse:
#       http://zsh.sourceforge.net/Guide/zshguide.html
# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# Load the aliases (disabled)
source "$XDG_CONFIG_HOME/shell/aliasrc"

HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=$XDG_CACHE_HOME/zsh/history

setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.

# Make cd push the old directory onto the directory stack.
setopt AUTO_PUSHD

# Remove percentage sign as EOL in STDOUT
setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=""

# Set case-insenitive TAB completion

autoload -U compinit; compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"

bindkey '\t' complete-word

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# remap C^a to C^o, because tmux uses C^a
bindkey -M viins '^O' beginning-of-line # vi specific
bindkey -M main '^O' beginning-of-line # emacs mode


#################
# Custom theme. Pure by Powerlevel10k.
#################

# defined in the left prompt in ./.p10k.zsh
prompt_workenv() {
    p10k segment -f "#EE82EE" -t "${WORKENV}"
}

source "$XDG_CONFIG_HOME/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.

[[ ! -f $XDG_CONFIG_HOME/zsh/.p10k.zsh ]] || source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"

#################
# VI mode in terminal
#################

# Set the timeout to a minimal 0.01s after hitting ESC to enter
export KEYTIMEOUT=1

source $XDG_CONFIG_HOME/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

#################
# CLI Plugins
#################
# Since the default initialization mode, this plugin will overwrite the previous key bindings, 
# this causes the key bindings of other plugins (i.e. fzf, zsh-autocomplete, etc.) to fail.

function _bindfzfkeys() {
    source /usr/share/fzf/key-bindings.zsh 
    source /usr/share/fzf/completion.zsh 
    bindkey '^F' fzf-file-widget 
    bindkey '^X^J' fzf-cd-widget  # j for jump
    # ~/.fzf.zsh or ~/.fzf.bash
    export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden'
    export FZF_ALT_C_COMMAND='fd --type d --hidden'
}

# Append a command directly after initting zsh-vi-mode.plugin
# bindkey <C-i> for completion in terminal commands

zvm_after_init_commands+=('_bindfzfkeys')


source $XDG_CONFIG_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

