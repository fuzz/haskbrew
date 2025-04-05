# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'tempfile'

class TestHomebrew < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
    @formula_file = File.join(@temp_dir, 'test_formula.rb')

    # Create a sample formula file
    File.write(@formula_file, <<~FORMULA)
      class TestFormula < Formula
        desc "Test formula for Haskbrew"
        homepage "https://github.com/test/test-formula"
        url "https://hackage.haskell.org/package/test-formula-0.1.2/test-formula-0.1.2.tar.gz"
        sha256 "abc123def456"
        license "MIT"

        depends_on "cabal-install" => :build
        depends_on "ghc" => "9.4"

        bottle do
          root_url "https://github.com/test/test-formula/releases/download/v0.1.2"
          rebuild 1
          sha256 cellar: :any, arm64_monterey: "98765abcdef"
        end

        def install
          system "cabal", "v2-update"
          system "cabal", "v2-install", *std_cabal_v2_args
        end

        test do
          system bin/"test-formula", "--version"
        end
      end
    FORMULA

    # Set up a mock implementation of the class for testing
    @formula = Haskbrew::Homebrew.new(false) # non-interactive

    # Add test methods to override private methods
    def @formula.test_update(version, sha256, formula_path)
      @formula_path = formula_path

      # Override package_name method for testing
      def self.package_name
        'test-formula'
      end

      update(version, sha256)
    end

    def @formula.test_update_bottle(bottle_info, formula_path)
      @formula_path = formula_path
      update_bottle_info(bottle_info)
    end
  end

  def teardown
    # Clean up temp directory
    FileUtils.rm_rf(@temp_dir)
  end

  def test_update_formula
    # Test updating the formula with new version and SHA
    result = @formula.test_update('0.1.3', 'new_sha_0123456789', @formula_file)

    assert result
    content = File.read(@formula_file)

    # URL should be updated
    assert_includes content, 'test-formula-0.1.3.tar.gz'
    refute_includes content, 'test-formula-0.1.2.tar.gz'

    # SHA should be updated
    assert_includes content, 'sha256 "new_sha_0123456789"'
    refute_includes content, 'sha256 "abc123def456"'

    # Root URL should be updated
    assert_includes content, 'root_url'

    # SHA should match
    assert_includes content, 'new_sha_0123456789'
  end

  def test_update_bottle_info
    # Test updating bottle information
    bottle_info = {
      version: '0.1.3',
      sha256: 'new_bottle_sha_0123456789',
      macos_version: 'ventura',
      rebuild: 2
    }

    result = @formula.test_update_bottle(bottle_info, @formula_file)

    assert result
    content = File.read(@formula_file)

    # SHA should be updated with new macOS version
    assert_includes content, 'sha256 cellar: :any, arm64_ventura: "new_bottle_sha_0123456789"'
    refute_includes content, 'sha256 cellar: :any, arm64_monterey: "98765abcdef"'

    # Rebuild should be updated
    assert_includes content, 'rebuild 2'
    refute_includes content, 'rebuild 1'
  end

  def test_formula_without_bottle
    # Create a formula without a bottle section
    no_bottle_file = File.join(@temp_dir, 'no_bottle.rb')
    File.write(no_bottle_file, <<~FORMULA)
      class TestFormula < Formula
        desc "Test formula for Haskbrew"
        homepage "https://github.com/test/test-formula"
        url "https://hackage.haskell.org/package/test-formula-0.1.2/test-formula-0.1.2.tar.gz"
        sha256 "abc123def456"
        license "MIT"

        depends_on "cabal-install" => :build
        depends_on "ghc" => "9.4"

        def install
          system "cabal", "v2-install", *std_cabal_v2_args
        end
      end
    FORMULA

    # Add bottle info
    bottle_info = {
      version: '0.1.3',
      sha256: 'bottle_sha_xyz',
      macos_version: 'ventura'
    }

    result = @formula.test_update_bottle(bottle_info, no_bottle_file)

    assert result
    content = File.read(no_bottle_file)

    # A new bottle block should be added
    assert_includes content, 'bottle do'
    assert_includes content, 'root_url'
    assert_includes content, 'sha256 cellar: :any, arm64_ventura: "bottle_sha_xyz"'
  end
end
