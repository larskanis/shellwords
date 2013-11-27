require "shellwords/version"

module Shellwords
  autoload :Bourne, 'shellwords/bourne'
  autoload :CmdExe, 'shellwords/cmd_exe'
  autoload :Msvcrt, 'shellwords/msvcrt'
  autoload :MsvcrtByCmdExe, 'shellwords/msvcrt_by_cmd_exe'

  @@default_rule_set = case RUBY_PLATFORM
    when /mingw|mswin/ then Shellwords::Msvcrt
    else Shellwords::Bourne
  end

  def self.default_rule_set
    @@default_rule_set
  end

  def self.default_rule_set=(v)
    @@default_rule_set = v
  end

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
  def shellsplit(line, rule_set=nil)
    (rule_set || @@default_rule_set).split(line)
  end

  alias shellwords shellsplit

  module_function :shellsplit, :shellwords

  class << self
    alias split shellsplit
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
  def shellescape(str, rule_set=nil)
    (rule_set || @@default_rule_set).escape(str)
  end

  module_function :shellescape

  class << self
    alias escape shellescape
  end

  # Builds a command line string from an argument list, +array+.
  #
  # All elements are joined into a single string with fields separated by a
  # space, where each element is escaped for Bourne shell and stringified using
  # +to_s+.
  #
  #   ary = ["There's", "a", "time", "and", "place", "for", "everything"]
  #   argv = Shellwords.join(ary)
  #   argv #=> "There\\'s a time and place for everything"
  #
  # Array#shelljoin is a shortcut for this function.
  #
  #   ary = ["Don't", "rock", "the", "boat"]
  #   argv = ary.shelljoin
  #   argv #=> "Don\\'t rock the boat"
  #
  # You can also mix non-string objects in the elements as allowed in Array#join.
  #
  #   output = `#{['ps', '-p', $$].shelljoin}`
  #
  def shelljoin(array, rule_set=nil)
    (rule_set || @@default_rule_set).join(array)
  end

  module_function :shelljoin

  class << self
    alias join shelljoin
  end
end

class String
  # call-seq:
  #   str.shellsplit => array
  #
  # Splits +str+ into an array of tokens in the same way the UNIX
  # Bourne shell does.
  #
  # See Shellwords.shellsplit for details.
  def shellsplit(rule_set=nil)
    Shellwords.split(self, rule_set)
  end

  # call-seq:
  #   str.shellescape => string
  #
  # Escapes +str+ so that it can be safely used in a Bourne shell
  # command line.
  #
  # See Shellwords.shellescape for details.
  def shellescape(rule_set=nil)
    Shellwords.escape(self, rule_set)
  end
end

class Array
  # call-seq:
  #   array.shelljoin => string
  #
  # Builds a command line string from an argument list +array+ joining
  # all elements escaped for Bourne shell and separated by a space.
  #
  # See Shellwords.shelljoin for details.
  def shelljoin(rule_set=nil)
    Shellwords.join(self, rule_set)
  end
end
