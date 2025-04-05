# frozen_string_literal: true

require_relative 'lib/haskbrew/version'

Gem::Specification.new do |spec|
  spec.name = 'haskbrew'
  spec.version = Haskbrew::VERSION
  spec.authors = ['Fuzz Leonard']
  spec.email = ['ink@fuzz.ink']

  spec.summary = 'Haskell package release automation for Hackage and Homebrew'
  spec.description = 'A tool for automating the release process of Haskell packages to Hackage and Homebrew'
  spec.homepage = 'https://github.com/fuzz/haskbrew'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/fuzz/haskbrew'
  spec.metadata['changelog_uri'] = 'https://github.com/fuzz/haskbrew/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob('{lib,exe}/**/*') +
               ['README.md', 'LICENSE.txt', 'CHANGELOG.md']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'json', '~> 2.6' # JSON parsing for bottles
  spec.add_dependency 'parslet', '~> 2.0' # Elegant parsing library
  spec.add_dependency 'sorbet-runtime', '~> 0.5' # Runtime type checking
  spec.add_dependency 'thor', '~> 1.2' # CLI interface
  spec.add_dependency 'toml-rb', '~> 2.2' # TOML parsing
  spec.add_dependency 'tty-prompt', '~> 0.23' # Interactive prompts

  # Development dependencies
  spec.add_development_dependency 'minitest', '~> 5.16'
  spec.add_development_dependency 'minitest-reporters', '~> 1.5'
  spec.add_development_dependency 'rubocop', '~> 1.75'
  spec.add_development_dependency 'sorbet', '~> 0.5'
  spec.add_development_dependency 'tapioca', '~> 0.16'
end
