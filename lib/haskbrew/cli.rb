# frozen_string_literal: true

require 'thor'
require 'haskbrew/version'
require 'haskbrew/cabal'
require 'haskbrew/hackage'
require 'haskbrew/homebrew'
require 'haskbrew/bottle'
require 'haskbrew/config'
require 'haskbrew/changelog'

module Haskbrew
  # CLI interface for Haskbrew commands
  class CLI < Thor
    desc 'version', 'Display Haskbrew version'
    def version
      puts "Haskbrew version #{Haskbrew::VERSION}"
    end

    desc 'release', 'Release a new version of a Haskell package to Hackage and Homebrew'
    option :non_interactive, type: :boolean, desc: 'Run in non-interactive mode (for CI, testing)'
    option :version, type: :string, desc: 'Version to release (for non-interactive mode)'
    option :skip_hackage, type: :boolean, desc: 'Skip uploading to Hackage'
    option :skip_bottles, type: :boolean, desc: 'Skip building Homebrew bottles'
    option :skip_github, type: :boolean, desc: 'Skip uploading to GitHub'
    def release
      interactive = !options[:non_interactive]

      project_root = Dir.pwd
      cabal_file = find_cabal_file(project_root)

      if cabal_file.nil?
        puts 'Error: No .cabal file found in current directory or subdirectories'
        exit 1
      end

      cabal = Cabal.new(cabal_file)

      current_version = cabal.version
      puts "Current version: #{current_version}"

      # Determine new version
      if options[:version] && !options[:version].empty?
        new_version = options[:version]
      elsif interactive
        suggested_version = increment_version(current_version)
        new_version = prompt('Enter new version', suggested_version)
      else
        new_version = increment_version(current_version)
      end

      puts "Preparing release for version #{new_version}"

      # Update cabal version
      cabal.update_version(new_version)
      puts "Updated .cabal file to version #{new_version}"

      # Update changelog
      if File.exist?('CHANGELOG.md')
        Changelog.update(new_version, project_root, interactive)
        puts 'Updated CHANGELOG.md with new version entry'
      end

      # Run tests
      puts 'Running tests to verify everything works...'
      unless system('bundle exec rake test')
        puts 'Tests failed. Aborting release process.'
        exit 1 unless yes_no_prompt('Continue anyway?', false) && interactive
      end

      # Commit changes if in interactive mode
      if interactive && yes_no_prompt('Commit version bump and changelog?')
        system("git add #{cabal_file} CHANGELOG.md")
        system("git commit -m \"Bump version to #{new_version}\"")

        system('git push origin main') if yes_no_prompt('Push changes to origin?')

        if yes_no_prompt("Create tag v#{new_version}?")
          if system("git rev-parse v#{new_version} >/dev/null 2>&1")
            if yes_no_prompt('Tag already exists. Update it?')
              system("git tag -fa v#{new_version} -m \"Release version #{new_version}\"")
            end
          else
            system("git tag -a v#{new_version} -m \"Release version #{new_version}\"")
          end

          system("git push origin v#{new_version}") if yes_no_prompt('Push tag to origin?')
        end
      end

      # Upload to Hackage
      unless options[:skip_hackage]
        puts 'Preparing for Hackage release...'
        hackage = Hackage.new(interactive)

        if interactive
          uploaded = hackage.publish(new_version)
        else
          # In non-interactive mode, use credentials from config
          config = Config.load
          uploaded = hackage.publish_non_interactive(new_version, config[:hackage_username], config[:hackage_password])
        end

        if uploaded
          puts 'Successfully published to Hackage!'

          # Calculate package SHA for Homebrew
          sha256 = hackage.calculate_package_sha256(new_version)

          # Update Homebrew formula
          if sha256
            puts 'Updating Homebrew formula...'
            formula = Homebrew.new(interactive)
            formula.update(new_version, sha256)

            # Build bottle if requested
            unless options[:skip_bottles]
              puts 'Building Homebrew bottle...'
              bottle = Bottle.new(interactive)
              bottle_info = bottle.build(new_version)

              if bottle_info && !options[:skip_github]
                puts 'Uploading bottle to GitHub...'
                bottle.upload_to_github(new_version, bottle_info)

                puts 'Updating formula with bottle information...'
                formula.update_bottle_info(bottle_info)
              end
            end
          end
        end
      end

      puts 'Release process complete!'
    end

    desc 'config_setup', 'Set up configuration'
    def config_setup
      Config.setup_credentials(true)
      puts 'Configuration setup complete.'
    end

    desc 'config_get', 'Get a configuration value'
    def config_get(key)
      value = Config.get(key.to_sym)
      puts "#{key}: #{value}"
    end

    desc 'config_set', 'Set a configuration value'
    def config_set(key, value)
      Config.set(key.to_sym, value)
      puts "Set #{key} = #{value}"
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

    def prompt(message, default = nil)
      if default
        print "#{message} [#{default}]: "
      else
        print "#{message}: "
      end
      input = $stdin.gets.chomp.strip
      input.empty? ? default : input
    end

    def yes_no_prompt(message, default_no = true)
      default = default_no ? '[y/N]' : '[Y/n]'
      print "#{message} #{default} "
      response = $stdin.gets.chomp.downcase
      return response.start_with?('y') if default_no

      !response.start_with?('n')
    end
  end
end
