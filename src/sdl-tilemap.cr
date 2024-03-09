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

    def render_tileset(tileset : ::Tmxparser::Tileset, camera : Pointer(Camera), tick : UInt64)
      # puts tileset.images.inspect
      tileset.tiles.each do |tile|
        # puts "tile: #{tile.animations.size}"
        render_animation_tile(tileset, tile, camera, tick) if tile.animations.size > 0
      end
    end

    def frame_index(tile : ::Tmxparser::Tile, tick : UInt64)
      sum_animation_duration = tile.animations.map { |animation| animation.frames.map { |frame| frame.duration }.sum }.sum
      puts "sum_animation_duration: #{sum_animation_duration}"
      puts "tick: #{tick}"
      frame_index = 0 # (tick / sum_animation_duration) % tile.animations.first.frames.size
      puts tile.animations.first.frames[frame_index].inspect
      frame_index
    end
    
    def render_animation_tile(tileset : ::Tmxparser::Tileset,tile : ::Tmxparser::Tile,  camera : Pointer(Camera), tick : UInt64)
      # puts "rendering animation tile"
      puts "---"
      frame = tile.animations.first.frames[frame_index(tile, tick)]
      puts frame.inspect
      puts tile.inspect
      puts tileset.inspect
      # puts tileset.source_rect_from_tilenumber(frame.tileid).inspect
      # source_rect = LibSDL::Rect.new(
      #   x: frame.tileid % tileset.columns * tileset.tile_width,
      #   y: frame.tileid / tileset.columns * tileset.tile_height,
      #   w: tileset.tile_width,
      #   h: tileset.tile_height
      # )
      # dest_rect = LibSDL::Rect.new(
      #   x: (tile.id % @tilemap.width) * tileset.tile_width * camera.value.zoom - camera.value.x,
      #   y: (tile.id / @tilemap.width) * tileset.tile_height * camera.value.zoom - camera.value.y,
      #   w: tileset.tile_width * camera.value.zoom,
      #   h: tileset.tile_height * camera.value.zoom
      # )
      # LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(dest_rect))

      # tile.animations.each do |animation|
      #   animation.frames.each do |frame|
          # puts "frame: #{frame.tileid}"
          # if frame.duration <= tick
          #   source_rect = LibSDL::Rect.new(
          #     x: frame.tileid % tileset.columns * tileset.tile_width,
          #     y: frame.tileid / tileset.columns * tileset.tile_height,
          #     w: tileset.tile_width,
          #     h: tileset.tile_height
          #   )
          #   dest_rect = LibSDL::Rect.new(
          #     x: (tile.id % @tilemap.width) * tileset.tile_width * camera.value.zoom - camera.value.x,
          #     y: (tile.id / @tilemap.width) * tileset.tile_height * camera.value.zoom - camera.value.y,
          #     w: tileset.tile_width * camera.value.zoom,
          #     h: tileset.tile_height * camera.value.zoom
          #   )
          #   LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(dest_rect))
          #   break
          # end
      #   end
      # end
      # tileset.tiles.each do |tile|
      #   tile.animations.each do |animation|
      #     animation.frames.each do |frame|
      #       if frame.duration <= tick
      #         source_rect = LibSDL::Rect.new(
      #           x: frame.tileid % tileset.columns * tileset.tile_width,
      #           y: frame.tileid / tileset.columns * tileset.tile_height,
      #           w: tileset.tile_width,
      #           h: tileset.tile_height
      #         )
      #         dest_rect = LibSDL::Rect.new(
      #           x: (tile.id % @tilemap.width) * tileset.tile_width * camera.value.zoom - camera.value.x,
      #           y: (tile.id / @tilemap.width) * tileset.tile_height * camera.value.zoom - camera.value.y,
      #           w: tileset.tile_width * camera.value.zoom,
      #           h: tileset.tile_height * camera.value.zoom
      #         )
      #         LibSDL.render_copy(@renderer, texture, pointerof(source_rect), pointerof(dest_rect))
      #         break
      #       end
      #     end
      #   end
      # end
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

    def render_map(camera : Pointer(Camera), tick : UInt64)
      # print "rendering map #{tick}"
      @tilemap.layers.each do |layer|
        render_layer(layer, camera)
      end
      @tilemap.tilesets.each do |tileset|
        render_tileset(tileset, camera, tick)
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
