require "sdl-crystal-bindings"
require "sdl-crystal-bindings/sdl-image-bindings"

module Example::Tmxparser
  VERSION = "0.1.0"


SCREEN_WIDTH  = 640
SCREEN_HEIGHT = 480

if LibSDL.init(LibSDL::INIT_VIDEO) != 0
  raise "SDL could not initialize! SDL Error: #{String.new(LibSDL.get_error)}"
end

if LibSDL.set_hint(LibSDL::HINT_RENDER_SCALE_QUALITY, "1") == 0
  puts "Warning: Linear texture filtering not enabled!"
end

g_window = LibSDL.create_window("SDL Tutorial", LibSDL::WINDOWPOS_UNDEFINED, LibSDL::WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, LibSDL::WindowFlags::WINDOW_SHOWN)
raise "Window could not be created! SDL Error: #{String.new(LibSDL.get_error)}" unless g_window

g_renderer = LibSDL.create_renderer(g_window, -1, LibSDL::RendererFlags::RENDERER_ACCELERATED)
raise "Renderer could not be created! SDL Error: #{String.new(LibSDL.get_error)}" unless g_renderer

LibSDL.set_render_draw_color(g_renderer, 0xFF, 0xFF, 0xFF, 0xFF)

img_flags = LibSDL::IMGInitFlags::IMG_INIT_PNG
if (LibSDL.img_init(img_flags) | img_flags.to_i) == 0
  raise "SDL_image could not initialize! SDL_image Error: #{String.new(LibSDLMacro.img_get_error)}"
end

loaded_surface = LibSDL.img_load("assets/tmw_desert_spacing.png")
raise "Unable to load image texture.png! SDL_image Error: #{String.new(LibSDL.get_error)}" unless loaded_surface

g_texture = LibSDL.create_texture_from_surface(g_renderer, loaded_surface)
raise "Unable to create texture from texture.png! SDL Error: #{String.new(LibSDL.get_error)}" unless g_texture

LibSDL.free_surface(loaded_surface)

quit = false

while (!quit)
  while LibSDL.poll_event(out e) != 0
    if e.type == LibSDL::EventType::QUIT.to_i
      quit = true
    end
  end

  tile_width = 32
  tile_height = 32
  source_rect = LibSDL::Rect.new(x: tile_width * 3, y: tile_height * 5, w: tile_width, h: tile_height)
  destination_rect = LibSDL::Rect.new(x: 0, y: 0, w: tile_width, h: tile_height)
  # LibSDL.set_render_draw_color(g_renderer, 0x00, 0xFF, 0x00, 0xFF)
  # LibSDL.render_draw_rect(g_renderer, pointerof(outline_rect))
  LibSDL.render_clear(g_renderer)
  LibSDL.render_copy(g_renderer, g_texture, pointerof(source_rect), pointerof(destination_rect))

  LibSDL.render_present(g_renderer)


end

LibSDL.destroy_texture(g_texture)
LibSDL.destroy_renderer(g_renderer)
LibSDL.destroy_window(g_window)

LibSDL.img_quit
LibSDL.quit


end
