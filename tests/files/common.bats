#!/usr/bin/env bats

@test "home directory structure exists" {
  [ -d "home" ]
}

@test "install directory structure exists" {
  [ -d "install" ]
}

@test "README.md exists" {
  [ -f "README.md" ]
}

@test ".chezmoiroot file exists" {
  [ -f ".chezmoiroot" ]
}
