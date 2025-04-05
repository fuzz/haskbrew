# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test/Lint Commands
- Run all tests: `bundle exec rake test`
- Run single test: `bundle exec ruby -I lib:test test/test_file.rb -n test_name`
- Run lint/style check: `bundle exec rake standard`
- Run all checks: `bundle exec rake` (runs both tests and standard)

## Code Style Guidelines
- Ruby version: >= 3.1.0
- Use frozen_string_literal: true at the top of all Ruby files
- Use Sorbet for type checking:
  - Add type signatures (sig) for all methods
  - Development: `bundle exec srb tc`
- Follow Standard Ruby style (based on RuboCop)
- Naming conventions:
  - Use snake_case for methods and variables
  - Use CamelCase for classes and modules
- Error handling:
  - Prefer exceptions with descriptive messages
  - Handle errors at appropriate levels
- Imports:
  - Group standard library requires first
  - Then gem requires
  - Finally relative requires
- Write comprehensive tests for all functionality