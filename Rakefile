desc "Generate rdoc"
task :rdoc do
  rdoc_dir = "rdoc"
  rdoc_opts = ["--line-numbers", "--inline-source", '--title', 'simple_mailer: Simple email library with testing support']

  begin
    gem 'hanna'
    rdoc_opts.concat(['-f', 'hanna'])
  rescue Gem::LoadError
  end

  rdoc_opts.concat(['--main', 'README', "-o", rdoc_dir] +
    %w"README MIT-LICENSE" +
    Dir["lib/**/*.rb"]
  )

  FileUtils.rm_rf(rdoc_dir)

  require "rdoc"
  RDoc::RDoc.new.document(rdoc_opts)
end

desc "Package into gem"
task :package do
  sh %{gem build simple_mailer.gemspec}
end

desc "Run specs"
task :spec do
  sh %{#{FileUtils::RUBY} #{"-w" if RUBY_VERSION >= '3'} #{'-W:strict_unused_block' if RUBY_VERSION >= '3.4'} spec/simple_mailer.rb}
end

task :default => :spec

desc "Run specs with coverage"
task :spec_cov do
  ENV['COVERAGE'] = '1'
  sh %{#{FileUtils::RUBY} spec/simple_mailer.rb}
end
