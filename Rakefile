require 'rake'

RDOC_OPTS = ["--quiet", "--line-numbers", "--inline-source"]
rdoc_task_class = begin
  require "rdoc/task"
  RDOC_OPTS.concat(['-f', 'hanna'])
  RDoc::Task
rescue LoadError
  require "rake/rdoctask"
  Rake::RDocTask
end

rdoc_task_class.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
  rdoc.main = "README"
  rdoc.title = "Simple email library with testing support"
  rdoc.rdoc_files.add ["README", "MIT-LICENSE", "lib/**/*.rb"]
end

desc "Package into gem"
task :package do
  sh %{gem build simple_mailer.gemspec}
end

desc "Run specs"
task :spec do
  sh %{#{FileUtils::RUBY} -rubygems -I lib spec/*.rb}
end

task :default => :spec
