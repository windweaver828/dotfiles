# ~/.ssh/agent-init.sh
# Shared fixed-socket ssh-agent for CLI/tmux/server sessions.
#
# Source from interactive shells before tmux autostart.
#
# This intentionally uses a stable socket:
#   ~/.ssh/agent.sock
#
# It does not add keys at login. SSH adds keys on first use via:
#   AddKeysToAgent 8h

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

command -v ssh-agent >/dev/null 2>&1 || return 0 2>/dev/null || exit 0
command -v ssh-add >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

: "${WW_SSH_AGENT_LIFETIME:=8h}"
: "${WW_SSH_AUTH_SOCK:=$HOME/.ssh/agent.sock}"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

export SSH_AUTH_SOCK="$WW_SSH_AUTH_SOCK"

# Reuse existing fixed-socket agent if it is alive.
if [ -S "$SSH_AUTH_SOCK" ]; then
  ssh-add -l >/dev/null 2>&1
  rc=$?

  # 0 = alive with identities
  # 1 = alive but no identities
  if [ "$rc" -eq 0 ] || [ "$rc" -eq 1 ]; then
    unset rc
    return 0 2>/dev/null || exit 0
  fi

  unset rc
  rm -f "$SSH_AUTH_SOCK"
fi

# Start fixed-socket agent with default key lifetime.
ssh-agent -a "$SSH_AUTH_SOCK" -t "$WW_SSH_AGENT_LIFETIME" >/dev/null
