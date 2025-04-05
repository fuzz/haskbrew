# frozen_string_literal: true

require 'fileutils'
require 'toml-rb'
require 'sorbet-runtime'

module Haskbrew
  # Manages configuration for Haskbrew
  class Config
    extend T::Sig

    CONFIG_DIR = File.expand_path('~/.config/haskbrew').freeze
    CONFIG_FILE = File.join(CONFIG_DIR, 'config.toml').freeze

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def self.load
      ensure_config_exists

      begin
        config = TomlRB.load_file(CONFIG_FILE)
        symbolize_keys(config)
      rescue StandardError => e
        puts "Error loading config: #{e.message}"
        {}
      end
    end

    sig { params(config: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
    def self.save(config)
      ensure_config_exists

      begin
        File.write(CONFIG_FILE, TomlRB.dump(stringify_keys(config)))
        true
      rescue StandardError => e
        puts "Error saving config: #{e.message}"
        false
      end
    end

    sig { params(key: Symbol, value: T.untyped).returns(T::Boolean) }
    def self.set(key, value)
      config = load
      config[key] = value
      save(config)
    end

    sig { params(key: Symbol).returns(T.untyped) }
    def self.get(key)
      config = load
      config[key]
    end

    sig { params(interactive: T::Boolean).returns(T::Hash[Symbol, T.untyped]) }
    def self.setup_credentials(interactive = true)
      config = load

      if interactive
        # Prompt for credentials
        puts 'Setting up Hackage credentials:'
        print 'Hackage username: '
        username = gets.chomp

        print 'Hackage password (input will be hidden): '
        system('stty -echo')
        password = gets.chomp
        system('stty echo')
        puts

        puts 'Setting up GitHub credentials:'
        print 'GitHub token (for bottle uploads): '
        system('stty -echo')
        github_token = gets.chomp
        system('stty echo')
        puts

        # Save credentials
        config[:hackage_username] = username
        config[:hackage_password] = password
        config[:github_token] = github_token

        save(config)
      end

      config
    end

    sig { returns(NilClass) }
    def self.ensure_config_exists
      FileUtils.mkdir_p(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)

      unless File.exist?(CONFIG_FILE)
        default_config = {
          hackage_username: '',
          hackage_password: '',
          github_token: '',
          default_formula_template: 'standard',
          bottle_platforms: ['arm64_monterey']
        }

        File.write(CONFIG_FILE, TomlRB.dump(default_config))
      end

      nil
    end

    sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
    def self.symbolize_keys(hash)
      result = {}
      hash.each do |key, value|
        result[key.to_sym] = if value.is_a?(Hash)
                               symbolize_keys(value)
                             else
                               value
                             end
      end
      result
    end

    sig { params(hash: T::Hash[Symbol, T.untyped]).returns(T::Hash[String, T.untyped]) }
    def self.stringify_keys(hash)
      result = {}
      hash.each do |key, value|
        result[key.to_s] = if value.is_a?(Hash)
                             stringify_keys(value)
                           else
                             value
                           end
      end
      result
    end
  end
end
