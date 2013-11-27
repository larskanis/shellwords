# -*- coding: utf-8 -*-
require 'test/unit'
require 'shellwords'

class TestCmdExe < Test::Unit::TestCase

  include Shellwords

  def setup
    Shellwords.default_rule_set = CmdExe
  end

  Examples = {
    '"ab "cd ef "gh"' => ['"ab "cd', 'ef', '"gh"'],
    '"ab ^"cd ^^ef "gh"' => ['"ab ^"cd', '^ef', '"gh"'],
  }.map { |str, args|
    [str.tr("/", "\\\\"), args.map { |arg| arg.tr("/", "\\\\") } ]
  }

  def test_examples_with_shellwords
    Examples.each do |cmdline, expected|
      assert_equal expected, shellwords(cmdline)
    end
  end
end
