# frozen_string_literal: true

require_relative 'lib/prawn/rtl/support/version'

Gem::Specification.new do |spec|
  spec.name          = 'prawn-rtl-support'
  spec.version       = Prawn::Rtl::Support::VERSION
  spec.authors       = ['Oleksandr Lapchenko']
  spec.email         = ['ozeron@me.com']

  spec.summary       = 'Bidirectional text support for Prawn PDF generator'
  spec.description   = 'Adds right-to-left (RTL) text support to Prawn PDF generator. ' \
                       'Fully supports Arabic script languages (Arabic, Persian, Urdu) with ' \
                       'contextual letter shaping and ligatures. Also supports Hebrew and other ' \
                       'RTL languages with bidirectional text reordering. Handles mixed LTR/RTL text properly.'
  spec.homepage      = 'https://github.com/prawn-rtl-support/prawn-rtl-support'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/prawn-rtl-support/prawn-rtl-support',
    'changelog_uri' => 'https://github.com/prawn-rtl-support/prawn-rtl-support/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/prawn-rtl-support/prawn-rtl-support/issues',
    'documentation_uri' => 'https://rubydoc.info/gems/prawn-rtl-support'
  }

  # Specify which files should be included in the gem
  spec.files = (Dir['{lib,exe}/**/*'] +
                Dir['*.{md,txt,gemspec}'] +
                %w[Gemfile Rakefile LICENSE.txt README.md CODE_OF_CONDUCT.md].select { |f| File.exist?(f) })
               .reject { |f| File.directory?(f) }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extra_rdoc_files = ['README.md', 'LICENSE.txt']

  # Runtime dependencies
  spec.add_dependency 'ffi', '~> 1.17'
  spec.add_dependency 'prawn', '~> 2.2'
end
