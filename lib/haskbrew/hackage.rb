# typed: strict
# frozen_string_literal: true

require 'net/http'
require 'digest'
require 'sorbet-runtime'

module Haskbrew
  # Handles interaction with Hackage package manager
  class Hackage
    extend T::Sig

    sig { params(interactive: T::Boolean).void }
    def initialize(interactive = true)
      @interactive = interactive
    end

    sig { params(version: String).returns(T::Boolean) }
    def publish(version)
      puts '=== Ready to upload to Hackage ==='

      package_path = build_package(version)
      return false unless package_path

      if @interactive
        puts 'The following command will upload the package to Hackage:'
        puts "  cabal upload --publish #{package_path}"

        if yes_no_prompt('Do you want to upload to Hackage now?')
          publish_package(package_path)
        else
          puts 'Skipping Hackage upload. Run the command manually when ready.'
          false
        end
      else
        # In non-interactive mode, just publish
        publish_package(package_path)
      end
    end

    sig { params(version: String, username: String, password: String).returns(T::Boolean) }
    def publish_non_interactive(version, username, password)
      package_path = build_package(version)
      return false unless package_path

      # Use HTTP Basic auth with credentials
      cmd = "curl -X PUT --data-binary \"@#{package_path}\" " \
            "-H 'Content-Type: application/x-tar' " \
            "-H 'Content-Encoding: gzip' " \
            "--user \"#{username}:#{password}\" " \
            '"https://hackage.haskell.org/packages/upload"'

      T.must(system(cmd))
    end

    sig { params(version: String).returns(T.nilable(String)) }
    def calculate_package_sha256(version)
      puts '=== Calculating SHA256 for Hackage package ==='

      # Wait for package to be available
      puts 'Waiting for Hackage to process the package (10 seconds)...'
      sleep 10 if @interactive

      package_name = File.basename(Dir.pwd)
      hackage_url = "https://hackage.haskell.org/package/#{package_name}-#{version}/#{package_name}-#{version}.tar.gz"

      max_attempts = 3
      attempt = 1
      sha256 = T.let(nil, T.nilable(String))

      while attempt <= max_attempts && sha256.nil?
        puts "Attempt #{attempt} of #{max_attempts} to calculate SHA256..."

        begin
          uri = URI(hackage_url)
          response = Net::HTTP.get_response(uri)

          if response.is_a?(Net::HTTPSuccess) && !response.body.empty?
            sha256 = Digest::SHA256.hexdigest(response.body)

            # Validate SHA256 format (64 hex chars)
            if sha256 =~ /^[0-9a-f]{64}$/
              puts "Valid SHA256 obtained: #{sha256}"
              break
            else
              puts 'Invalid SHA256 obtained. Retrying...'
              sha256 = T.let(nil, T.nilable(String))
            end
          else
            puts 'Package not available yet or empty response.'
          end
        rescue StandardError => e
          puts "Error downloading package: #{e.message}"
        end

        # Wait before retrying
        wait_time = attempt * 5
        puts "Waiting #{wait_time} seconds before retry..."
        sleep wait_time
        attempt += 1
      end

      if sha256.nil?
        puts "Error: Failed to calculate SHA256 after #{max_attempts} attempts."
        puts 'The package might not be available on Hackage yet.'
        nil
      else
        sha256
      end
    end

    private

    sig { params(version: String).returns(T.nilable(String)) }
    def build_package(version)
      # Run necessary steps to build the package
      puts 'Building documentation for Hackage...'
      unless system('cabal haddock --haddock-for-hackage')
        puts 'Failed to build documentation'
        return nil
      end

      puts 'Creating source distribution...'
      unless system('cabal sdist')
        puts 'Failed to create source distribution'
        return nil
      end

      # Find the generated package file
      package_name = File.basename(Dir.pwd)
      package_path = "dist-newstyle/sdist/#{package_name}-#{version}.tar.gz"

      unless File.exist?(package_path)
        puts "Generated package not found at #{package_path}"
        return nil
      end

      package_path
    end

    sig { params(package_path: String).returns(T::Boolean) }
    def publish_package(package_path)
      puts 'Uploading package to Hackage...'
      T.must(system("cabal upload --publish \"#{package_path}\""))
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
