#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/windweaver828/dotfiles.git}"
SSH_REPO_URL="${DOTFILES_SSH_REPO:-git@github.com:windweaver828/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-master}"
DOT_DIR="${DOTFILES_DIR:-$HOME/.dot}"
BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backup}"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"

recommended_installs=(
	"bash-completion"
	"git"
	"tmux"
	"neovim"
  "fzf"
)

optional_installs=(
	"bat"
	"curl"
	"lsd"
	"ripgrep"
	"wl-clipboard"
	"xclip"
	"zoxide"
)

echo "Setting up environment"
echo

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "Missing required command: $1"
		exit 1
	}
}

prompt_yes() {
	local prompt="$1"
	local answer=""

	read -r -p "$prompt [y/N]: " answer

	case "$answer" in
	[Yy] | [Yy][Ee][Ss])
		return 0
		;;
	*)
		return 1
		;;
	esac
}

dot() {
	GIT_DIR="$DOT_DIR/.git/" GIT_WORK_TREE="$HOME" /usr/bin/git "$@"
}

backup_path() {
	local relpath="$1"
	local src="$HOME/$relpath"
	local dest="$BACKUP_DIR/$relpath"

	[ -e "$src" ] || [ -L "$src" ] || return 0

	mkdir -p "$(dirname "$dest")"
	mv "$src" "$dest"

	echo "Backed up $src -> $dest"
}

backup_existing_home_files() {
	echo "Backing up existing home files that the dotfiles repo will manage"
	echo

	mkdir -p "$BACKUP_DIR"

	# Dynamically back up every file tracked in the target branch.
	# No manual file list needed.
	while IFS= read -r relpath; do
		[ -n "$relpath" ] || continue
		backup_path "$relpath"
	done < <(dot ls-tree -r --name-only "origin/$BRANCH")

	# Also back up ~/.gitignore if it exists, since this installer may create it
	# even when it is not tracked in the dotfiles repo.
	backup_path ".gitignore"

	echo
	echo "Backup directory:"
	echo "  $BACKUP_DIR"
	echo
}

need_cmd git

if [ -e "$DOT_DIR" ] && [ ! -d "$DOT_DIR/.git" ]; then
	echo "$DOT_DIR exists but does not look like a dotfiles git checkout."
	echo "Backing it up before continuing."
	echo

	mkdir -p "$BACKUP_DIR"
	mv "$DOT_DIR" "$BACKUP_DIR/.dot"

	echo "Backed up $DOT_DIR -> $BACKUP_DIR/.dot"
	echo
fi

if [ ! -d "$DOT_DIR/.git" ]; then
	echo "Cloning dotfiles to $DOT_DIR"
	git clone --no-checkout "$REPO_URL" "$DOT_DIR" || {
		echo "Cloning failed."
		exit 1
	}
else
	echo "Using existing dotfiles checkout at $DOT_DIR"
fi

echo "Fetching $BRANCH"
dot fetch origin "$BRANCH"

backup_existing_home_files

echo "Checking out $BRANCH"
dot checkout -f -B "$BRANCH" "origin/$BRANCH"
dot reset --hard "origin/$BRANCH"
dot config --local status.showUntrackedFiles no

# Hide untracked home files from the dotfiles worktree unless the repo itself
# manages ~/.gitignore.
if ! dot ls-tree -r --name-only "origin/$BRANCH" | grep -qx ".gitignore"; then
	echo "*" >"$HOME/.gitignore"
fi

# Build the bat cache if possible.
# Failure here should not fail the whole setup.
if command -v bat >/dev/null 2>&1; then
	bat cache --build >/dev/null 2>&1 || true
elif command -v batcat >/dev/null 2>&1; then
	batcat cache --build >/dev/null 2>&1 || true
fi

echo
echo "Recommended packages for full functionality:"
echo "  ${recommended_installs[*]}"
echo
echo "Optional comfort packages:"
echo "  ${optional_installs[*]}"
echo

if [ -f "$HOME/.dotfiles/setup/install-fonts.sh" ]; then
	if prompt_yes "Install bundled FiraCode Nerd Fonts?"; then
		bash "$HOME/.dotfiles/setup/install-fonts.sh"
	fi
else
	echo "Font installer not found at $HOME/.dotfiles/setup/install-fonts.sh"
fi

echo

if [ -f "$HOME/.dotfiles/setup/setup-github-ssh.sh" ]; then
	if prompt_yes "Run GitHub SSH setup and switch dotfiles remote to SSH?"; then
		DOTFILES_SSH_REPO="$SSH_REPO_URL" bash "$HOME/.dotfiles/setup/setup-github-ssh.sh"
	fi
else
	echo "GitHub SSH setup script not found at $HOME/.dotfiles/setup/setup-github-ssh.sh"
fi

echo
echo "Installation complete."
echo

exec bash
