#!/usr/bin/env bats

@test "mise config exists" {
  [ -f "home/dot_config/mise/config.toml" ]
}

@test "mise config does not install ruby" {
  run grep -Eq '^[[:space:]]*ruby[[:space:]]*=' "home/dot_config/mise/config.toml"
  [ "$status" -ne 0 ]
}
