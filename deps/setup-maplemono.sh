#!/usr/bin/env bash

if ! command -v jq > /dev/null; then
	echo "The program 'jq' must be installed."
	exit 1
fi

dir="$(mktemp -d)"
cd "$dir" || exit 1
trap 'rm -rf "$dir"' EXIT

gitlatestrelease="$(curl -Ls https://api.github.com/repos/subframe7536/maple-font/releases/latest)"
url="$(echo "$gitlatestrelease" | jq -r '.assets[].browser_download_url | select(contains("MapleMono-NF.zip"))')"
curl -LO "$url"

outdir="$HOME/.local/share/fonts/MapleMono-NF"
mkdir -p "$outdir"
unzip "MapleMono-NF.zip" -d "$outdir"

echo "Sucess..."
exit 0
