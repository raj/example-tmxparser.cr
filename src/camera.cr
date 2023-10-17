require "sdl-crystal-bindings"
require "sdl-crystal-bindings/sdl-image-bindings"
require "tmxparser"

module Example::Tmxparser
  class Camera
    property x : Int32, y : Int32, width : Int32, height : Int32, zoom : Int32

    def initialize(x : Int32, y : Int32, width : Int32, height : Int32, zoom : Int32)
      @x = x
      @y = y
      @width = width
      @height = height
      @zoom = zoom
    end

    def move(x, y)
      @x += x
      @y += y
    end
  end
end