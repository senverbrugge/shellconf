# shellconf

A [Starship](https://starship.rs) prompt with a "powerline, one-line" look: `░▒▓` start cap, dark (256-color 234) segments,
arrow separators, left-side directory + git, right-side status / duration /
jobs / terraform / kubernetes / azure / ssh user@host / time.

## Requirements
- zsh
- a [Nerd Font](https://www.nerdfonts.com/) (or any Powerline-patched font) set in your terminal
- starship (`sudo pacman -S starship`, `brew install starship`, or `curl -sS https://starship.rs/install.sh | sh`)

## Install
```sh
git clone <this-repo> ~/dev/shellconf
mkdir -p ~/.config
ln -sf ~/dev/shellconf/starship.toml ~/.config/starship.toml
```

Add to the end of `~/.zshrc`:
```sh
source ~/dev/shellconf/zsh/starship.zsh   # or: eval "$(starship init zsh)"
```
Back up `~/.zshrc` first. Open a new terminal.

## Kubernetes tooling (kubectl, kubectx, kubens, krew)
```sh
./scripts/setup-kube.sh
```
Installs kubectl and kubectx/kubens (pacman, brew, or manual download fallback),
krew, zsh completions, and the krew plugins listed in `krew-plugins.txt`
(edit that file to taste). Then add to `~/.zshrc`, **after** `compinit`:
```sh
source ~/dev/shellconf/zsh/kube.zsh
```
This adds krew to `PATH`, the `k` alias for kubectl, and completions for
`kubectl`, `k`, `kubectx` and `kubens`. On Arch, `krew-bin` comes from the AUR
(the script uses `yay` if present, otherwise it falls back to the upstream
release binary).

## Kubernetes segment not showing?
Starship's kubernetes module can fail to parse kubeconfigs with unusual
indentation (e.g. written by some tools). Normalize it (keep a backup):
```sh
cp -p ~/.kube/config ~/.kube/config.bak
kubectl config view --raw > /tmp/k && cat /tmp/k > ~/.kube/config && chmod 600 ~/.kube/config && rm /tmp/k
```

## Secrets
Never put tokens in `~/.zshrc`. Keep them in an untracked file, e.g.:
```sh
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh   # chmod 600, not in git
```
