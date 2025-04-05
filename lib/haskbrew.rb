# frozen_string_literal: true

require_relative 'haskbrew/version'
require_relative 'haskbrew/cabal'
require_relative 'haskbrew/cli'
require_relative 'haskbrew/hackage'
require_relative 'haskbrew/homebrew'
require_relative 'haskbrew/bottle'
require_relative 'haskbrew/config'
require_relative 'haskbrew/changelog'

module Haskbrew
  class Error < StandardError; end

  # Main entry point for the Haskbrew library
  class Core
    # Initialize with configuration
    def initialize(config = {})
      @config = config
    end

    # Release a new version
    def release(version = nil, options = {})
      # This is a wrapper around the CLI functionality
      # Useful for programmatic access
      current_dir = Dir.pwd

      # Find cabal file
      cabal_file = find_cabal_file(current_dir)
      return false unless cabal_file

      cabal = Cabal.new(cabal_file)
      current_version = cabal.version

      # Determine new version
      new_version = version || increment_version(current_version)

      # Update version in cabal file
      cabal.update_version(new_version)

      # Update changelog
      Changelog.update(new_version, current_dir, options[:interactive]) if File.exist?('CHANGELOG.md')

      # Handle the rest of the release process based on options
      true
    end

    private

    def find_cabal_file(dir)
      Dir.glob("#{dir}/**/*.cabal").first
    end

    def increment_version(version)
      if version =~ /(\d+)\.(\d+)\.(\d+)/
        major = ::Regexp.last_match(1).to_i
        minor = ::Regexp.last_match(2).to_i
        patch = ::Regexp.last_match(3).to_i
        "#{major}.#{minor}.#{patch + 1}"
      else
        "#{version}.1"
      end
    end
  end
end
