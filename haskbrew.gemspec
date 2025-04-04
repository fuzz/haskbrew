# frozen_string_literal: true

require_relative "lib/haskbrew/version"

Gem::Specification.new do |spec|
  spec.name = "haskbrew"
  spec.version = Haskbrew::VERSION
  spec.authors = ["TODO: Write your name"]
  spec.email = ["TODO: Write your email address"]

  spec.summary = "TODO: Write a short summary, because RubyGems requires one."
  spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "thor", "~> 1.2"  # CLI interface
  spec.add_dependency "toml-rb", "~> 2.2"  # TOML parsing
  spec.add_dependency "sorbet-runtime", "~> 0.5"  # Runtime type checking
  spec.add_dependency "kramdown", "~> 2.4"  # Markdown processing
  spec.add_dependency "tty-prompt", "~> 0.23"  # Interactive prompts
  spec.add_dependency "parslet", "~> 2.0"  # Elegant parsing library

  # Development dependencies
  spec.add_development_dependency "sorbet", "~> 0.5"
  spec.add_development_dependency "minitest", "~> 5.16"
  spec.add_development_dependency "standard", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
