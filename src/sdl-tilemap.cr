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
      @current_tick = 0
    end

    def load_textures
      @tilemap.tilesets.each do |tileset|
        tileset.images.each do |image|
          @textures[image.source] = SdlTilemap.load_img_file(@renderer, "#{@assets_path}/#{image.source}")
        end
      end
    end

    def render_layer(layer : ::Tmxparser::Layer, camera : Pointer(Camera), tick : UInt64)
      layer_data = layer.layer_data
      if layer_data.nil?
        puts "layer_data is nil"
        return
      end

      list_gid = @tilemap.tilesets.map { |tileset| tileset.firstgid }
      max_tile_id = layer.layer_data.data.split(",").max
      return if max_tile_id.to_i == 0

      max_gid = list_gid.select { |gid| gid <= max_tile_id.to_i }.last
      tileset = @tilemap.tilesets.find { |tileset| tileset.firstgid == max_gid }
      return if tileset.nil?

      source_dests = layer.source_destination_indexes(tileset, @tilemap.orientation, tick)
      spacing = tileset.spacing || 0
      spacing = 0 if @tilemap.orientation == ::Tmxparser::Orientation::Orthogonal
      margin = tileset.margin || 0

      source_dests.each do |source_dest|
        source_rect = LibSDL::Rect.new(
          x: source_dest.source.x + spacing + margin,
          y: source_dest.source.y + spacing + margin,
          w: source_dest.source.w,
          h: source_dest.source.h
        )
        dest_rect = LibSDL::Rect.new(
          x: (source_dest.destination.x * camera.value.zoom) - camera.value.x,
          y: (source_dest.destination.y * camera.value.zoom) - camera.value.y,
          w: source_dest.destination.w * camera.value.zoom,
          h: source_dest.destination.h * camera.value.zoom
        )
        image = tileset.images.first
        texture = @textures[image.source]

        LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(dest_rect))
      end
    end

    def render_map(camera : Pointer(Camera), tick : UInt64)
      @tilemap.layers.each do |layer|
        render_layer(layer, camera, tick)
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
