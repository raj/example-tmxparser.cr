require "sdl-crystal-bindings"
require "sdl-crystal-bindings/sdl-image-bindings"

module Example::Tmxparser
  def self.sdl_init
    if LibSDL.init(LibSDL::INIT_VIDEO) != 0
      raise "SDL could not initialize! SDL Error: #{String.new(LibSDL.get_error)}"
    end

    if LibSDL.set_hint(LibSDL::HINT_RENDER_SCALE_QUALITY, "1") == 0
      puts "Warning: Linear texture filtering not enabled!"
    end
  end

  def self.create_window : Pointer(LibSDL::Window)
    g_window = LibSDL.create_window("SDL Tutorial", LibSDL::WINDOWPOS_UNDEFINED, LibSDL::WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, LibSDL::WindowFlags::WINDOW_SHOWN)
    raise "Window could not be created! SDL Error: #{String.new(LibSDL.get_error)}" unless g_window
    displays = LibSDL.get_num_video_displays
    puts "Number of displays: #{displays}"

    g_window
  end

  def self.create_renderer(window : Pointer(LibSDL::Window)) : Pointer(LibSDL::Renderer)
    g_renderer = LibSDL.create_renderer(window, -1, LibSDL::RendererFlags::RENDERER_ACCELERATED | LibSDL::RendererFlags::RENDERER_PRESENTVSYNC)
    raise "Renderer could not be created! SDL Error: #{String.new(LibSDL.get_error)}" unless g_renderer

    LibSDL.set_render_draw_color(g_renderer, 0xFF, 0xFF, 0xFF, 0xFF)

    g_renderer
  end

  def self.init_sdl_image
    img_flags = LibSDL::IMGInitFlags::IMG_INIT_PNG
    if (LibSDL.img_init(img_flags) | img_flags.to_i) == 0
      raise "SDL_image could not initialize! SDL_image Error: #{String.new(LibSDLMacro.img_get_error)}"
    end
  end

  def self.load_img_file(renderer : Pointer(LibSDL::Renderer), file : String) : Pointer(LibSDL::Texture)
    loaded_surface = LibSDL.img_load(file)
    raise "Unable to load image #{file}! SDL_image Error: #{String.new(LibSDLMacro.img_get_error)}" unless loaded_surface

    new_texture = LibSDL.create_texture_from_surface(renderer, loaded_surface)
    raise "Unable to create texture from #{file}! SDL Error: #{String.new(LibSDL.get_error)}" unless new_texture

    LibSDL.free_surface(loaded_surface)

    new_texture
  end
end
