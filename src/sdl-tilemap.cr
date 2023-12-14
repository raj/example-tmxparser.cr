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

    def render_tileset(tileset : ::Tmxparser::Tileset, camera : Pointer(Camera))
      tileset.tiles.each do |tile|
        puts "tile: #{tile.inspect}"
      end
    end


    def render_layer(layer : ::Tmxparser::Layer, camera : Pointer(Camera))
      layer_data = layer.layer_data
      if layer_data.nil?
        puts "layer_data is nil"
        return
      end

      source_dests = layer.source_destination_indexes(tileset, @tilemap.orientation)
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
    end

    def render_map(camera : Pointer(Camera))
      @tilemap.layers.each do |layer|
        render_layer(layer, camera)
      end
      @tilemap.tilesets.each do |tileset|
        render_tileset(tileset, camera)
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
