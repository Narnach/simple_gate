Gem::Specification.new do |s|
  # Project
  s.name         = 'simple_gate'
  s.summary      = "SimpleGate makes it possible to use net/ssh/gateway's capabilities in a simple to use way."
  s.description  = s.summary
  s.version      = '0.5.2'
  s.date         = '2009-04-18'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Wes Oldenbeuving"]
  s.email        = "narnach@gmail.com"
  s.homepage     = "http://www.github.com/Narnach/simple_gate"

  # Files
  root_files     = %w[MIT-LICENSE README.rdoc Rakefile simple_gate.gemspec]
  bin_files      = %w[simple_gate gate_cp]
  lib_files      = %w[simple_gate
                      simple_gate/server_definition
                      simple_gate/router]
  test_files     = %w[]
  spec_files     = %w[simple_gate]
  s.bindir       = "bin"
  s.require_path = "lib"
  s.executables  = bin_files
  s.test_files   = test_files.map {|f| 'test/%s_test.rb' % f} + spec_files.map {|f| 'spec/%s_spec.rb' % f}
  s.files        = root_files + bin_files.map {|f| 'bin/%s' % f} + lib_files.map {|f| 'lib/%s.rb' % f} + s.test_files

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README.rdoc MIT-LICENSE]
  s.rdoc_options << '--inline-source' << '--line-numbers' << '--main' << 'README.rdoc'

  # Requirements
  s.required_ruby_version = ">= 1.8.0"
end
