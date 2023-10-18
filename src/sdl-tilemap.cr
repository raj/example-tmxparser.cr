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
      # puts "renderer: #{@renderer.inspect}"
      # puts "tilemap: #{@tilemap.inspect}"
      # puts "-----------------------------------------------"
      puts "tilemap: #{@tilemap.tilesets.inspect}"

      # # @tileset = SDL::Image::load_texture(@renderer, @tilemap.tileset.image.source)
    end

    def load_textures
      @tilemap.tilesets.each do |tileset|
        tileset.images.each do |image|
          @textures[image.source] = SdlTilemap.load_img_file(@renderer, "#{@assets_path}/#{image.source}")
        end
      end
    end

    # TODO : for now only one tileset is supported
    def tileset
      @tilemap.tilesets.first
    end

    def image
      tileset.images.first
    end

    def texture
      @textures[image.source]
    end

    def render_layer(layer : ::Tmxparser::Layer, camera : Pointer(Camera) )
      layer_data = layer.layer_data
      if layer_data.nil?
        puts "layer_data is nil"
        return
      end
      # puts "layer_data: #{layer_data.inspect}"
      all_data = layer_data.data.split(",").map { |x| begin x.to_i rescue 0 end }
      # puts "all_data 1: #{all_data.inspect}" if layer.name == "Objects"
      all_texture_source = all_data.map { |x| source_rect_from_tilenumber(x) }
      # puts "all_data: #{all_texture_source.inspect}" if layer.name == "Objects"
      zoom = camera.value.zoom
      source_tw = (tileset.tilewidth || 1)
      source_th = (tileset.tileheight || 1)
      all_texture_source.each_slice(layer.width).each_with_index do |row_textures, index_row|
        dest_y = index_row * source_th * zoom
        row_textures.each_with_index do |texture_source, index_col|
          next if texture_source[0] == -1
          source_rect = LibSDL::Rect.new(x: texture_source[0], y: texture_source[1], w: source_tw, h: source_th)
          dest_x = index_col * source_tw * zoom
          destination_rect = LibSDL::Rect.new(x: dest_x, y: dest_y, w: source_tw * zoom, h: source_th * zoom)
          LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(destination_rect))
        end
      end
    end

    def source_rect_from_tilenumber(tile_number : Int32) : Array(Int32) # [Int32, Int32]
      if (tile_number == 0)
        return [-1, -1]
      end
      columns = ((image.width + (tileset.spacing || 0) ) / ((tileset.tilewidth || 1) + (tileset.spacing || 0))).to_i
      position_x = tile_number % columns == 0 ? columns : tile_number % columns
      position_x = tile_number <= columns ? tile_number : position_x
      position_y = tile_number % columns == 0 ? (tile_number / columns).to_i : (tile_number / columns).to_i + 1
      position_y = tile_number <= columns ? 1 : position_y
      [
        (position_x - 1) * (tileset.tilewidth || 1) + (position_x - 1) * (tileset.spacing || 0),
        (position_y - 1) * (tileset.tileheight || 1) + (position_y - 1) * (tileset.spacing || 0),
      ]
    end

    def render_map(camera : Pointer(Camera))
      # puts "render_map"
      # puts "camera: #{camera.value.width}"
      # puts @tilemap.layers.last.inspect
      @tilemap.layers.each do |layer|
        # return unless layer.name == "Objects"
        # puts "layer: #{layer.name}"
        # puts "layer data : #{layer.layer_data.inspect}"
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
