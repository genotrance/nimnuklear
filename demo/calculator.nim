##  nuklear - v1.00 - public domain

import nimnuklear/nuklear except true, false, char

import strformat

## FIXME: Necessary in order to combine panel flags.  This should really
##        be a part of the bindings.
proc `or`(a, b :panel_flags): panel_flags =
  return panel_flags(a.cint or b.cint)

## FIXME: Fix the parameters of the appropriate functions.  This should
##        really be a part of the bindings.
converter toFlags(x: nuklear.panel_flags): flags =
  return x.flags

proc calculator*(ctx: ptr nuklear.context) =
  if nuklear.begin(ctx, "Calculator", nuklear.rect(x:10, y:10, w:180, h:250),
      nuklear.WINDOW_BORDER or nuklear.WINDOW_NO_SCROLLBAR or nuklear.WINDOW_MOVABLE) != 0:
    var
      set: cint = 0
      prev: cint = 0
      op: cint = 0
    var numbers: cstring = "789456123"
    var ops: cstring = "+-*/"
    var
      a: cdouble = 0
      b: cdouble = 0
    var current: ptr cdouble = addr(a)
    var solve: bool = false

    var len: cint # string editor
    var buffer: array[256, char] # string editor

    nuklear.layout_row_dynamic(ctx, 35, 1)
    #len = snprintf(buffer, 256, "%.2f", current[])
    discard nuklear.edit_string(ctx, nuklear.EDIT_SIMPLE.flags, cast[cstring](addr buffer[0]), addr(len), 255, nuklear.filter_float)
    #buffer[len] = 0
    #current[] = atof(buffer)
    nuklear.layout_row_dynamic(ctx, 35, 4)

    for i in 0..15:
      if i >= 12 and i < 15:
        if i > 12:
          continue
        if nuklear.button_label(ctx, "C") != 0:
          a = 0; b = 0; op = 0
          current = addr(a)
          set = 0
        if nuklear.button_label(ctx, "0") != 0:
          current[] = current[] * 10.0
          set = 0
        if nuklear.button_label(ctx, "=") != 0:
          solve = true
          prev = op
          op = 0
      elif ((i + 1) mod 4) != 0:
        if nuklear.button_text(ctx, addr(numbers[(i div 4) * 3 + i mod 4]), 1) != 0:
          current[] = current[] * 10.0 + float64(numbers[(i div 4) * 3 + i mod 4].ord - '0'.ord)
          set = 0
      elif nuklear.button_text(ctx, addr(ops[i div 4]), 1) != 0:
        if set == 0:
          if current != addr(b):
            current = addr(b)
          else:
            prev = op
            solve = true
        op = ops[i div 4].ord.cint
        set = 1

    if solve:
      if prev == '+'.cint:
        a = a + b
      if prev == '-'.cint:
        a = a - b
      if prev == '*'.cint:
        a = a * b
      if prev == '/'.cint:
        a = a / b
      current = addr(a)
      if set != 0:
        current = addr(b)
      b = 0
      set = 0
  nuklear.end(ctx)
