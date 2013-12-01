module Shellwords::CmdExe
  # Splits a string into an array of tokens in the same way the Windows
  # cmd.exe shell does for %1 to %9 parameters.
  #
  #   argv = Shellwords.split('here are "two words"')
  #   argv #=> ["here", "are", "\"two words\""]
  def self.split(line)
    words = []
    field = ''
    line.scan(/\G\s*(?>([^\s\^\"]+)|(\^.?)|("[^\"]*")|(\S))(\s|\z)?/m) do
      |word, esc, dq, garbage, sep|
      raise ArgumentError, "Unmatched double quote: #{line.inspect}" if garbage
      field << (word || dq || esc.gsub(/\^(.)/, '\\1'))
      if sep
        words << field
        field = ''
      end
    end
    words
  end

  def self.escape(str)
    raise NotImplemented
  end

  def self.join(array)
    array.map { |arg| escape(arg) }.join(' ')
  end
end
