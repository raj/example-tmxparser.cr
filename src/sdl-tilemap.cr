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
      # puts "tilemap: #{@tilemap.tilesets.inspect}"

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

    def render_layer(layer : ::Tmxparser::Layer, camera : Pointer(Camera))
      layer_data = layer.layer_data
      if layer_data.nil?
        puts "layer_data is nil"
        return
      end

      # VERSION 2 : still othorgraphic
      source_dests = layer.source_destination_indexes(tileset)
      source_dests.each do |source_dest|
        source_rect = LibSDL::Rect.new(
          x: source_dest.source.x,
          y: source_dest.source.y,
          w: source_dest.source.w,
          h: source_dest.source.h
        )
        dest_rect = LibSDL::Rect.new(
          x: (source_dest.destination.x * camera.value.zoom) - camera.value.x,
          y: (source_dest.destination.y * camera.value.zoom) - camera.value.y,
          w: source_dest.destination.w * camera.value.zoom,
          h: source_dest.destination.h * camera.value.zoom
        )
        LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(dest_rect))
      end

      # print "source_dest: #{source_dest.inspect}\n"


      # VERSION 1 OK
      # all_data = layer_data.data.split(",").map { |x| begin x.to_i rescue 0 end }
      # zoom = camera.value.zoom
      # source_tw = (tileset.tilewidth || 1)
      # source_th = (tileset.tileheight || 1)
      # all_data
      #   .map { |x| source_rect_from_tilenumber(x) }
      #   .each_slice(layer.width).each_with_index do |row_textures, index_row|
      #   row_textures.each_with_index do |texture_source, index_col|
      #     next if texture_source[0] == -1
      #     source_rect = LibSDL::Rect.new(
      #       x: texture_source[0],
      #       y: texture_source[1],
      #       w: source_tw,
      #       h: source_th
      #     )
      #     # source_rect = layer.layer_tile_source_rect(pointerof(tileset), texture_source[1])

      #     dest_x = index_col * source_tw * zoom
      #     dest_y = index_row * source_th * zoom
      #     destination_rect = LibSDL::Rect.new(
      #       x: dest_x - camera.value.x,
      #       y: dest_y - camera.value.y,
      #       w: source_tw * zoom,
      #       h: source_th * zoom
      #     )
      #     LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(destination_rect))
      #   end
      # end


    end

    def source_rect_from_tilenumber(tile_number : Int32) : Array(Int32) # [Int32, Int32]
      if (tile_number == 0)
        return [-1, -1]
      end
      columns = ((image.width + (tileset.spacing || 0)) / ((tileset.tilewidth || 1) + (tileset.spacing || 0))).to_i
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
      @tilemap.layers.each do |layer|
        render_layer(layer, camera)
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
end
