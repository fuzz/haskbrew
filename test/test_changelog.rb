# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'tempfile'

class TestChangelog < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir
    @changelog_path = File.join(@temp_dir, 'CHANGELOG.md')

    # Create a sample changelog
    File.write(@changelog_path, <<~CHANGELOG)
      # Changelog

      ## [0.1.2] - 2024-04-01

      - Fixed bug in file processing
      - Added new feature X

      ## [0.1.1] - 2024-03-15

      - Initial release
    CHANGELOG

    # Mock stdin to avoid blocking on gets
    @original_stdin = $stdin
    $stdin = StringIO.new("\n")
  end

  def teardown
    # Clean up temp directory
    FileUtils.rm_rf(@temp_dir)

    # Restore original stdin
    $stdin = @original_stdin
  end

  def test_update_with_new_version
    # Also override ENV['EDITOR'] to avoid actually opening an editor
    original_editor = ENV['EDITOR']
    ENV['EDITOR'] = 'echo'

    # Run the update with interactive = false to avoid gets
    Haskbrew::Changelog.update('0.1.3', @temp_dir, false)

    # Restore EDITOR
    ENV['EDITOR'] = original_editor

    # Verify changelog was updated
    content = File.read(@changelog_path)
    assert_includes content, '## [0.1.3] -'
    assert_includes content, '- Add your changes here'

    # The original entries should still be there
    assert_includes content, '## [0.1.2] - 2024-04-01'
    assert_includes content, '## [0.1.1] - 2024-03-15'
  end

  def test_existing_version_not_duplicated
    # First add version 0.1.3
    Haskbrew::Changelog.update('0.1.3', @temp_dir, false)

    # Try to add it again
    result = Haskbrew::Changelog.update('0.1.3', @temp_dir, false)

    # It should return true and not duplicate the entry
    assert result

    content = File.read(@changelog_path)
    assert_equal 1, content.scan(/## \[0\.1\.3\]/).size
  end

  def test_generate_release_notes
    # Add a version entry
    Haskbrew::Changelog.update('0.1.3', @temp_dir, false)

    # Manually update the release notes (since we're not using an editor)
    content = File.read(@changelog_path)
    content.gsub!('- Add your changes here', "- Feature A\n- Bug fix B")
    File.write(@changelog_path, content)

    # Generate release notes
    notes = Haskbrew::Changelog.generate_release_notes(@temp_dir)

    assert_equal '0.1.3', notes[:version]
    assert_includes notes[:notes], 'Feature A'
    assert_includes notes[:notes], 'Bug fix B'
  end

  def test_create_changelog_if_missing
    # Remove the changelog
    FileUtils.rm(@changelog_path)

    # Update should create a new one
    Haskbrew::Changelog.update('0.1.0', @temp_dir, false)

    assert File.exist?(@changelog_path)
    content = File.read(@changelog_path)
    assert_includes content, '# Changelog'
    assert_includes content, '## [0.1.0]'
  end
end
