#!/bin/bash

set -e

xcodebuild \
  -project Aran.xcodeproj \
  -scheme Aran \
  -configuration Debug \
  -destination 'platform=iOS Simulator,OS=26.4.1,name=iPhone 17 Pro' \
  build
