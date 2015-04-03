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

    def +(other)
      TCOD.color_add(self, other)
    end

    def scale_hsv(sscale, vscale)
      TCOD.color_scale_HSV(self, sscale, vscale)
    end

    class << self
      def bkgnd_alpha(alpha)
        #define TCOD_BKGND_ALPHA(alpha) ((TCOD_bkgnd_flag_t)(TCOD_BKGND_ALPH|(((uint8)(alpha*255))<<8)))
        BKGND_ALPH | (((alpha * 255).to_i & 0xFF) << 8)
      end

      def bkgnd_addalpha(alpha)
        #define TCOD_BKGND_ADDALPHA(alpha) ((TCOD_bkgnd_flag_t)(TCOD_BKGND_ADDA|(((uint8)(alpha*255))<<8)))
        BKGND_ADDA | (((alpha * 255).to_i & 0xFF) << 8)
      end
    end
  end
end
