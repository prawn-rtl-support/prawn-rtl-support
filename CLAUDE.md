# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is prawn-rtl-support, a Ruby gem that provides bidirectional text (RTL/LTR) support for the Prawn PDF generation library. It enables proper rendering of Arabic and other right-to-left languages in PDFs by:
- Using Unicode Bidirectional Algorithm via TwitterCldr for text reordering
- Connecting Arabic letters properly for visual display
- Minimally patching Prawn's text rendering pipeline

## Development Commands

```bash
# Install dependencies
bundle install

# Run test suite
bundle exec rake spec
# or just
rake spec

# Run linting (RuboCop)
bundle exec rubocop

# Open console for experimentation
bin/console

# Build gem locally
bundle exec rake build

# Install gem to local machine
bundle exec rake install
```

## Architecture

The gem patches Prawn by prepending a module to `Prawn::Text::Formatted::Box#original_text`. The core functionality:

1. **lib/prawn/rtl/support.rb**: Main entry point that patches Prawn::Text::Formatted::Box
2. **lib/prawn/rtl/connector.rb**: Core RTL fixing logic with three main methods:
   - `fix_rtl(string)`: Main public API that detects RTL text and processes it
   - `connect(string)`: Applies Arabic letter connection rules
   - `reorder(string)`: Uses TwitterCldr's Bidi algorithm to reorder text visually
3. **lib/prawn/rtl/connector/logic.rb**: Arabic letter connection logic with character mapping tables for different forms (isolated, initial, medial, final)

The gem automatically activates when required - no configuration needed. It detects RTL text and only processes strings that contain RTL characters.

## Key Dependencies

- **prawn ~> 2.2**: The PDF generation library being patched
- **twitter_cldr >= 4.0, < 7.0**: Provides Unicode Bidirectional Algorithm implementation

## Contributing

- Use Conventional Commits for commit messages.
- Run tests `bundle exec rake` and rubocop linting `bundle exec rubocop` before committing.
