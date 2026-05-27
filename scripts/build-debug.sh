#!/bin/bash

set -e

xcodebuild \
  -project Aran.xcodeproj \
  -scheme Aran \
  -configuration Debug \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro' \
  build
