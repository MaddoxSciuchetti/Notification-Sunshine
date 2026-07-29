#!/bin/zsh
set -euo pipefail

repository_dir="${0:A:h:h}"
cd "$repository_dir"

swift build -c release

app_dir="$repository_dir/dist/Shining Sun.app"
contents_dir="$app_dir/Contents"
mkdir -p "$contents_dir/MacOS"
cp "$repository_dir/.build/release/ShiningSun" "$contents_dir/MacOS/ShiningSun"
cp "$repository_dir/Resources/Info.plist" "$contents_dir/Info.plist"
codesign --force --sign - "$app_dir"

echo "$app_dir"
