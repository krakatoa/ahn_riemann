# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ahn_riemann/version"

Gem::Specification.new do |s|
  s.name        = "ahn_riemann"
  s.version     = AhnRiemann::VERSION
  s.authors     = ["Fernando D. Alonso"]
  s.email       = ["krakatoa1987@gmail.com"]
  s.homepage    = "http://github.com/krakatoa/ahn_riemann"
  s.summary     = %q{Adhearsion-Riemann plugin}
  s.description = %q{Adhearsion plugin to forward call events and exceptions to the Riemann server}

  s.rubyforge_project = "ahn_riemann"

  # Use the following if using Git
  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.files         = Dir.glob("{lib}/**/*") + %w( README.md Rakefile Gemfile)
  s.test_files    = Dir.glob("{spec}/**/*")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, ["~> 2.3"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]
  s.add_runtime_dependency %q<riemann-client>, [">= 0.2.1"]
  s.add_runtime_dependency %q<timers>, [">= 1.1.0"]

  s.add_development_dependency %q<bundler>, ["~> 1.0"]
  s.add_development_dependency %q<rspec>, ["~> 2.5"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<mocha>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
 end
