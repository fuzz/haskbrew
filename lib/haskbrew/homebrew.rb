# frozen_string_literal: true

require 'sorbet-runtime'

module Haskbrew
  # Manages Homebrew formula creation and updates
  class Homebrew
    extend T::Sig

    sig { params(interactive: T::Boolean).void }
    def initialize(interactive = true)
      @interactive = interactive
      @tap_dir = find_homebrew_tap
      @formula_path = find_formula_path
    end

    sig { params(version: String, sha256: String).returns(T::Boolean) }
    def update(version, sha256)
      unless @formula_path && File.exist?(@formula_path)
        puts "Error: Formula file not found at #{@formula_path}"
        return false
      end

      puts "Updating Homebrew formula with new version #{version} and SHA256 #{sha256}..."

      # Read current formula
      formula_content = File.read(@formula_path)

      # Verify markers exist
      unless formula_content.include?('url') && formula_content.include?('sha256')
        puts 'ERROR: Required fields not found in formula. Cannot update safely.'
        return false
      end

      # Update version in URL
      formula_content.gsub!(/url\s+"[^"]+"/, "url \"https://hackage.haskell.org/package/#{package_name}-#{version}/#{package_name}-#{version}.tar.gz\"")

      # Update SHA256
      formula_content.gsub!(/sha256\s+"[a-f0-9]+"/, "sha256 \"#{sha256}\"")

      # Write updated formula
      File.write(@formula_path, formula_content)

      # Verify the update was successful
      updated_content = File.read(@formula_path)
      if !updated_content.include?("#{package_name}-#{version}.tar.gz") ||
         !updated_content.include?("sha256 \"#{sha256}\"")
        puts 'ERROR: Formula update verification failed.'
        return false
      end

      puts 'Formula updated successfully with new version and SHA256.'

      # Commit the changes if interactive
      if @interactive && yes_no_prompt('Commit formula changes?')
        Dir.chdir(File.dirname(@formula_path)) do
          system("git add #{File.basename(@formula_path)}")
          system("git commit -m \"Update formula to version #{version}\"")

          system('git push origin main') if yes_no_prompt('Push formula changes to origin?')
        end
      end

      true
    end

    sig { params(bottle_info: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
    def update_bottle_info(bottle_info)
      unless @formula_path && File.exist?(@formula_path)
        puts 'Error: Formula file not found'
        return false
      end

      macos_version = bottle_info[:macos_version]
      bottle_sha = bottle_info[:sha256]
      rebuild_num = bottle_info[:rebuild] || 0

      formula_content = File.read(@formula_path)

      # Check if bottle block exists
      if formula_content.include?('bottle do')
        # Update existing bottle block

        # Update rebuild directive if needed
        if rebuild_num > 0
          if formula_content =~ /\s+rebuild\s+\d+/
            formula_content.gsub!(/(\s+rebuild\s+)\d+/, "\\1#{rebuild_num}")
          else
            formula_content.gsub!(/(\s+root_url.*)$/, "\\1\n    rebuild #{rebuild_num}")
          end
        else
          # Remove rebuild directive if it exists
          formula_content.gsub!(/\s+rebuild\s+\d+\n/, "\n")
        end

        # Update SHA256 for the specific platform
        if formula_content =~ /sha256\s+cellar:[^,]+,\s+arm64_[^:]+:/
          formula_content.gsub!(/sha256\s+cellar:[^,]+,\s+arm64_[^:]+:\s+"[a-f0-9]+"/,
                                "sha256 cellar: :any, arm64_#{macos_version}: \"#{bottle_sha}\"")
        else
          # Add line for this platform
          formula_content.gsub!(/(\s+root_url\s+"[^"]+".*$)/,
                                "\\1\n    sha256 cellar: :any, arm64_#{macos_version}: \"#{bottle_sha}\"")
        end
      else
        # Create bottle block after sha256 line
        bottle_block = <<~BOTTLE

          bottle do
            root_url "https://github.com/#{repo_owner}/#{repo_name}/releases/download/v#{bottle_info[:version]}"
            sha256 cellar: :any, arm64_#{macos_version}: "#{bottle_sha}"
          end
        BOTTLE

        formula_content.gsub!(/sha256\s+"[a-f0-9]+"/, "\\0#{bottle_block}")
      end

      # Write updated formula
      File.write(@formula_path, formula_content)

      # Verify the update was successful
      updated_content = File.read(@formula_path)
      unless updated_content.include?("arm64_#{macos_version}: \"#{bottle_sha}\"")
        puts 'ERROR: Bottle SHA update failed.'
        return false
      end

      puts 'Bottle information updated successfully.'

      # Commit the changes if interactive
      if @interactive && yes_no_prompt('Commit bottle changes?')
        Dir.chdir(File.dirname(@formula_path)) do
          system("git add #{File.basename(@formula_path)}")
          system("git commit -m \"Add bottle for version #{bottle_info[:version]}\"")

          system('git push origin main') if yes_no_prompt('Push bottle changes to origin?')
        end
      end

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
        tap_dir = gets.chomp.strip
        return tap_dir if !tap_dir.empty? && Dir.exist?(tap_dir)
      end

      nil
    end

    sig { returns(T.nilable(String)) }
    def find_formula_path
      return nil unless @tap_dir

      # Try to find the formula file
      formula_name = package_name
      formula_path = File.join(@tap_dir, 'Formula', "#{formula_name}.rb")

      return formula_path if File.exist?(formula_path)

      # If not found in standard location, try to find elsewhere
      Dir.glob(File.join(@tap_dir, '**', "#{formula_name}.rb")).first
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
      return [::Regexp.last_match(1), ::Regexp.last_match(2)] if remote =~ %r{github\.com[:/]([^/]+)/([^/]+)\.git}

      %w[user repo]
    end

    sig { returns(String) }
    def repo_owner
      repo_info[0]
    end

    sig { returns(String) }
    def repo_name
      repo_info[1]
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
