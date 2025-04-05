# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class TestConfig < Minitest::Test
  def setup
    # Save original config location
    @original_config_dir = Haskbrew::Config::CONFIG_DIR
    @original_config_file = Haskbrew::Config::CONFIG_FILE

    # Create a temp directory for config
    @temp_dir = Dir.mktmpdir

    # Override constants for testing
    Haskbrew::Config.send(:remove_const, :CONFIG_DIR)
    Haskbrew::Config.const_set(:CONFIG_DIR, @temp_dir)

    Haskbrew::Config.send(:remove_const, :CONFIG_FILE)
    Haskbrew::Config.const_set(:CONFIG_FILE, File.join(@temp_dir, 'config.toml'))
  end

  def teardown
    # Clean up temp directory
    FileUtils.rm_rf(@temp_dir)

    # Restore original constants
    Haskbrew::Config.send(:remove_const, :CONFIG_DIR)
    Haskbrew::Config.const_set(:CONFIG_DIR, @original_config_dir)

    Haskbrew::Config.send(:remove_const, :CONFIG_FILE)
    Haskbrew::Config.const_set(:CONFIG_FILE, @original_config_file)
  end

  def test_load_creates_default_config
    # Config shouldn't exist yet
    refute File.exist?(Haskbrew::Config::CONFIG_FILE)

    # Loading should create the default config
    config = Haskbrew::Config.load

    # The file should now exist
    assert File.exist?(Haskbrew::Config::CONFIG_FILE)

    # Check default values
    assert_equal '', config[:hackage_username]
    assert_equal '', config[:hackage_password]
    assert_equal '', config[:github_token]
    assert_includes config.keys, :bottle_platforms
  end

  def test_save_and_load_config
    # Create a test config
    test_config = {
      hackage_username: 'testuser',
      hackage_password: 'testpass',
      github_token: 'testtoken',
      custom_field: 'custom value'
    }

    # Save it
    result = Haskbrew::Config.save(test_config)
    assert result

    # Load it back
    loaded_config = Haskbrew::Config.load

    # Check values
    assert_equal 'testuser', loaded_config[:hackage_username]
    assert_equal 'testpass', loaded_config[:hackage_password]
    assert_equal 'testtoken', loaded_config[:github_token]
    assert_equal 'custom value', loaded_config[:custom_field]
  end

  def test_get_and_set
    # Set a value
    Haskbrew::Config.set(:test_key, 'test_value')

    # Get it back
    value = Haskbrew::Config.get(:test_key)

    assert_equal 'test_value', value

    # Update the value
    Haskbrew::Config.set(:test_key, 'updated_value')

    # Get it again
    updated = Haskbrew::Config.get(:test_key)

    assert_equal 'updated_value', updated
  end
end
