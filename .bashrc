# ~/.bashrc
#
# Minimal interactive Bash config.
# No framework, no plugin manager, no external prompt dependency.

# Return immediately for non-interactive shells.
case $- in
*i*) ;;
*) return ;;
esac

# ------------------------------------------------------------
# History
# ------------------------------------------------------------

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist

# PATH
# ------------------------------------------------------------

[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/go/bin" ] && PATH="$PATH:$HOME/go/bin"

export PATH

# ------------------------------------------------------------
# Locale
# ------------------------------------------------------------

# Do not force LC_ALL by default. It can cause warnings on minimal systems
# if the locale is not generated.
export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

# ------------------------------------------------------------
# Editor
# ------------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
  alias vim="nvim"
  alias vi="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
  export VISUAL="vim"
  alias vi="vim"
elif command -v vi >/dev/null 2>&1; then
  export EDITOR="vi"
  export VISUAL="vi"
else
  export EDITOR="nano"
  export VISUAL="nano"
fi

# ------------------------------------------------------------
# Aliases and custom commands
# ------------------------------------------------------------

gcmp() {
  local dot=false
  local message=""
  for arg in "$@"; do
    case "${arg}" in
    -dot)
      dot=true
      ;;
    *)
      message+="${arg} "
      ;;
    esac
  done
  if ${dot}; then
    gitcmd=dot
  else
    gitcmd=git
  fi
  if [[ -n ${message} ]]; then
    message="${message% }"
  else
    echo -n "Commit message: "
    read message
  fi
  if [[ -n $(${gitcmd} rev-parse --is-inside-work-tree) ]]; then
    ${gitcmd} commit --allow-empty-message -am "${message}" && ${gitcmd} push
  fi
}

# Config alias/function for dotfiles repo, home files git repo
dot() {
  GIT_DIR=$HOME/.dot/.git/ GIT_WORK_TREE=$HOME /usr/bin/git "$@"
}
dotcmp() {
  gcmp -dot "$@"
}

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain --pager=never'
  alias less='bat --style=plain'
  PAGER="${PAGER:-bat --style=plain}"
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --style=plain --pager=never'
  alias less='batcat --style=plain'
  PAGER="${PAGER:-batcat --style=plain}"
fi

# ls / directory listing
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd --group-dirs=first --date=relative --size=short -g'
  alias tree='ls --tree'
else
  alias ls='ls --color=auto'
  alias tree="ls -AR"
fi

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias celar=clear
alias df='df -h'
alias diff='diff --color=auto'
alias du='du -hs'
alias free='free -m'
alias gcam='git commit --all --message'
alias gcm=gcam
alias gitcmp=gcmp
alias grep="grep --color=auto"
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias lla='ls -lha'
alias lsa='ls -lah'
alias psc="ps -A | grep"
alias sl=ls
alias xclip='xclip -selection clipboard'

# ------------------------------------------------------------
# Bash completions and prompt - ORDER MATTERS HERE
# ------------------------------------------------------------

# ORDER 1 - Main completions

# Make sure programmable completion is enabled.
shopt -s progcomp

if [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# ORDER 2 - Set up fzf key bindings and fuzzy completions
command -v fzf >/dev/null && source <(fzf --bash)

# ORDER 3 - Setup Prompt
__ww_git_info() {
  command -v git >/dev/null 2>&1 || return 0
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local green="$1"
  local red="$2"
  local reset="$3"

  local branch
  local dirty=""

  branch="$(git branch --show-current 2>/dev/null)"

  if [ -z "$branch" ]; then
    branch="$(git rev-parse --short HEAD 2>/dev/null)"
  fi

  [ -n "$branch" ] || return 0

  # Mark dirty for tracked/staged changes.
  # This ignores untracked files, similar to DISABLE_UNTRACKED_FILES_DIRTY.
  if ! git diff --quiet --ignore-submodules -- 2>/dev/null ||
    ! git diff --cached --quiet --ignore-submodules -- 2>/dev/null; then
    dirty="${red}*${green}"
  fi

  printf " %s<%s%s>%s" "$green" "$branch" "$dirty" "$reset"
}

__ww_prompt() {
  local exit_code="${1:-$?}"

  local reset="\[\033[0m\]"
  local red="\[\033[38;5;160m\]"
  local yellow="\[\033[38;5;226m\]"
  local cyan="\[\033[38;5;45m\]"
  local blue="\[\033[38;5;69m\]"
  local purple="\[\033[38;5;165m\]"
  local green="\[\033[38;5;40m\]"

  # Disable color when stdout is not a terminal.
  if [ ! -t 1 ]; then
    reset=""
    red=""
    yellow=""
    cyan=""
    blue=""
    purple=""
    green=""
  fi

  local name_color="$yellow"
  local dollar_color="$red"

  # Make root extra obvious.
  if [ "$(id -u)" -eq 0 ]; then
    name_color="$red"
  fi

  local status=""
  if [ "$exit_code" -ne 0 ]; then
    status=" ${red}${exit_code}${reset}"
  fi

  local git_info
  git_info="$(__ww_git_info "$green" "$red" "$reset")"

  PS1="╭─${name_color}\u${reset}${cyan}@${blue}\h${reset} ${purple}\w${reset}${git_info}${status}\n╰─${red}\\\$${reset} "
}

__ww_prompt_command() {
  local exit_code="$?"

  # Save history after each command and reload newly written history.
  # Helps when using multiple terminals/tmux panes.
  history -a
  history -n

  __ww_prompt "$exit_code"
}

PROMPT_COMMAND="__ww_prompt_command"

# ------------------------------------------------------------
# Auto-start tmux - Leave near bottom ideally
# ------------------------------------------------------------

if command -v tmux >/dev/null 2>&1 &&
  [ -z "${TMUX:-}" ] &&
  [ -z "${WW_NO_TMUX:-}" ] &&
  [ -t 0 ] &&
  [ -t 1 ]; then
  exec tmux new-session -A -s main
fi
