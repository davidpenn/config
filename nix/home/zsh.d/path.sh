typeset -U path

extra_paths=(
  "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"
  "${HOME}/.cargo/bin"
  "${HOME}/.local/bin"
)

for entry in "${extra_paths[@]}"; do
  if [ -d "$entry" ]; then
    path=("$entry" "${path[@]}")
  fi
done

unset extra_paths

if command -v go > /dev/null; then
  path=("$(go env GOPATH)/bin" "${path[@]}")
fi

typeset -U path
