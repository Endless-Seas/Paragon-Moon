#!/bin/sh

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
export BYOND_MAJOR=516
export BYOND_MINOR=1688
export BYOND_WINDOWS_SHA256=9079f29b0747719233715dfeff223641e6fb69bd16b8ba9676d5cd42cfcd0148

# rust-g release; Windows binary already matches this upstream artifact.
export RUST_G_REPO=tgstation/rust-g
export RUST_G_VERSION=6.1.0
export RUST_G_WINDOWS_SHA256=2abdf53bf883da2ab354554dba7a2c3caa770d2b8bb91eb2f2ff97bce074ca1d
export RUST_G_LINUX_SHA256=77cc23841658fe4446cc0aab9b79357f0b3c822cf7fa385abf1fe51b6fded316

# node version
export NODE_VERSION_LTS=22.11.0

# Bun version
export BUN_VERSION=1.3.5

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.11

# Python version for mapmerge and other tools
export PYTHON_VERSION=3.9.0

#auxlua repo
export AUXLUA_REPO=tgstation/auxlua

#auxlua git tag
export AUXLUA_VERSION=1.4.4

#hypnagogic repo
export CUTTER_REPO=spacestation13/hypnagogic

#hypnagogic git tag
export CUTTER_VERSION=v3.1.0
