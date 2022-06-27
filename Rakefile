require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'Simple email library with testing support', '--main', 'README']

  begin
    gem 'hanna-nouveau'
    rdoc.options += ['-f', 'hanna']
  rescue Gem::LoadError
  end

  rdoc.rdoc_files.add %w"README MIT-LICENSE lib/**/*.rb"
end

desc "Package into gem"
task :package do
  sh %{gem build simple_mailer.gemspec}
end

desc "Run specs"
task :spec do
  sh %{#{FileUtils::RUBY} #{"-w" if RUBY_VERSION >= '3'} -I lib spec/*.rb}
end

task :default => :spec
