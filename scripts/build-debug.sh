#!/bin/bash

set -e

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-26.4.1.app/Contents/Developer}"

xcodebuild \
  -project Aran.xcodeproj \
  -scheme Aran \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
