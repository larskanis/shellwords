# -*- coding: utf-8 -*-
require 'test/unit'
require 'shellwords'

class TestMsvcrtByCmdExe < Test::Unit::TestCase

  include Shellwords

  def setup
    Shellwords.default_rule_set = MsvcrtByCmdExe
  end

  Examples = {
    # examples based on http://msdn.microsoft.com/en-us/library/windows/desktop/17w5ykft%28v=vs.85%29.aspx
    '"abc" d E' => ['abc', 'd', 'E'],
    'a///b d"e f"g H' => ['a///b', 'de fg', 'H'],
    'a///^"b c D' => ['a/"b', 'c', 'D'],
    'a////^"b c^" d E' => ['a//b c', 'd', 'E'],
    # further corner cases
    "a/////^\"b\tc\tD" => ['a//"b', 'c', 'D'],
    'a//^"^"  b \'c\' d^"^"E' => ['a/', 'b', "'c'", 'dE'],
    '^"//^" ^" b /^" / // c^" D' => ["/", ' b " / // c', 'D'],
    '^" a /^" / //^"/' => [' a " / //'],
    '^" a /^" /^> //^"/// ^^B' => [' a " /> ////', '^B'],
    '^" ^"a^" / /////^" B^"' => [' a / //" B'],
    '^" ^"^"a / /////^"^"^"^"^"^"^"' => [' "a', '/', '//"""'],
    "a/ b" => ['a/', 'b'],
  }.map { |str, args|
    [str.tr("/", "\\\\"), args.map { |arg| arg.tr("/", "\\\\") } ]
  }

  OutputArgvExe = File.expand_path('../output_argv.exe', __FILE__)
  OnWindows = RUBY_PLATFORM=~/mingw|mswin/

  def test_examples_with_shellwords
    Examples.each do |cmdline, expected|
      assert_equal expected, shellwords(cmdline)
    end
  end

  def test_examples_with_join_split
    Examples.each do |cmdline, expected|
      assert_equal expected, shellwords(shelljoin(shellwords(cmdline)))
    end
  end

  def test_examples_with_split_join
    Examples.each do |cmdline, expected|
      assert_equal [cmdline, cmdline], shellsplit(shelljoin([cmdline, cmdline]))
    end
  end

  def test_unmatched_double_quote
    bad_cmd = 'one two "three'
    assert_raise ArgumentError do
      shellwords(bad_cmd)
    end
  end

  def test_against_output_argv_exe
    skip unless OnWindows
    Examples.each do |cmdline, expected|
      assert_equal expected, split_per_output_argv_exe(cmdline)[2..-1]
    end
  end

  def split_per_output_argv_exe(cmdline)
    # The @ triggers that the command is started through cmd.exe.
    `@#{OutputArgvExe} #{cmdline}`.scan(/^===>(.*?)<===\n/m).map(&:first)
  end
end
