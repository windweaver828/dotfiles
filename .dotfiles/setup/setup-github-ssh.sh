#!/usr/bin/env bash
set -euo pipefail

# setup-github-ssh.sh
#
# Idempotently sets up a GitHub-specific SSH key and SSH config entry.
# Safe for a public dotfiles repo: this script contains no secrets and only
# generates key material locally.
#
# Also switches the dotfiles repo origin remote to SSH when the dotfiles repo
# exists at $DOTFILES_DIR, defaulting to ~/.dot.

KEY_TTL="${GITHUB_SSH_KEY_TTL:-8h}"

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"
KEY_FILE="$SSH_DIR/id_ed25519-github"
PUB_KEY_FILE="$KEY_FILE.pub"
HOST_COMMENT="$(whoami)@$(hostname) github"
MANAGED_COMMENT="# GitHub SSH config added by setup-github-ssh.sh"

DOT_DIR="${DOTFILES_DIR:-$HOME/.dot}"
DOTFILES_SSH_REMOTE="${DOTFILES_SSH_REMOTE:-git@github.com:windweaver828/dotfiles.git}"
DOTFILES_HTTPS_REMOTE="${DOTFILES_HTTPS_REMOTE:-https://github.com/windweaver828/dotfiles.git}"

die() {
  echo "Error: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

has_github_host_block() {
  [ -f "$CONFIG_FILE" ] || return 1

  awk '
        /^[[:space:]]*#/ { next }

        /^[[:space:]]*Host[[:space:]]+/ {
            for (i = 2; i <= NF; i++) {
                if ($i == "github.com") {
                    found = 1
                }
            }
        }

        END {
            exit found ? 0 : 1
        }
    ' "$CONFIG_FILE"
}

set_dotfiles_remote_to_ssh() {
  if [ ! -d "$DOT_DIR/.git" ]; then
    echo
    echo "Dotfiles repo not found at:"
    echo "  $DOT_DIR"
    echo "Skipping dotfiles remote update."
    return 0
  fi

  echo
  echo "Setting dotfiles origin remote to SSH:"
  echo "  $DOTFILES_SSH_REMOTE"

  GIT_DIR="$DOT_DIR/.git" GIT_WORK_TREE="$HOME" \
    git remote set-url origin "$DOTFILES_HTTPS_REMOTE"
    git remote set-url --push origin "$DOTFILES_SSH_REMOTE"

  echo
  echo "Current dotfiles remote:"
  GIT_DIR="$DOT_DIR/.git" GIT_WORK_TREE="$HOME" \
    git remote -v
}

need_cmd ssh
need_cmd ssh-keygen
need_cmd git

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

echo "Setting up GitHub SSH authentication..."

if [ -f "$KEY_FILE" ]; then
  echo "Existing GitHub SSH key found; leaving it unchanged."

  if [ ! -f "$PUB_KEY_FILE" ]; then
    echo "Public key file is missing; regenerating it now."
    ssh-keygen -y -f "$KEY_FILE" >"$PUB_KEY_FILE"
    chmod 644 "$PUB_KEY_FILE"
  fi
else
  if [ -f "$PUB_KEY_FILE" ]; then
    rm -f "$PUB_KEY_FILE"
  fi

  echo
  echo "Creating a new GitHub SSH key."
  echo "When prompted, enter a passphrase. Avoid leaving it blank."
  echo

  umask 077
  ssh-keygen -q -t ed25519 -f "$KEY_FILE" -C "$HOST_COMMENT"
  chmod 600 "$KEY_FILE"
  chmod 644 "$PUB_KEY_FILE"

  echo "Created new GitHub SSH key."
fi

if has_github_host_block; then
  echo "Existing Host github.com block found in SSH config; leaving config unchanged."
else
  cat >>"$CONFIG_FILE" <<EOF

$MANAGED_COMMENT
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519-github
    IdentitiesOnly yes
    AddKeysToAgent $KEY_TTL
    CheckHostIP no
EOF

  chmod 600 "$CONFIG_FILE"
  echo "Added GitHub SSH config block."
fi

echo
echo "Add this public key to GitHub:"
echo
cat "$PUB_KEY_FILE"
echo
echo "GitHub path:"
echo "  Settings → SSH and GPG keys → New SSH key"
echo
echo "Suggested title:"
echo "  $(hostname)-github"
echo
echo "Key type:"
echo "  Authentication Key"
echo
echo "After saving the key in GitHub, test with:"
echo "  ssh -T git@github.com"
echo
echo "To remove the cached GitHub SSH key from ssh-agent early:"
echo "  ssh-add -d ~/.ssh/id_ed25519-github"
echo
echo "To remove all cached SSH keys from ssh-agent:"
echo "  ssh-add -D"

if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  echo
  echo "Note: no ssh-agent was detected in this shell."
  echo "Passphrase caching needs an active ssh-agent."
  echo "For a temporary agent in this shell, run:"
  echo '  eval "$(ssh-agent -s)"'
fi

set_dotfiles_remote_to_ssh

echo
echo "Done."
