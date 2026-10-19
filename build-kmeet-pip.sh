#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

kmeet_build_backup=$(mktemp -d)
kmeet_generated_files=(
    Sources/Common/versionGenerated.swift
    Sources/Common/gitHashGenerated.swift
    Sources/Cli/subcommandDescriptionsGenerated.swift
)
for kmeet_generated_file in "${kmeet_generated_files[@]}"; do
    cp "$kmeet_generated_file" "$kmeet_build_backup/$(basename "$kmeet_generated_file")"
done
restore_generated_files() {
    for kmeet_generated_file in "${kmeet_generated_files[@]}"; do
        cp "$kmeet_build_backup/$(basename "$kmeet_generated_file")" "$kmeet_generated_file"
    done
    rm -rf "$kmeet_build_backup"
}
trap restore_generated_files EXIT

./generate.sh --ignore-xcodeproj --ignore-cmd-help \
    --build-version 0.20.0-Beta-kmeet-sticky.2 --generate-git-hash
swift build -c release

# Package the SPM executable without requiring Xcode's application builder.
# Only the optional icon is copied from the installed application.
python3 - <<'PY'
from pathlib import Path
import plistlib
import shutil
import subprocess

root = Path.cwd()
dist = root / '.local' / 'dist'
app = dist / 'AeroSpace-kMeet.app'
contents = app / 'Contents'
(contents / 'MacOS').mkdir(parents=True, exist_ok=True)
(contents / 'Resources').mkdir(parents=True, exist_ok=True)
shutil.copy2(root / '.build/release/AeroSpaceApp', contents / 'MacOS/AeroSpace')
shutil.copy2(root / '.build/release/aerospace', dist / 'aerospace')
shutil.copy2(root / 'docs/config-examples/default-config.toml', contents / 'Resources/default-config.toml')
icon = Path('/Applications/AeroSpace.app/Contents/Resources/AppIcon.icns')
if icon.exists():
    shutil.copy2(icon, contents / 'Resources/AppIcon.icns')
info = {
    'CFBundleExecutable': 'AeroSpace',
    'CFBundleIdentifier': 'bobko.aerospace',
    'CFBundleName': 'AeroSpace',
    'CFBundleDisplayName': 'AeroSpace kMeet',
    'CFBundlePackageType': 'APPL',
    'CFBundleInfoDictionaryVersion': '6.0',
    'CFBundleShortVersionString': '0.20.0-Beta-kmeet-sticky.2',
    'CFBundleVersion': '20.0.2',
    'CFBundleIconFile': 'AppIcon',
    'LSMinimumSystemVersion': '13.0',
    'LSUIElement': True,
}
(contents / 'Info.plist').write_bytes(plistlib.dumps(info))
(contents / 'PkgInfo').write_bytes(b'APPL????')
subprocess.run(['codesign', '--force', '--sign', '-', str(app)], check=True)
subprocess.run(['codesign', '--verify', '--strict', str(app)], check=True)
print(app)
PY
