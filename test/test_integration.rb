# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'tempfile'

class TestIntegration < Minitest::Test
  def setup
    # Create a temporary directory to work in
    @temp_dir = Dir.mktmpdir
    @cabal_path = File.join(@temp_dir, 'test.cabal')
    @changelog_path = File.join(@temp_dir, 'CHANGELOG.md')

    # Create a sample cabal file
    File.write(@cabal_path, <<~CABAL)
      name:                test
      version:             0.1.0
      synopsis:            Test package
      description:         Test package description
      license:             MIT
      author:              Test Author
      maintainer:          test@example.com
      build-type:          Simple
      cabal-version:       >=1.10

      library
        exposed-modules:     Test
        build-depends:       base >=4.13 && <5
        default-language:    Haskell2010
    CABAL

    # Create a sample changelog
    File.write(@changelog_path, <<~CHANGELOG)
      # Changelog

      ## [0.1.0] - 2024-04-01

      - Initial release
    CHANGELOG

    # Store the current directory
    @original_dir = Dir.pwd

    # Change to the temp directory
    Dir.chdir(@temp_dir)

    # Override stdin for non-interactive testing
    @original_stdin = $stdin
    $stdin = StringIO.new("\n")
  end

  def teardown
    # Restore original directory
    Dir.chdir(@original_dir)

    # Clean up temp directory
    FileUtils.rm_rf(@temp_dir)

    # Restore stdin
    $stdin = @original_stdin
  end

  def test_non_interactive_release
    # Create core instance
    core = Haskbrew::Core.new

    # Run release in non-interactive mode
    result = core.release('0.1.1', interactive: false)

    # Check that the release was successful
    assert result

    # Check that the cabal version was updated
    cabal_content = File.read(@cabal_path)
    assert_includes cabal_content, 'version: 0.1.1'

    # Check that the changelog was updated
    changelog_content = File.read(@changelog_path)
    assert_includes changelog_content, '## [0.1.1]'
  end

  def test_version_incrementing
    # Test the increment_version method directly
    test_cases = {
      '1.0.0' => '1.0.1',
      '0.1.2' => '0.1.3',
      '0.0.0' => '0.0.1',
      '1.0' => '1.0.1',
      'abc' => 'abc.1'
    }

    # Create a Core instance
    instance = Haskbrew::Core.new

    # Get the private method
    increment_method = Haskbrew::Core.instance_method(:increment_version)
    increment_method = increment_method.bind(instance)

    # Test each case
    test_cases.each do |current, expected|
      actual = increment_method.call(current)
      assert_equal expected, actual, "Failed for input: #{current}"
    end
  end
end
