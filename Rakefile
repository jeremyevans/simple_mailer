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
task :default=>[:spec]

begin
  begin
    raise LoadError if ENV['RSPEC1']
    # RSpec 2
    require "rspec/core/rake_task"
    spec_class = RSpec::Core::RakeTask
    spec_files_meth = :pattern=
  rescue LoadError
    # RSpec 1
    require "spec/rake/spectask"
    spec_class = Spec::Rake::SpecTask
    spec_files_meth = :spec_files=
  end

  desc "Run specs"
  spec_class.new("spec") do |t|
    t.send(spec_files_meth, ["spec/*.rb"])
  end
rescue LoadError
  task :default do
    puts "Must install rspec to run the default task (which runs specs)"
  end
end

