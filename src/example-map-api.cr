require "./sdl-utils"
require "tmxparser"
require "./sdl-tilemap"
require "./camera"

module Example::Tmxparser
  VERSION = "0.1.0"

  SCREEN_WIDTH  = 1280
  SCREEN_HEIGHT = 720

  ZOOM_FACTOR = 1

  g_window = create_window
  g_renderer = create_renderer(g_window)
  init_sdl_image
  tilemap = ::Tmxparser.load_xml("assets/example-api.tmx")

  sdl_tilemap = SdlTilemap.new(g_renderer, tilemap, "assets")
  sdl_tilemap.load_textures
  camera = Camera.new(-600, -50, SCREEN_WIDTH, SCREEN_HEIGHT, ZOOM_FACTOR)

  quit = false

  while (!quit)
    while LibSDL.poll_event(out e) != 0
      if e.type == LibSDL::EventType::QUIT.to_i
        quit = true
      end
      if e.type == LibSDL::EventType::MOUSEWHEEL.to_i
        if (e.wheel.y > 0)
          camera.zoom_in
        else
          camera.zoom_out
        end
      end
    end
    # puts LibSDL.get_performance_counter()

    current_key_states = LibSDL.get_keyboard_state(nil)
    if current_key_states[LibSDL::Scancode::SCANCODE_ESCAPE.to_i] == 1
      quit = true
    end
    
    if current_key_states[LibSDL::Scancode::SCANCODE_UP.to_i] == 1
      camera.y -= 10
    end
    if current_key_states[LibSDL::Scancode::SCANCODE_DOWN.to_i] == 1
      camera.y += 10
    end
    if current_key_states[LibSDL::Scancode::SCANCODE_LEFT.to_i] == 1
      camera.x -= 10
    end
    if current_key_states[LibSDL::Scancode::SCANCODE_RIGHT.to_i] == 1
      camera.x += 10
    end

    LibSDL.render_clear(g_renderer)
    sdl_tilemap.render_map(pointerof(camera), LibSDL.get_ticks64)
    LibSDL.render_present(g_renderer)
  end

  # LibSDL.destroy_texture(g_texture)
  LibSDL.destroy_renderer(g_renderer)
  LibSDL.destroy_window(g_window)

  LibSDL.img_quit
  LibSDL.quit
end
