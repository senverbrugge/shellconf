#!/usr/bin/env bash
# Install kubectl, kubectx/kubens (+ zsh completions) and krew with plugins.
# Supports Arch (pacman), macOS (brew) and falls back to manual downloads.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMP_DIR="$HOME/.zsh/completions"
KUBECTX_VERSION="${KUBECTX_VERSION:-v0.9.5}"

have() { command -v "$1" >/dev/null 2>&1; }

install_pkgs() {
  if have pacman; then
    sudo pacman -S --needed --noconfirm kubectl kubectx
    have kubectl-krew || { have yay && yay -S --needed --noconfirm krew-bin || true; }
  elif have brew; then
    brew install kubectl kubectx krew
  else
    echo "No supported package manager; using manual downloads" >&2
    mkdir -p "$HOME/.local/bin"
    arch="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
    os="$(uname -s | tr A-Z a-z)"
    have kubectl || {
      ver="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
      curl -fsSLo "$HOME/.local/bin/kubectl" "https://dl.k8s.io/release/$ver/bin/$os/$arch/kubectl"
      chmod +x "$HOME/.local/bin/kubectl"
    }
    for t in kubectx kubens; do
      have "$t" || {
        curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/${t}_${KUBECTX_VERSION}_${os}_$(uname -m).tar.gz" \
          | tar -xz -C "$HOME/.local/bin" "$t"
      }
    done
  fi
}

install_completions() {
  # Distro/brew packages normally ship these; only fetch if missing.
  mkdir -p "$COMP_DIR"
  for t in kubectx kubens; do
    if ! compgen -G "/usr/share/zsh/site-functions/_$t" >/dev/null \
       && ! compgen -G "$(brew --prefix 2>/dev/null)/share/zsh/site-functions/_$t" >/dev/null; then
      curl -fsSLo "$COMP_DIR/_$t" "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_$t.zsh"
    fi
  done
}

install_krew_binary() {
  have kubectl-krew && return
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  os="$(uname | tr A-Z a-z)"
  arch="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
  krew="krew-${os}_${arch}"
  curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/latest/download/${krew}.tar.gz" | tar -xz -C "$tmp"
  "$tmp/$krew" install krew
}

install_plugins() {
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  kubectl krew update
  grep -vE '^\s*(#|$)' "$REPO_DIR/krew-plugins.txt" | xargs -r kubectl krew install
}

install_pkgs
install_krew_binary
install_completions
install_plugins

echo "Done. Add to ~/.zshrc (after compinit):  source $REPO_DIR/zsh/kube.zsh"
