# Prawn::Rtl::Support

[![CI](https://github.com/prawn-rtl-support/prawn-rtl-support/actions/workflows/ci.yml/badge.svg)](https://github.com/prawn-rtl-support/prawn-rtl-support/actions/workflows/ci.yml)

This gem provides bidirectional text support for Prawn PDF generator. It uses the Unicode Bidirectional Algorithm via [ICU](http://site.icu-project.org/) (International Components for Unicode) for text reordering and implements Arabic letter shaping similar to [Arabic Letter Connector](https://github.com/staii/arabic-letter-connector). Prawn patching is minimal - we only patch [`Prawn::Text::Formatted::Box#original_text`](https://github.com/prawnpdf/prawn/blob/master/lib/prawn/text/formatted/box.rb#L367).

## Supported Languages

- **Full support** (with contextual letter shaping):
  - Arabic
  - Persian/Farsi
  - Urdu
  - Other Arabic script languages
  
- **RTL support** (bidirectional text reordering):
  - Hebrew
  - Syriac
  - Thaana
  - Mixed LTR/RTL text

## Motivation

Ruby and Rails internally provide Unicode string normalization. However, Prawn doesn't connect Arabic letters into their contextual forms and doesn't support mixed LTR and RTL strings. This gem adds this support. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prawn-rtl-support'
```

And that's all. Your Prawn is patched!

Or install it yourself as:

```shell
gem install prawn-rtl-support
```

## Usage

`prawn-rtl-support` provide method [`Prawn::Rtl::Connector#fix_rtl(string)`](https://github.com/prawn-rtl-support/prawn-rtl-support/blob/master/lib/prawn/rtl/connector.rb#L13) which reverse string and connect arabic letters.

Prawn patching is minimal, we patch only [`Prawn::Text::Formatted::Box#original_text`](https://github.com/prawnpdf/prawn/blob/master/lib/prawn/text/formatted/box.rb#L367).

## Development

Check [CLAUDE.md](CLAUDE.md) for more details about the architecture and development commands.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prawn-rtl-support/prawn-rtl-support. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Acknowledgment
This gem uses the same code as [Arabic Letter Connector](https://github.com/staii/arabic-letter-connector) by [@staii](https://github.com/staii) and therefore is based on [Arabic-Prawn](https://rubygems.org/gems/Arabic-Prawn/versions/0.0.1) by Dynamix Solutions (Ahmed Nasser).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
