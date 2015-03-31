require 'libtcod'

module TCOD
  class Key

    KEY_TO_SYM = TCOD.constants
                 .map(&:to_s)
                 .select { |key| key.start_with?('KEY_') && !%w(KEY_PRESSED KEY_RELEASED).include?(key) }
                 .map { |key| [TCOD.const_get(key), key.to_sym] }
                 .to_h

    CHAR_TO_SYM = TCOD.constants
                 .map(&:to_s)
                 .select { |key| key.start_with?('CHAR_') }
                 .map { |key| [TCOD.const_get(key), key.to_sym] }
                 .to_h

    def to_sym
      if vk == TCOD::KEY_CHAR
        sym = CHAR_TO_SYM[c] || c.to_sym
      else
        sym = KEY_TO_SYM[vk]
      end
      fail TypeError if sym.nil?
      sym
    end

  end

  class Color
    alias_method :inspect, :to_s

    def scale_hsv(sscale, vscale)
      TCOD.color_scale_HSV(self, sscale, vscale)
    end
  end
end
