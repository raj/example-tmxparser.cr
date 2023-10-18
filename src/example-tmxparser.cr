require "./sdl-utils"
require "tmxparser"
require "./sdl-tilemap"
require "./camera"

module Example::Tmxparser
  VERSION = "0.1.0"

  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480
  ZOOM_FACTOR = 2

  g_window = create_window
  g_renderer = create_renderer(g_window)
  init_sdl_image
  # tilemap = ::Tmxparser.load_xml("assets/sample-map.tmx")
  tilemap = ::Tmxparser.load_xml("assets/sample-map.tmx")
  # tilemap = ::Tmxparser.load_xml("assets/example.tmx") # data is only 0


  sdl_tilemap = SdlTilemap.new(g_renderer, tilemap, "assets")
  sdl_tilemap.load_textures
  camera = Camera.new(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, ZOOM_FACTOR)

  quit = false

  while (!quit)
    while LibSDL.poll_event(out e) != 0
      if e.type == LibSDL::EventType::QUIT.to_i
        quit = true
      end
    end

    LibSDL.render_clear(g_renderer)
    sdl_tilemap.render_map(pointerof(camera))
    LibSDL.render_present(g_renderer)
  end

  # LibSDL.destroy_texture(g_texture)
  LibSDL.destroy_renderer(g_renderer)
  LibSDL.destroy_window(g_window)

  LibSDL.img_quit
  LibSDL.quit
end
