#!/usr/bin/env bash

methods=$(rg --vimgrep -g '*.rb' '\bdef [a-z_\.]+' "$1" | \
  sed -e 's/.*def //' -e 's/[a-z_]*\.//' -e 's/[( ].*$//' -e 's/[^a-z_]//' | \
  sort | uniq)

for method in $methods; do
  if [[ $(rg --vimgrep -w -g '*.rb' -g '*.haml' -g '*.erb' "$method" "$1" | rg -w -v def | wc -l) -eq 0 ]]; then
    echo "could not find $method"
  fi
done
