#!/bin/bash

set -e

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-26.4.0.app/Contents/Developer}"

xcodebuild \
  -project Aran.xcodeproj \
  -scheme Aran \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=2CCD00CF-75FB-4B06-8A01-A7349A3EF7CF' \
  build
