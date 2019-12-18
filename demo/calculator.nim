##  nuklear - v1.00 - public domain

import nimnuklear except true, false

import strformat, strutils

proc calculator*(ctx: ptr context) =
  if begin(ctx, "Calculator", rect(x:10, y:10, w:180, h:250),
           (WINDOW_BORDER or WINDOW_NO_SCROLLBAR or WINDOW_MOVABLE).flags) != 0:
    var
      set {.global.}: bool = false
      prev {.global.}: char = '\0'
      op {.global.}: char = '\0'
      numbers {.global.}: cstring = "789456123"
      ops {.global.}: cstring = "+-*/"
      a {.global.}: float = 0
      b {.global.}: float = 0
      current {.global.}: ptr float = addr a
      solve: bool = false

    var len: cint # string editor
    var buffer: array[256, char] # string editor
    var buffercs: cstring = cast[cstring](addr buffer[0])

    layout_row_dynamic(ctx, 35, 1)
    var curstring = current[].formatFloat(ffDecimal, 2)
    copyMem(buffercs, curstring.cstring, curstring.len)
    buffer[curstring.len + 1] = '\0'
    len = curstring.len.cint
    discard edit_string(ctx, EDIT_ALWAYS_INSERT_MODE.flags, buffercs, addr(len), 255, filter_float)
    buffer[len] = '\0'
    current[] = parseFloat($buffercs)

    layout_row_dynamic(ctx, 35, 4)
    for i in 0..15:
      if i >= 12 and i < 15:
        if i > 12:
          continue
        if button_label(ctx, "C") != 0:
          a = 0; b = 0; op = '\0'
          current = addr(a)
          set = false
        if button_label(ctx, "0") != 0:
          current[] = current[] * 10.0
          set = false
        if button_label(ctx, "=") != 0:
          solve = true
          prev = op
          op = '\0'
      elif ((i + 1) mod 4) != 0:
        if button_text(ctx, addr(numbers[(i div 4) * 3 + i mod 4]), 1) != 0:
          current[] = current[] * 10.0 + float(numbers[(i div 4) * 3 + i mod 4].ord - '0'.ord)
          set = false
      elif button_text(ctx, addr(ops[i div 4]), 1) != 0:
        if not set:
          if current != addr(b):
            current = addr(b)
          else:
            prev = op
            solve = true
        op = ops[i div 4]
        set = true

    if solve:
      if prev == '+':
        a = a + b
      if prev == '-':
        a = a - b
      if prev == '*':
        a = a * b
      if prev == '/':
        a = a / b
      current = addr(a)
      if set:
        current = addr(b)
      b = 0
      set = false
  `end`(ctx)
