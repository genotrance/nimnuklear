import os

import nimterop/[build, cimport]

const
  baseDir = getProjectCacheDir("nimnuklear")
  nuklear = baseDir/"nuklear.h"

static:
  cDebug()
  if not fileExists(nuklear):
    downloadUrl("https://github.com/Immediate-Mode-UI/Nuklear/raw/master/nuklear.h", baseDir)

cPlugin:
  import strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.strip(chars = {'_'}).replace("__", "_x_")

    if sym.name.toLowerAscii().startsWith("nk_"):
      sym.name = sym.name[3 .. ^1]

    sym.name = case sym.name
      of "colorf": "colorf_t"
      of "strlen": "strlen_str"
      of "panel_set": ""
      of "edit_types": ""
      of "window_flags": ""
      else:
        sym.name

cDefine("NK_INCLUDE_FONT_BAKING")
cDefine("NK_INCLUDE_VERTEX_BUFFER_OUTPUT")
cDefine("NK_INCLUDE_DEFAULT_ALLOCATOR")

cImport(nuklear)

{.passC: "-DNK_IMPLEMENTATION".}
