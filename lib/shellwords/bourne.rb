##
# == Manipulates strings like the UNIX Bourne shell
#
# This module manipulates strings according to the word parsing rules
# of the UNIX Bourne shell.
#
# The shellwords() function was originally a port of shellwords.pl,
# but modified to conform to POSIX / SUSv3 (IEEE Std 1003.1-2001 [1]).
#
# === Usage
#
# You can use shellwords to parse a string into a Bourne shell friendly Array.
#
#   require 'shellwords'
#
#   argv = Shellwords.split('three blind "mice"')
#   argv #=> ["three", "blind", "mice"]
#
# Once you've required Shellwords, you can use the #split alias
# String#shellsplit.
#
#   argv = "see how they run".shellsplit
#   argv #=> ["see", "how", "they", "run"]
#
# Be careful you don't leave a quote unmatched.
#
#   argv = "they all ran after the farmer's wife".shellsplit
#        #=> ArgumentError: Unmatched double quote: ...
#
# In this case, you might want to use Shellwords.escape, or it's alias
# String#shellescape.
#
# This method will escape the String for you to safely use with a Bourne shell.
#
#   argv = Shellwords.escape("special's.txt")
#   argv #=> "special\\s.txt"
#   system("cat " + argv)
#
# Shellwords also comes with a core extension for Array, Array#shelljoin.
#
#   argv = %w{ls -lta lib}
#   system(argv.shelljoin)
#
# You can use this method to create an escaped string out of an array of tokens
# separated by a space. In this example we'll use the literal shortcut for
# Array.new.
#
# === Authors
# * Wakou Aoyama
# * Akinori MUSHA <knu@iDaemons.org>
#
# === Contact
# * Akinori MUSHA <knu@iDaemons.org> (current maintainer)
#
# === Resources
#
# 1: {IEEE Std 1003.1-2004}[http://pubs.opengroup.org/onlinepubs/009695399/toc.htm]

module Shellwords::Bourne
  # Splits a string into an array of tokens in the same way the UNIX
  # Bourne shell does.
  #
  #   argv = Shellwords.split('here are "two words"')
  #   argv #=> ["here", "are", "two words"]
  #
  # String#shellsplit is a shortcut for this function.
  #
  #   argv = 'here are "two words"'.shellsplit
  #   argv #=> ["here", "are", "two words"]
  def self.split(line)
    words = []
    field = ''
    line.scan(/\G\s*(?>([^\s\\\'\"]+)|'([^\']*)'|"((?:[^\"\\]|\\.)*)"|(\\.?)|(\S))(\s|\z)?/m) do
      |word, sq, dq, esc, garbage, sep|
      raise ArgumentError, "Unmatched double quote: #{line.inspect}" if garbage
      field << (word || sq || (dq || esc).gsub(/\\(.)/, '\\1'))
      if sep
        words << field
        field = ''
      end
    end
    words
  end

  # Escapes a string so that it can be safely used in a Bourne shell
  # command line.  +str+ can be a non-string object that responds to
  # +to_s+.
  #
  # Note that a resulted string should be used unquoted and is not
  # intended for use in double quotes nor in single quotes.
  #
  #   argv = Shellwords.escape("It's better to give than to receive")
  #   argv #=> "It\\'s\\ better\\ to\\ give\\ than\\ to\\ receive"
  #
  # String#shellescape is a shorthand for this function.
  #
  #   argv = "It's better to give than to receive".shellescape
  #   argv #=> "It\\'s\\ better\\ to\\ give\\ than\\ to\\ receive"
  #
  #   # Search files in lib for method definitions
  #   pattern = "^[ \t]*def "
  #   open("| grep -Ern #{pattern.shellescape} lib") { |grep|
  #     grep.each_line { |line|
  #       file, lineno, matched_line = line.split(':', 3)
  #       # ...
  #     }
  #   }
  #
  # It is the caller's responsibility to encode the string in the right
  # encoding for the shell environment where this string is used.
  #
  # Multibyte characters are treated as multibyte characters, not bytes.
  #
  # Returns an empty quoted String if +str+ has a length of zero.
  def self.escape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?

    str = str.dup

    # Treat multibyte characters as is.  It is caller's responsibility
    # to encode the string in the right encoding for the shell
    # environment.
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    str.gsub!(/\n/, "'\n'")

    return str
  end

  def self.join(array)
    array.map { |arg| escape(arg) }.join(' ')
  end
end
