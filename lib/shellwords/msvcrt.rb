module Shellwords::Msvcrt
  # Splits a string into an array of tokens in the same way the Microsoft
  # C-runtime does.
  #
  #   argv = Shellwords.split('here are "two words"')
  #   argv #=> ["here", "are", "two words"]
  def self.split(line)
    words = []
    field = ''
    line.scan(/\G\s*(?>((?:[^\s\\\"]|\\+[^\s\\\"]|(?:\\\\)*\\")+)|((?:\\\\)*)"((?:[^\\\"]|\\+[^\\\"]|(?:\\\\)*\\")*)("|(?:\\\\)*)"|(\\+)(?:\s|\z)|(\S))(\s|\z)?/m) do
      |word, bsbq, dq, bsaq, trbs, garbage, sep|
      raise ArgumentError, "Unmatched double quote: #{line.inspect}" if garbage
      bsbq, bsaq = [bsbq, bsaq].map{|a| a.to_s.gsub("\\\\", "\\") }
      field << bsbq
      field << (word || dq || '').gsub(/((?:\\\\)*)\\"/){ "\\" * ($1.length/2) + '"' }
      field << bsaq
      field << trbs if trbs
      if sep || trbs
        words << field
        field = ''
      end
    end
    words
  end

  # Escapes a string so that it can be safely used in a Windows
  # command line for most C applications.
  # +str+ can be a non-string object that responds to +to_s+.
  #
  # Note that a resulted string should be used unquoted and is not
  # intended for use in double quotes nor in single quotes.
  #
  #   argv = Shellwords.escape("It's better to give than to receive")
  #   argv #=> "\"It's better to give than to receive\""
  #
  # Returns an empty quoted String if +str+ has a length of zero.
  def self.escape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    return '""' if str.empty?

    str = str.dup

    str.gsub!(/((?:\\)*)"/){ "\\" * ($1.length*2) + "\\\"" }
    if str =~ /\s/
      str.gsub!(/(\\+)\z/){ "\\" * ($1.length*2) }
      str = "\"#{str}\""
    end

    return str
  end

  def self.join(array)
    array.map { |arg| escape(arg) }.join(' ')
  end
end
