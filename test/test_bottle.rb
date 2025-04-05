# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'tempfile'

class TestBottle < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@temp_dir)
  end

  # NOTE: Most of Bottle functionality requires actual Homebrew installation
  # and GitHub access, making it difficult to test fully in isolation.
  # These basic tests verify the class structure.

  def test_bottle_initialization
    bottle = Haskbrew::Bottle.new(false) # non-interactive mode

    # Make sure it initializes without errors
    assert_instance_of Haskbrew::Bottle, bottle
  end
end
