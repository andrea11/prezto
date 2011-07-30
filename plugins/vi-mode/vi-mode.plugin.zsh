# ------------------------------------------------------------------------------
#          FILE:  vi-mode.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Sorin Ionescu <sorin.ionescu@gmail.com>
#       VERSION:  1.0.3
# ------------------------------------------------------------------------------


# Allow command line editing in an external editor.
autoload -Uz edit-command-line

# If mode indicator wasn't setup by theme, define a default.
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%B%F{red}<%f%b%F{red}<<%f"
fi

# If I am using vi keys, I want to know what mode I'm currently using.
# zle-keymap-select is executed every time KEYMAP changes.
# From http://zshwiki.org/home/examples/zlewidgets
function zle-line-init zle-keymap-select {
  if [[ "$KEYMAP" == 'vicmd' ]]; then
    rprompt_cached="$RPROMPT"
    RPROMPT="$MODE_INDICATOR"
  elif [[ -n "$rprompt_cached" ]]; then
    RPROMPT="$rprompt_cached"
    rprompt_cached=""
  fi
  zle reset-prompt
}

# Accept RETURN in vi command mode.
function accept_line {
  if [[ -n "$rprompt_cached" ]]; then
    RPROMPT="$rprompt_cached"
    rprompt_cached=""
  fi
  builtin zle .accept-line
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N accept_line
zle -N edit-command-line

# Avoid binding ^J, ^M,  ^C, ^?, ^S, ^Q, etc.
bindkey -d # Reset to default.
bindkey -v # Use vi key bindings.
bindkey -M vicmd "^M" accept_line # Alow RETURN in vi command.
bindkey -M vicmd v edit-command-line # ESC-v to edit in an external editor.

bindkey ' ' magic-space
bindkey -M vicmd "gg" beginning-of-history
bindkey -M vicmd "G" end-of-history

# Bind to history substring search plugin if enabled;
# otherwise, bind to built-in ZSH history search.
if (( $+plugins[(er)history-substring-search] )); then
  bindkey -M vicmd "k" history-substring-search-up
  bindkey -M vicmd "j" history-substring-search-down
else
  bindkey -M vicmd "k" history-search-backward
  bindkey -M vicmd "j" history-search-forward
fi

bindkey "^P"          up-line-or-search
bindkey -M vicmd "k"  up-line-or-search
bindkey -M vicmd "^k" up-line-or-search
bindkey -M viins "^k" up-line-or-search
bindkey "^N"          down-line-or-search
bindkey -M vicmd "j"  down-line-or-search
bindkey -M vicmd "^j" down-line-or-search
bindkey -M viins "^j" down-line-or-search

bindkey -M viins '^r' history-incremental-pattern-search-backward
bindkey -M viins '^f' history-incremental-pattern-search-forward
bindkey -M vicmd "?"  history-incremental-pattern-search-backward
bindkey -M vicmd "/"  history-incremental-pattern-search-forward

bindkey -M vicmd "^l" clear-screen
bindkey -M viins "^l" clear-screen

bindkey -M vicmd "^w" backward-kill-word
bindkey -M viins "^w" backward-kill-word

bindkey -M vicmd "^a" beginning-of-line
bindkey -M viins "^a" beginning-of-line

bindkey -M vicmd "^e" end-of-line
bindkey -M viins "^e" end-of-line

bindkey -M vicmd '^d' delete
bindkey -M viins '^d' delete

bindkey -M vicmd '^?' backward-delete-char
bindkey -M viins '^?' backward-delete-char

# 'jj' = ESC
bindkey -M viins 'jj' vi-cmd-mode

if (( ${+functions[rationalize-dot]} )); then
  bindkey -M viins '.' rationalize-dot
  bindkey -M isearch . self-insert 2>/dev/null
fi
