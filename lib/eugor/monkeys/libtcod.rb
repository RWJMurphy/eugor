module TCOD
  class Key

  TCOD.constants
    .map(&:to_s)
    .select { |key| key.start_with?('KEY_') && ! %w(KEY_PRESSED KEY_RELEASED).include?(key) }
    .map { |key| "#{key}?".downcase.to_sym }
    .each do |method|
      define_method method do
        return(vk == TCOD.const_get(method[0..-2].upcase))
      end
    end
  end
end
