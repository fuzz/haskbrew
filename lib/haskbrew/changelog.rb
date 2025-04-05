# frozen_string_literal: true

require 'date'
require 'sorbet-runtime'

module Haskbrew
  # Manages changelog updates and version entries
  class Changelog
    extend T::Sig

    sig { params(version: String, project_root: String, interactive: T::Boolean).returns(T::Boolean) }
    def self.update(version, project_root, interactive = true)
      changelog_path = File.join(project_root, 'CHANGELOG.md')
      today = Date.today.strftime('%Y-%m-%d')

      # Create file if it doesn't exist
      File.write(changelog_path, "# Changelog\n\n") unless File.exist?(changelog_path)

      content = File.read(changelog_path)

      # Check if this version already exists in changelog
      return true if content.include?("## [#{version}]")

      # Insert new version entry after the header
      new_content = content.sub(/^# Changelog/,
                                "# Changelog\n\n## [#{version}] - #{today}\n\n- Add your changes here\n\n")

      File.write(changelog_path, new_content)

      # Open editor for user to edit changelog if in interactive mode
      if interactive
        editor = ENV['EDITOR'] || 'nano'
        puts 'Opening CHANGELOG.md for editing. Please add your release notes.'
        system("#{editor} #{changelog_path}")
        puts 'Press Enter to continue with the release process...'
        gets
      end

      true
    end

    sig { params(project_root: String).returns(T::Hash[String, String]) }
    def self.generate_release_notes(project_root)
      changelog_path = File.join(project_root, 'CHANGELOG.md')

      return { version: 'unknown', notes: 'No changelog found' } unless File.exist?(changelog_path)

      content = File.read(changelog_path)

      # Extract the latest version entry
      if content =~ /## \[([^\]]+)\][^\n]*\n\n(.*?)(?=\n## |\Z)/m
        version = ::Regexp.last_match(1)
        notes = ::Regexp.last_match(2).strip

        return { version: version, notes: notes }
      end

      { version: 'unknown', notes: 'Could not extract release notes' }
    end
  end
end
