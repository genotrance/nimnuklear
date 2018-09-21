##  nuklear - 1.32.0 - public domain

import nimnuklear/nuklear except true, false
import opengl, sdl2

import nuklear_sdl_gl3

const
  WINDOW_WIDTH* = 1200
  WINDOW_HEIGHT* = 800
  MAX_VERTEX_MEMORY* = 512 * 1024
  MAX_ELEMENT_MEMORY* = 128 * 1024

##  ===============================================================
## 
##                           EXAMPLE
## 
##  ===============================================================
##  This are some code examples to provide a small overview of what can be
##  done with this library. To try out an example uncomment the defines
const INCLUDE_STYLE = false
const INCLUDE_CALCULATOR = true
const INCLUDE_OVERVIEW = false
const INCLUDE_NODE_EDITOR = false

when INCLUDE_STYLE:
  import
    ../style

when INCLUDE_CALCULATOR:
  import
    ../calculator

when INCLUDE_OVERVIEW:
  import
    ../overview

when INCLUDE_NODE_EDITOR:
  import
    ../node_editor

## FIXME: Necessary in order to combine panel flags.  This should really
##        be a part of the bindings.
proc `or`(a, b :panel_flags): panel_flags =
  return panel_flags(a.cint or b.cint)

##  ===============================================================
## 
##                           DEMO
## 
##  ===============================================================

##  Platform
var win: sdl2.WindowPtr
var glContext: sdl2.GlContextPtr
var
  win_width: cint
  win_height: cint
var running: cint = 1

##  GUI
var ctx: ptr nuklear.context
var bg: nuklear.colorf

##  SDL setup
discard sdl2.setHint("SDL_VIDEO_HIGHDPI_DISABLED", "0")
sdl2.init(sdl2.INIT_VIDEO or sdl2.INIT_TIMER or sdl2.INIT_EVENTS)
discard sdl2.glSetAttribute(SDL_GL_CONTEXT_FLAGS,
                            SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)
discard sdl2.glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
discard sdl2.glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
discard sdl2.glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
discard sdl2.glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)
win = sdl2.createWindow("Demo", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                        WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_OPENGL or
                        SDL_WINDOW_SHOWN or SDL_WINDOW_ALLOW_HIGHDPI)
glContext = sdl2.glCreateContext(win)
win.getSize(win_width, win_height)

##  OpenGL setup
opengl.loadExtensions()
glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
ctx = nk_sdl_init(win)
##  Load Fonts: if none of these are loaded a default font will be used
##  Load Cursor: if you uncomment cursor loading please hide the cursor
var atlas: ptr nuklear.font_atlas
nk_sdl_font_stash_begin(addr(atlas))
## struct nk_font *droid = nk_font_atlas_add_from_file(atlas, "../../../extra_font/DroidSans.ttf", 14, 0);
## struct nk_font *roboto = nk_font_atlas_add_from_file(atlas, "../../../extra_font/Roboto-Regular.ttf", 16, 0);
## struct nk_font *future = nk_font_atlas_add_from_file(atlas, "../../../extra_font/kenvector_future_thin.ttf", 13, 0);
## struct nk_font *clean = nk_font_atlas_add_from_file(atlas, "../../../extra_font/ProggyClean.ttf", 12, 0);
## struct nk_font *tiny = nk_font_atlas_add_from_file(atlas, "../../../extra_font/ProggyTiny.ttf", 10, 0);
## struct nk_font *cousine = nk_font_atlas_add_from_file(atlas, "../../../extra_font/Cousine-Regular.ttf", 13, 0);
nk_sdl_font_stash_end()
## nk_style_load_all_cursors(ctx, atlas->cursors);
## nk_style_set_font(ctx, &roboto->handle);

##  style.c
when defined(INCLUDE_STYLE):
  ## set_style(ctx, THEME_WHITE);
  ## set_style(ctx, THEME_RED);
  ## set_style(ctx, THEME_BLUE);
  ## set_style(ctx, THEME_DARK);

bg.r = 0.1
bg.g = 0.18
bg.b = 0.24
bg.a = 1.0
while running == 1:
  ##  Input
  var evt: sdl2.Event
  nuklear.input_begin(ctx)
  while sdl2.pollEvent(evt):
    if evt.kind == QuitEvent:
      # TODO: Handle cleanup
      quit(QuitFailure)
    discard nk_sdl_handle_event(addr(evt))
  nuklear.input_end(ctx)

  ##  GUI
  if nuklear.begin(ctx, "Demo".cstring,
    nuklear.rect(x:50, y:50, w:230, h:250),
    nuklear.flags(nuklear.WINDOW_BORDER or nuklear.WINDOW_MOVABLE or
    nuklear.WINDOW_SCALABLE or nuklear.WINDOW_MINIMIZABLE or
    nuklear.WINDOW_TITLE)) == 1:
    const
      EASY = 0
      HARD = 1
    var op {.global.}: cint = EASY
    var property {.global.}: cint = 20

    nuklear.layout_row_static(ctx, 30, 80, 1)
    if nuklear.button_label(ctx, "button") == 1:
      echo "button pressed!"
    nuklear.layout_row_dynamic(ctx, 30, 2)
    if nuklear.option_label(ctx, "easy", cint(op == EASY)) == 1:
      op = EASY
    if nuklear.option_label(ctx, "hard", cint(op == HARD)) == 1:
      op = HARD
    nuklear.layout_row_dynamic(ctx, 22, 1)
    nuklear.property_int(ctx, "Compression:", 0, addr(property), 100, 10, 1)

    nuklear.layout_row_dynamic(ctx, 20, 1)
    nuklear.label(ctx, "background:", nuklear.TEXT_LEFT.flags)
    nuklear.layout_row_dynamic(ctx, 25, 1)
    if nuklear.combo_begin_color(ctx, nuklear.rgb_cf(bg),
      nuklear.vec2(x: nuklear.widget_width(ctx), y: 400)) == 1:
      nuklear.layout_row_dynamic(ctx, 120, 1)
      bg = nuklear.color_picker(ctx, bg, nuklear.RGBA)
      nuklear.layout_row_dynamic(ctx, 25, 1)
      bg.r = nuklear.propertyf(ctx, "#R:", 0, bg.r, 1.0, 0.01, 0.005)
      bg.g = nuklear.propertyf(ctx, "#G:", 0, bg.g, 1.0, 0.01, 0.005)
      bg.b = nuklear.propertyf(ctx, "#B:", 0, bg.b, 1.0, 0.01, 0.005)
      bg.a = nuklear.propertyf(ctx, "#A:", 0, bg.a, 1.0, 0.01, 0.005)
      nuklear.combo_end(ctx)
  nuklear.end(ctx)

  ##  -------------- EXAMPLES ----------------
  when INCLUDE_CALCULATOR:
    calculator.calculator(ctx)
  when INCLUDE_OVERVIEW:
    overview(ctx)
  when INCLUDE_NODE_EDITOR:
    node_editor(ctx)
  ##  -----------------------------------------

  ##  Draw
  win.getSize(win_width, win_height)
  glViewport(0, 0, win_width, win_height)
  glClear(GL_COLOR_BUFFER_BIT)
  glClearColor(bg.r, bg.g, bg.b, bg.a)
  ##  IMPORTANT: `nk_sdl_render` modifies some global OpenGL state
  ##  with blending, scissor, face culling, depth test and viewport and
  ##  defaults everything back into a default state.
  ##  Make sure to either a.) save and restore or b.) reset your own state after
  ##  rendering the UI.
  nk_sdl_render(nuklear.ANTI_ALIASING_ON, MAX_VERTEX_MEMORY, MAX_ELEMENT_MEMORY)
  sdl2.glSwapWindow(win)

# TODO: Implement clean shutdown
#nk_sdl_shutdown()
#SDL_GL_DeleteContext(glContext)
#SDL_DestroyWindow(win)
#SDL_Quit()
quit(QuitSuccess)
