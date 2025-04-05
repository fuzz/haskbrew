# Haskbrew

Haskbrew is a Ruby gem that automates the release process for Haskell packages to both Hackage and Homebrew. It streamlines the workflow of releasing Haskell packages by handling version updates, changelog management, Hackage publishing, and Homebrew formula updates.

## Features

- **Cabal Integration**: Parse and update Cabal files with version bumps
- **Changelog Management**: Auto-update CHANGELOG.md with new version entries
- **Hackage Publishing**: Publish packages to Hackage with documentation
- **Homebrew Formula Generation**: Update Homebrew formulas with new versions and SHAs
- **Bottle Building**: Build and publish Homebrew bottles to GitHub
- **Non-interactive Mode**: Support for CI/CD pipelines and automated testing

## Installation

Install the gem by executing:

```bash
gem install haskbrew
```

## Usage

### Command Line Interface

The primary interface is through the `haskbrew` command:

```bash
# Interactive release process
haskbrew release

# Non-interactive release with specific version
haskbrew release --non-interactive --version 0.1.2

# Skip specific steps
haskbrew release --skip-hackage --skip-bottles

# Show version
haskbrew version
```

### Non-interactive Release Script

For CI/CD pipelines, you can use the included release script:

```bash
# Basic usage
bin/release --version 0.1.2

# Skip specific steps
bin/release --version 0.1.2 --skip-hackage --skip-bottles

# Run in interactive mode
bin/release --interactive
```

### Configuration

Haskbrew stores configuration in `~/.config/haskbrew/config.toml`. For non-interactive usage, you should set up your Hackage credentials:

```bash
# Setup credentials
haskbrew config setup

# Manually set credentials
haskbrew config set hackage_username "your-username"
haskbrew config set hackage_password "your-password"
haskbrew config set github_token "your-token"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt.

### Running Tests

```bash
# Run all tests
bundle exec rake test

# Run a specific test
bundle exec ruby -I lib:test test/test_cabal.rb -n test_name
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).