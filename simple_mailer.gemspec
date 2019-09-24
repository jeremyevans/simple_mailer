spec = Gem::Specification.new do |s| 
  s.name = "simple_mailer"
  s.version = "1.3.0"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple email library with testing support"
  s.files = ["README", "MIT-LICENSE", "lib/simple_mailer.rb", 'spec/simple_mailer.rb']
  s.extra_rdoc_files = ["MIT-LICENSE"]
  s.require_paths = ["lib"]
  s.rdoc_options = %w'--inline-source --line-numbers README lib'
  s.add_development_dependency "minitest-global_expectations"
end
