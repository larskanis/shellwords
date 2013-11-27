# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shellwords/version'

Gem::Specification.new do |spec|
  spec.name          = "shellwords"
  spec.version       = Shellwords::VERSION
  spec.authors       = ["Lars Kanis"]
  spec.email         = ["lars@greiz-reinsdorf.de"]
  spec.description   = %q{Replacement for shellwords in Ruby's stdlibs. It supports escaping rules of Windows cmd.exe and MS runtime libraries.}
  spec.summary       = %q{Replacement for shellwords in Ruby's stdlibs.}
  spec.homepage      = "https://github.com/larskanis/shellwords"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
