require 'rake'
begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ["--quiet", "--line-numbers", "--inline-source"]
  rdoc.main = "README"
  rdoc.title = "Simple email library with testing support"
  rdoc.rdoc_files.add ["README", "LICENSE", "lib/**/*.rb"]
end

desc "Package into gem"
task :package do
  sh %{gem build simple_mailer.gemspec}
end

desc "Run specs"
task :spec do
  sh %{spec spec/*}
end

desc "Run specs"
task :default=>[:spec]
