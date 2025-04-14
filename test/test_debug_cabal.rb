# frozen_string_literal: true

require 'test_helper'

class TestDebugCabal < Minitest::Test
  def test_debug_parsing
    # Direct path to the fixture file
    fixture_path = File.join(File.dirname(__FILE__), 'fixtures', 'sample.cabal')

    # Read the file contents for debugging
    puts '=== FIXTURE FILE CONTENTS ==='
    contents = File.read(fixture_path)
    puts contents
    puts '=== END FIXTURE FILE ==='

    # Try to parse the file
    cabal = Bruh::Cabal.new(fixture_path)

    # Print parsed content for debugging
    puts '=== PARSED CONTENT ==='
    puts "Name: #{cabal.name.inspect}"
    puts "Version: #{cabal.version.inspect}"
    puts "Dependencies: #{cabal.dependencies.inspect}"

    # Verify that the cabal file was parsed properly
    assert_equal 'sample-project', cabal.name
    assert_equal '0.1.0', cabal.version
  end
end
