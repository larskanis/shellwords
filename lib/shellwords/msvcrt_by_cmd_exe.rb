module Shellwords::MsvcrtByCmdExe
  # Splits a string into an array of tokens in the same way the Microsoft
  # C-runtime does when started by the cmd.exe shell.
  #
  #   argv = Shellwords.split('here are "two words"')
  #   argv #=> ["here", "are", "two words"]
  def self.split(line)
    cmdline = ''
    line.scan(/\G(?>([^\^\"]+)|(\^.?)|("[^\"]*")|(\S))/m) do
      |word, esc, dq, garbage|
      raise ArgumentError, "Unmatched double quote: #{line.inspect}" if garbage
      cmdline << (word || dq || esc.gsub(/\^(.)/, '\\1'))
    end
    Shellwords::Msvcrt.split(cmdline)
  end

  # Escapes a string so that it can be safely used in a Windows cmd.exe
  # command line for most C applications.
  # +str+ can be a non-string object that responds to +to_s+.
  #
  # Note that a resulted string should be used unquoted and is not
  # intended for use in double quotes nor in single quotes.
  #
  #   argv = Shellwords.escape("It's better to give than to receive")
  #   argv #=> "^\"It's better to give than to receive^\""
  #
  # Returns an empty quoted String if +str+ has a length of zero.
  def self.escape(str)
    str = Shellwords::Msvcrt.escape(str)

    str.gsub!(/([\(\)%!\^\"\<\>\&|])/, "^\\1")

    return str
  end

  def self.join(array)
    array.map { |arg| escape(arg) }.join(' ')
  end
end
