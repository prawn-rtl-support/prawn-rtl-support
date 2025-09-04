# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prawn/rtl/support/version'

Gem::Specification.new do |spec|
  spec.name          = 'prawn-rtl-support'
  spec.version       = Prawn::Rtl::Support::VERSION
  spec.authors       = ['Oleksandr Lapchenko']
  spec.email         = ['ozeron@me.com']

  spec.summary       = 'Gem which patch prawn to provide support of arabic language.'
  spec.description   = 'Add suport for arabic language in prawn.'
  spec.homepage      = 'https://github.com/prawn-rtl-support/prawn-rtl-support'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'prawn', '~> 2.2'
  spec.add_dependency 'twitter_cldr', '>= 4.0', '< 7.0'
end
