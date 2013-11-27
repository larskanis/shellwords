require "bundler/gem_tasks"

desc "Run tests"
task :test do
  sh "ruby -w -W2 -I. -Ilib -e \"#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}\" -- -v"
end

if RUBY_PLATFORM=~/mingw|mswin/
  task :compile => ['test/output_argv.exe']

  file 'test/output_argv.exe' => ['test/output_argv.c'] do |t|
    sh "gcc -o #{t.name} #{t.prerequisites.first}"
  end

  task :test => :compile
end
