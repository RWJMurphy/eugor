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
      if KEY_TO_SYM.key? vk
        KEY_TO_SYM[vk]
      elsif c != "\x00"
        CHAR_TO_SYM[c]
      else
        fail TypeError
      end
    end

  end
end
