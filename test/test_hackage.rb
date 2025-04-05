# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'tempfile'

class TestHackage < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@temp_dir)
  end

  # NOTE: Most of Hackage functionality requires access to Hackage
  # and a real Haskell package, making it difficult to test fully in isolation.
  # These basic tests verify the class structure.

  def test_hackage_initialization
    hackage = Haskbrew::Hackage.new(false) # non-interactive mode

    # Make sure it initializes without errors
    assert_instance_of Haskbrew::Hackage, hackage
  end
end
