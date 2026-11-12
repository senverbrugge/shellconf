# Source from ~/.zshrc AFTER `compinit`.

# krew plugins live here
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

alias k=kubectl

# kubectl completion (covers `k` and krew plugins via `kubectl <plugin>`)
if (( $+commands[kubectl] )); then
  source <(kubectl completion zsh)
  compdef k=kubectl
fi

# kubectx / kubens completions: shipped by distro packages in site-functions;
# fall back to ~/.zsh/completions (installed by scripts/setup-kube.sh).
[[ -d ~/.zsh/completions ]] && fpath=(~/.zsh/completions $fpath)
