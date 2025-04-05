# typed: strict
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'sorbet-runtime'

module Haskbrew
  # Builds and manages Homebrew bottles
  class Bottle
    extend T::Sig

    sig { params(interactive: T::Boolean).void }
    def initialize(interactive = true)
      @interactive = interactive
      @tap_dir = T.let(find_homebrew_tap, T.nilable(String))
    end

    sig { params(version: String).returns(T.nilable(T::Hash[Symbol, T.untyped])) }
    def build(version)
      return nil unless @tap_dir

      return nil if @interactive && !yes_no_prompt('Do you want to build a Homebrew bottle for this release?')

      puts "Building bottle for #{package_name} formula..."

      Dir.chdir(@tap_dir) do
        # Clean environment - uninstall any existing version
        system("brew uninstall --force #{package_name} 2>/dev/null || true")

        # Ensure tap is properly set up
        tap_name = "#{repo_owner}/tap"
        system("brew untap #{tap_name} 2>/dev/null || true")
        system("brew tap #{tap_name} \"$(pwd)\"")

        # Install with build-bottle flag
        unless system("brew install --build-bottle #{tap_name}/#{package_name}")
          puts 'Failed to install formula with --build-bottle flag'
          return nil
        end

        # Create bottle with JSON output
        unless system("brew bottle --json --root-url=\"https://github.com/#{repo_owner}/#{repo_name}/releases/download/v#{version}\" #{tap_name}/#{package_name}")
          puts 'Failed to create bottle'
          return nil
        end

        # Find the JSON file created by brew bottle
        bottle_json = Dir['*.json'].sort_by { |f| File.mtime(f) }.last

        unless bottle_json && File.exist?(bottle_json)
          puts 'Could not find bottle JSON file'
          return nil
        end

        # Parse the JSON file
        bottle_data = JSON.parse(File.read(bottle_json))

        # Extract filenames and other data
        first_entry = bottle_data.values.first
        first_tag = first_entry['bottle']['tags'].values.first

        bottle_info = {
          version: version,
          expected_filename: first_tag['filename'],
          local_filename: first_tag['local_filename'],
          sha256: first_tag['sha256'],
          macos_version: first_entry['bottle']['tags'].keys.first.to_s.split('_')[1]
        }

        # Extract rebuild number from filename if present
        bottle_info[:rebuild] = ::Regexp.last_match(1).to_i if bottle_info[:local_filename] =~ /bottle\.(\d+)/

        # Verify the bottle file exists
        unless File.exist?(bottle_info[:local_filename])
          puts "Bottle file not found: #{bottle_info[:local_filename]}"
          return nil
        end

        # Create bottles directory and move the file
        FileUtils.mkdir_p('bottles')
        FileUtils.mv(bottle_info[:local_filename], 'bottles/')

        puts "Bottle created successfully: bottles/#{bottle_info[:local_filename]}"
        bottle_info
      end
    end

    sig { params(version: String, bottle_info: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
    def upload_to_github(version, bottle_info)
      # Check for GitHub CLI
      unless system('which gh > /dev/null 2>&1')
        puts 'GitHub CLI (gh) not found. Please install it to automate bottle uploads.'
        return false
      end

      return false if @interactive && !yes_no_prompt('Do you want to upload bottle to GitHub?')

      # Remember current directory
      original_dir = Dir.pwd

      # Change to the tap directory
      Dir.chdir(T.must(@tap_dir)) do
        # Check if release exists
        release_exists = system("gh release view \"v#{version}\" &>/dev/null")

        unless release_exists
          puts "Release v#{version} doesn't exist. Creating it now..."
          unless system("gh release create \"v#{version}\" --title \"Release v#{version}\" --notes \"Release v#{version} with Homebrew bottle support.\"")
            puts 'Failed to create GitHub release'
            return false
          end
        end

        # Rename the bottle file to expected filename
        bottle_src = File.join('bottles', bottle_info[:local_filename])
        bottle_dst = File.join('bottles', bottle_info[:expected_filename])

        FileUtils.mv(bottle_src, bottle_dst) unless bottle_src == bottle_dst

        # Upload to GitHub release
        puts "Uploading bottle to GitHub release v#{version}..."
        unless system("gh release upload \"v#{version}\" \"#{bottle_dst}\" --clobber")
          puts 'Failed to upload bottle to GitHub'
          Dir.chdir(original_dir)
          return false
        end

        puts 'Bottle uploaded successfully to GitHub release!'
      end

      # Change back to original directory
      Dir.chdir(original_dir)
      true
    end

    private

    sig { returns(T.nilable(String)) }
    def find_homebrew_tap
      # Try common locations
      potential_paths = [
        '../homebrew-tap',
        '~/homebrew-tap',
        '~/Projects/homebrew-tap'
      ]

      potential_paths.each do |path|
        expanded = File.expand_path(path)
        return expanded if Dir.exist?(expanded)
      end

      if @interactive
        puts 'Homebrew tap directory not found in common locations.'
        puts 'Please enter the path to your Homebrew tap directory:'
        tap_dir = gets.chomp.strip
        return tap_dir if !tap_dir.empty? && Dir.exist?(tap_dir)
      end

      nil
    end

    sig { returns(String) }
    def package_name
      # Extract package name from current directory
      File.basename(Dir.pwd)
    end

    sig { returns(T::Array[String]) }
    def repo_info
      # Extract owner and repo from git remote
      remote = `git remote get-url origin`.chomp
      if remote =~ %r{github\.com[:/]([^/]+)/([^/]+)\.git}
        owner = T.let(T.must(::Regexp.last_match(1)), String)
        repo = T.let(T.must(::Regexp.last_match(2)), String)
        return [owner, repo]
      end

      %w[user repo]
    end

    sig { returns(String) }
    def repo_owner
      T.must(repo_info[0])
    end

    sig { returns(String) }
    def repo_name
      T.must(repo_info[1])
    end

    sig { params(message: String, default_no: T::Boolean).returns(T::Boolean) }
    def yes_no_prompt(message, default_no = true)
      return true unless @interactive

      default = default_no ? '[y/N]' : '[Y/n]'
      print "#{message} #{default} "
      response = gets.chomp.downcase
      return response.start_with?('y') if default_no

      !response.start_with?('n')
    end
  end
end
