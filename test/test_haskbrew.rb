# frozen_string_literal: true

require 'test_helper'

class TestHaskbrew < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Haskbrew::VERSION
  end

  def test_core_modules_loaded
    assert defined?(Haskbrew::Cabal), 'Cabal module should be loaded'
  end
end
