⏺ Haskbrew Implementation Plan

  1. Cabal Module Recommendations

  For releasing to Hackage, we need the Cabal parser to be more than just version handling. We should keep
  a robust parser that can:

  - Parse and manipulate version information (already done)
  - Extract core metadata for Hackage uploads
  - Identify dependencies for proper documentation building

  The parser should be sufficient but not overly complex. Our current implementation is a good balance - it
   focuses on the core needs without trying to be a complete Cabal file parser.

  2. Key Module Implementation Plan

  Core Modules

  1. HackagePublisher
    - Handle authentication with Hackage
    - Create source distributions (cabal sdist)
    - Build and package documentation (cabal haddock)
    - Upload to Hackage with proper credentials
  2. HomebrewFormula
    - Template-based formula generation
    - SHA calculation for Hackage packages
    - Formula patching for version updates
    - Support for bottle specifications
  3. BottleBuilder
    - Build bottles for different platforms
    - Upload bottles to GitHub releases
    - Generate bottle SHA for Homebrew formulas
  4. CLI Interface
    - Command structure with Thor
    - Interactive prompts with TTY
    - Common commands: release, bump, bottle
    - Config commands for Hackage/GitHub credentials

  Support Modules

  1. ConfigManager
    - Store configuration in TOML
    - Manage Hackage/GitHub credentials
    - Store project-specific settings
  2. ChangelogHandler
    - Parse and update CHANGELOG.md
    - Generate release notes for GitHub

  3. Implementation Workflow

  1. Start with the HomebrewFormula module - this is the most critical for your current needs
  2. Next implement the CLI Interface for basic commands
  3. Then add HackagePublisher for complete Hackage integration
  4. Finally add BottleBuilder to complete the workflow

  4. Considerations for Development

  1. Credential Management
    - Use secure credential storage
    - Support both environment variables and config files
    - Never hardcode or expose sensitive information
  2. Testing Strategy
    - Unit tests for each module
    - Mock external systems (Hackage, GitHub)
    - Integration tests with fake repositories
  3. Error Handling
    - Clear error messages for common failures
    - Graceful recovery options when possible
    - Detailed logging for debugging
  4. Platform Compatibility
    - Ensure it works on macOS (primary target)
    - Consider Linux compatibility for CI environments
    - Document Windows limitations if applicable

  5. Sample Usage Examples

  # Basic version bump
  haskbrew bump 0.2.0

  # Complete release process
  haskbrew release --hackage --homebrew

  # Just update formula
  haskbrew formula update

  # Build bottles for current platform
  haskbrew bottle build
