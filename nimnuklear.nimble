# Package

version       = "0.1.0"
author        = "genotrance"
description   = "nuklear wrapper for Nim"
license       = "MIT"

skipDirs = @["tests"]

# Dependencies

requires "nimgen >= 0.4.0"

import distros

var cmd = ""
if detectOs(Windows):
  cmd = "cmd /c "

task setup, "Download and generate":
  exec cmd & "nimgen nimnuklear.cfg"

before install:
  setupTask()

task test, "Test nimnuklear":
  exec "nim c -r tests/tnuk.nim"