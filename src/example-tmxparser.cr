require "./sdl-utils"

module Example::Tmxparser
  VERSION = "0.1.0"

  SCREEN_WIDTH  = 640
  SCREEN_HEIGHT = 480

  g_window = create_window
  g_renderer = create_renderer(g_window)
  init_sdl_image
  g_texture = load_img_file(g_renderer, "assets/tmw_desert_spacing.png")

  quit = false

  while (!quit)
    while LibSDL.poll_event(out e) != 0
      if e.type == LibSDL::EventType::QUIT.to_i
        quit = true
      end
    end

    LibSDL.render_clear(g_renderer)

    tile_width = 8
    tile_height = 8
    source_rect = LibSDL::Rect.new(x: tile_width * 19, y: tile_height * 12, w: tile_width, h: tile_height)
    destination_rect = LibSDL::Rect.new(x: 0, y: 0, w: tile_width * 10, h: tile_height * 10)
    LibSDL.render_copy(g_renderer, g_texture, pointerof(source_rect), pointerof(destination_rect))

    source_rect = LibSDL::Rect.new(x: tile_width * 20, y: tile_height * 12, w: tile_width, h: tile_height)
    destination_rect = LibSDL::Rect.new(x: tile_width * 10, y: 0, w: tile_width * 10, h: tile_height * 10)
    LibSDL.render_copy(g_renderer, g_texture, pointerof(source_rect), pointerof(destination_rect))

    LibSDL.render_present(g_renderer)
  end

  LibSDL.destroy_texture(g_texture)
  LibSDL.destroy_renderer(g_renderer)
  LibSDL.destroy_window(g_window)

  LibSDL.img_quit
  LibSDL.quit
end
