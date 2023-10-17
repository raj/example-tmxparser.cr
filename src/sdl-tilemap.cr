require "sdl-crystal-bindings"
require "sdl-crystal-bindings/sdl-image-bindings"
require "tmxparser"

module Example::Tmxparser
  class SdlTilemap
    property textures : Hash(String, Pointer(LibSDL::Texture))

    def initialize(renderer : Pointer(LibSDL::Renderer), tilemap : ::Tmxparser::Map, assets_path : String)
      @renderer = renderer
      @tilemap = tilemap
      @assets_path = assets_path
      @textures = {} of String => Pointer(LibSDL::Texture)
      puts "renderer: #{@renderer.inspect}"
      puts "tilemap: #{@tilemap.inspect}"
      puts "-----------------------------------------------"
      puts "tilemap: #{@tilemap.tilesets.inspect}"

      # @tileset = SDL::Image::load_texture(@renderer, @tilemap.tileset.image.source)
    end

    def load_textures
      @tilemap.tilesets.each do |tileset|
        tileset.images.each do |image|
          @textures[image.source] = SdlTilemap.load_img_file(@renderer, "#{@assets_path}/#{image.source}")
        end
      end
    end

    # TODO : for now only one tileset is supported
    def texture
      @textures[@tilemap.tilesets.first.images.first.source]
    end

    def render_layer(layer : ::Tmxparser::Layer, camera : Pointer(Camera) )
      # puts "render_layer #{layer.name} with texture #{texture.inspect}"
      layer_data = layer.layer_data
      if layer_data.nil?
        puts "layer_data is nil"
        return
      end
      puts "data: #{layer.inspect}"
      all_data = layer_data.data.split(",").map { |x| x.to_i }
      puts "all_data: #{all_data.size}"

      zoom = camera.value.zoom
      source_rect = LibSDL::Rect.new(x:87, y: 87, w: 8, h: 8)
      destination_rect = LibSDL::Rect.new(x: 0, y: 0, w: 8 * zoom, h: 8 * zoom)
      LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(destination_rect))
    end

    def render_map(camera : Pointer(Camera))
      # puts "render_map"
      # puts "camera: #{camera.value.width}"
      @tilemap.layers.each do |layer|
        # puts "layer: #{layer.inspect}"
        render_layer(layer, camera)
      end

      # tile_width = 8
      # tile_height = 8
      # source_rect = LibSDL::Rect.new(x: tile_width * 19, y: tile_height * 12, w: tile_width, h: tile_height)
      # destination_rect = LibSDL::Rect.new(x: 0, y: 0, w: tile_width * 10, h: tile_height * 10)
      # # puts "source_rect: #{source_rect.inspect}"
      # # puts "destination_rect: #{destination_rect.inspect}"
      # g_texture = @textures["./tilemap.png"]
      # LibSDL.render_copy(@renderer, g_texture, pointerof(source_rect), pointerof(destination_rect))
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
end
