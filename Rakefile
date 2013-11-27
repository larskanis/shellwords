require "bundler/gem_tasks"

desc "Run tests"
task :test do
  sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
end

if RUBY_PLATFORM=~/mingw|mswin/
  task :compile do
    sh "gcc -o test/output_argv.exe test/output_argv.c"
  end

  task :test => :compile
end
