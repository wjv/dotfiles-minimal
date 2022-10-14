# Minimal, portable .zshrc
#
# vim: fdm=marker fdc=1 nu et sw=2 tw=0


### Enviroment variables {{{

# Zsh-specific
HISTFILE="${HOME}/.history"
HISTSIZE=25000
SAVEHIST=25000
DIRSTACKSIZE=100
KEYTIMEOUT=1
LISTMAX=0
cdpath=(~)

# L10n
export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

# Editor and pager
export EDITOR=vim
export PAGER=less
export LESS='-MRq -z-2 -j2'

# BSD & GNU ls(1) colours
export CLICOLOR=true
export CLICOLOR_FORCE=true
if [[ -z $(whence -p dircolors) ]]; then
  export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"
else
  eval "$(dircolors -b)"
fi

# macOS
SHELL_SESSION_DISABLE=1
SHELL_SESSION_HISTORY=0

# }}}


### Prompt {{{

function zle-keymap-select {
  ZLE_VIMODE="${${KEYMAP/vicmd/%%}/(main|viins)/$}"
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  unset ZLE_VIMODE
  zle reset-prompt
}
zle -N zle-line-finish

export PROMPT=\
'%(1j.[%j] .)'\
$'%n@%m'\
$':%15<…<%~%<<'\
'%(!.#.${ZLE_VIMODE-$}) '

# }}}


### Functions and aliases {{{

realpath() { for f in "$@"; do echo ${f}(:A); done }
hgrep() { fc -Dlim "*$@*" 1 }

alias ls="ls --color=auto"
[[ $OSTYPE == darwin* ]] && alias top="top -ocpu -Otime"

# }}}


### Zsh options {{{

# Changing Directories
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_SILENT
setopt PUSHD_IGNORE_DUPS

# Completion
setopt AUTO_NAME_DIRS
setopt NO_LIST_BEEP
setopt LIST_ROWS_FIRST

# Expansion and Globbing
setopt BRACE_CCL
setopt EXTENDED_GLOB

# History
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS 
setopt HIST_VERIFY
unsetopt HIST_BEEP

# Input/Output
setopt INTERACTIVE_COMMENTS
setopt PRINT_EXIT_VALUE

# Job Control
unsetopt BG_NICE
unsetopt HUP

# Prompt
setopt TRANSIENT_RPROMPT
setopt PROMPT_SUBST

# ZLE
setopt NO_BEEP

# }}}


### ZLE completion  {{{

zstyle ':completion:*' completer _expand _complete

zstyle ':completion:*' auto-description 'specify %d (auto-description)'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' menu yes=long select=long select=2
zstyle ':completion:*' verbose yes

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' select-prompt '%S%M matches%s'

zstyle ':completion:*:complete:(cd|pushd):*' tag-order local-directories
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:expand:*' accept-exact continue
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:messages' format '%B%d%b'
zstyle ':completion:*:warnings' format '%Bno matches:%b %d'

zstyle ':completion:*:*:-command-:*' group-order builtins aliases functions
zstyle ':completion:*:*:-tilde-:*' group-order named-directories

zstyle ':completion:history-words:*' list no 
zstyle ':completion:history-words:*' menu yes
zstyle ':completion:history-words:*' remove-all-dups yes

zmodload -i zsh/complist
autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# }}}


### ZLE keybindings {{{

# Vi mode

bindkey -v
bindkey -M vicmd '^[' undefined-key

autoload -U select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# History

bindkey -M viins '^[.' insert-last-word

bindkey -M vicmd '^B' push-line-or-edit
bindkey -M viins '^B' push-line-or-edit

bindkey -M vicmd '^T' end-of-list
bindkey -M viins '^T' end-of-list

bindkey -M vicmd " " history-incremental-pattern-search-backward

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M vicmd '^[[A' up-line-or-beginning-search \
                 '^[OA' up-line-or-beginning-search \
                 '^[[B' down-line-or-beginning-search \
                 '^[OB' down-line-or-beginning-search
bindkey -M viins '^[[A' up-line-or-beginning-search \
                 '^[OA' up-line-or-beginning-search \
                 '^[[B' down-line-or-beginning-search \
                 '^[OB' down-line-or-beginning-search


# Completion

bindkey -M viins '^I' complete-word

bindkey -M menuselect '^O' accept-and-infer-next-history
bindkey -M menuselect '^U' undo

bindkey -M menuselect '^P' accept-and-menu-complete
bindkey -M menuselect '+' accept-and-menu-complete

bindkey -M menuselect 'q' send-break
bindkey -M menuselect '^[' send-break

bindkey -M menuselect '^[[Z' reverse-menu-complete

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '0' vi-beginning-of-line
bindkey -M menuselect '$' vi-end-of-line
bindkey -M menuselect '^F' vi-forward-word
bindkey -M menuselect '^B' vi-backward-word
bindkey -M menuselect '{' vi-backward-blank-word
bindkey -M menuselect '[' vi-backward-blank-word
bindkey -M menuselect '}' vi-forward-blank-word
bindkey -M menuselect ']' vi-forward-blank-word
bindkey -M menuselect 'gg' beginning-of-history
bindkey -M menuselect 'G' end-of-history

# }}}


### Generic config; cleanup and finish {{{

if [[ -d "${HELPDIR}" ]]; then
  unalias run-help
  autoload run-help
  alias help=run-help
fi

pathclean() {for p in $@; eval "$p=(\$^$p(-/N))"}
pathclean path cdpath fpath manpath pkg_config_path
unfunction pathclean
export -U path cdpath fpath manpath pkg_config_path

disable r
umask 077
stty crt erase \^\? kill \^U intr \^C

[[ -r .zshrc-local ]] && source .zshrc-local

# }}}
