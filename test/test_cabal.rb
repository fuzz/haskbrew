# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tempfile"

class TestCabal < Minitest::Test
  def setup
    @fixture_path = File.join(File.dirname(__FILE__), "fixtures", "sample.cabal")

    # Create a temp copy of the fixture for tests that modify the file
    @temp_file = Tempfile.new(["sample", ".cabal"])
    FileUtils.copy(@fixture_path, @temp_file.path)
  end

  def teardown
    @temp_file.close
    @temp_file.unlink
  end

  def test_parsing_cabal_file
    cabal = Haskbrew::Cabal.new(@fixture_path)

    # Test basic attributes
    assert_equal "sample-project", cabal.name
    assert_equal "0.1.0", cabal.version
  end

  def test_updating_version
    cabal = Haskbrew::Cabal.new(@temp_file.path)
    assert_equal "0.1.0", cabal.version

    # Update the version
    cabal.update_version("0.2.0")

    # Check that the version was updated in the object
    assert_equal "0.2.0", cabal.version

    # Read the file again to verify the change was written
    new_cabal = Haskbrew::Cabal.new(@temp_file.path)
    assert_equal "0.2.0", new_cabal.version
  end

  def test_extracting_dependencies
    cabal = Haskbrew::Cabal.new(@fixture_path)

    # Check that we can extract dependencies
    deps = cabal.dependencies
    assert deps.is_a?(Array), "Dependencies should be an array"
    assert_includes deps, "base", "Should extract 'base' dependency"
    assert_includes deps, "text", "Should extract 'text' dependency"
  end
end
