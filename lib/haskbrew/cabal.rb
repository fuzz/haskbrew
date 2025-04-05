# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module Haskbrew
  # Minimal Cabal file handler for version management
  class Cabal
    extend T::Sig

    sig { returns(String) }
    attr_reader :version

    sig { returns(String) }
    attr_reader :name

    sig { returns(String) }
    attr_reader :file_path

    sig { params(file_path: String).void }
    def initialize(file_path)
      @file_path = file_path
      @content = T.let(File.read(file_path), String)

      # Extract name and version with specific regexes
      @name = T.let(extract_field('name'), String)
      @version = T.let(extract_field('version'), String)
    end

    sig { params(new_version: String).returns(String) }
    def update_version(new_version)
      # Update the version field in the file content
      updated_content = @content.sub(/^version:\s*[0-9.]+/, "version: #{new_version}")

      # Only write if something actually changed
      if updated_content != @content
        File.write(@file_path, updated_content)
        # These variables are already declared in initialize, so we don't use T.let again
        @content = updated_content
        @version = new_version
      end

      new_version
    end

    # Get essential dependencies for version calculations
    sig { returns(T::Array[String]) }
    def dependencies
      # Extract all build-depends lines
      deps = []

      @content.scan(/build-depends:.*?(?=\n\S|\Z)/m).each do |match|
        # Extract package names without version constraints
        match_str = T.cast(match, String)
        match_str.scan(/\b([a-zA-Z][a-zA-Z0-9-]*)[,\s<>=]/).each do |dep_arr|
          # dep_arr is an array where the first element is the capture group
          deps << dep_arr[0]
        end
      end

      deps.uniq
    end

    private

    sig { params(field: String).returns(String) }
    def extract_field(field)
      # Use a specific regex targeting the field at the beginning of a line
      # followed by colon and whitespace
      if @content =~ /^#{field}:\s*([^\n]+)/
        T.must(::Regexp.last_match(1)).strip
      else
        ''
      end
    end
  end
end
