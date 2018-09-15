##  nuklear - 1.32.0 - public domain

import opengl, sdl2

import nimnuklear/nuklear

const
  NK_INCLUDE_FIXED_TYPES* = true
  NK_INCLUDE_STANDARD_IO* = true
  NK_INCLUDE_STANDARD_VARARGS* = true
  NK_INCLUDE_DEFAULT_ALLOCATOR* = true
  NK_INCLUDE_VERTEX_BUFFER_OUTPUT* = true
  NK_INCLUDE_FONT_BAKING* = true
  NK_INCLUDE_DEFAULT_FONT* = true
  NK_IMPLEMENTATION* = true
  NK_SDL_GL3_IMPLEMENTATION* = true

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
## #define INCLUDE_ALL
## #define INCLUDE_STYLE
## #define INCLUDE_CALCULATOR
## #define INCLUDE_OVERVIEW
## #define INCLUDE_NODE_EDITOR

when defined(INCLUDE_ALL):
  const
    INCLUDE_STYLE* = true
    INCLUDE_CALCULATOR* = true
    INCLUDE_OVERVIEW* = true
    INCLUDE_NODE_EDITOR* = true
when defined(INCLUDE_STYLE):
  import
    ../style

when defined(INCLUDE_CALCULATOR):
  import
    ../calculator

when defined(INCLUDE_OVERVIEW):
  import
    ../overview

when defined(INCLUDE_NODE_EDITOR):
  import
    ../node_editor

##  ===============================================================
## 
##                           DEMO
## 
##  ===============================================================

proc main*(): cint =
  ##  Platform
  var win: ptr SDL_Window
  var glContext: SDL_GLContext
  var
    win_width: cint
    win_height: cint
  var running: cint = 1
  ##  GUI
  var ctx: ptr nk_context
  var bg: nk_colorf
  ##  SDL setup
  SDL_SetHint(SDL_HINT_VIDEO_HIGHDPI_DISABLED, "0")
  SDL_Init(SDL_INIT_VIDEO or SDL_INIT_TIMER or SDL_INIT_EVENTS)
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS,
                      SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  win = SDL_CreateWindow("Demo", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                       WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_OPENGL or
      SDL_WINDOW_SHOWN or SDL_WINDOW_ALLOW_HIGHDPI)
  glContext = SDL_GL_CreateContext(win)
  SDL_GetWindowSize(win, addr(win_width), addr(win_height))
  ##  OpenGL setup
  glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
  glewExperimental = 1
  if glewInit() != GLEW_OK:
    fprintf(stderr, "Failed to setup GLEW\x0A")
    exit(1)
  ctx = nk_sdl_init(win)
  ##  Load Fonts: if none of these are loaded a default font will be used
  ##  Load Cursor: if you uncomment cursor loading please hide the cursor
  var atlas: ptr nk_font_atlas
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
  while running:
    ##  Input
    var evt: SDL_Event
    nk_input_begin(ctx)
    while SDL_PollEvent(addr(evt)):
      if evt.`type` == SDL_QUIT: break cleanup
      nk_sdl_handle_event(addr(evt))
    nk_input_end(ctx)
    ##  GUI
    if nk_begin(ctx, "Demo", nk_rect(50, 50, 230, 250), NK_WINDOW_BORDER or
        NK_WINDOW_MOVABLE or NK_WINDOW_SCALABLE or NK_WINDOW_MINIMIZABLE or
        NK_WINDOW_TITLE):
      const
        EASY = 0
        HARD = 1
      var op: cint = EASY
      var property: cint = 20
      nk_layout_row_static(ctx, 30, 80, 1)
      if nk_button_label(ctx, "button"): printf("button pressed!\x0A")
      nk_layout_row_dynamic(ctx, 30, 2)
      if nk_option_label(ctx, "easy", op == EASY): op = EASY
      if nk_option_label(ctx, "hard", op == HARD): op = HARD
      nk_layout_row_dynamic(ctx, 22, 1)
      nk_property_int(ctx, "Compression:", 0, addr(property), 100, 10, 1)
      nk_layout_row_dynamic(ctx, 20, 1)
      nk_label(ctx, "background:", NK_TEXT_LEFT)
      nk_layout_row_dynamic(ctx, 25, 1)
      if nk_combo_begin_color(ctx, nk_rgb_cf(bg),
                             nk_vec2(nk_widget_width(ctx), 400)):
        nk_layout_row_dynamic(ctx, 120, 1)
        bg = nk_color_picker(ctx, bg, NK_RGBA)
        nk_layout_row_dynamic(ctx, 25, 1)
        bg.r = nk_propertyf(ctx, "#R:", 0, bg.r, 1.0, 0.01, 0.005)
        bg.g = nk_propertyf(ctx, "#G:", 0, bg.g, 1.0, 0.01, 0.005)
        bg.b = nk_propertyf(ctx, "#B:", 0, bg.b, 1.0, 0.01, 0.005)
        bg.a = nk_propertyf(ctx, "#A:", 0, bg.a, 1.0, 0.01, 0.005)
        nk_combo_end(ctx)
    nk_end(ctx)
    ##  -------------- EXAMPLES ----------------
    when defined(INCLUDE_CALCULATOR):
      calculator(ctx)
    when defined(INCLUDE_OVERVIEW):
      overview(ctx)
    when defined(INCLUDE_NODE_EDITOR):
      node_editor(ctx)
    ##  -----------------------------------------
    ##  Draw
    SDL_GetWindowSize(win, addr(win_width), addr(win_height))
    glViewport(0, 0, win_width, win_height)
    glClear(GL_COLOR_BUFFER_BIT)
    glClearColor(bg.r, bg.g, bg.b, bg.a)
    ##  IMPORTANT: `nk_sdl_render` modifies some global OpenGL state
    ##  with blending, scissor, face culling, depth test and viewport and
    ##  defaults everything back into a default state.
    ##  Make sure to either a.) save and restore or b.) reset your own state after
    ##  rendering the UI.
    nk_sdl_render(NK_ANTI_ALIASING_ON, MAX_VERTEX_MEMORY, MAX_ELEMENT_MEMORY)
    SDL_GL_SwapWindow(win)
  nk_sdl_shutdown()
  SDL_GL_DeleteContext(glContext)
  SDL_DestroyWindow(win)
  SDL_Quit()
  return 0
