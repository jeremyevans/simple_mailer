spec = Gem::Specification.new do |s| 
  s.name = "simple_mailer"
  s.version = "1.0.0"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple email library with testing support"
  s.files = ["README", "LICENSE", "lib/simple_mailer.rb", 'spec/simple_mailer.rb']
  s.extra_rdoc_files = ["LICENSE"]
  s.require_paths = ["lib"]
  s.has_rdoc = true
  s.rdoc_options = %w'--inline-source --line-numbers README lib'
end
