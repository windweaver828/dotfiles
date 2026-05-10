# ~/.profile
#
# Login-shell setup. Keep this small and POSIX-ish.

[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/go/bin" ] && PATH="$PATH:$HOME/go/bin"

export PATH

# Source Bash config for login Bash shells.
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
