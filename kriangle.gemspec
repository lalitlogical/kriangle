# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kriangle/version'

Gem::Specification.new do |spec|
  spec.name          = 'kriangle'
  spec.version       = Kriangle::VERSION
  spec.authors       = ['Lalit Kumar Maurya']
  spec.email         = ['lalit.logical@gmail.com']

  spec.summary       = '"Write a short summary, because RubyGems requires one."'
  spec.description   = '"Write a longer description or delete this line."'
  spec.homepage      = 'https://github.com/lalitlogical'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'

  spec.add_dependency('sqlite3')

  spec.add_dependency('bcrypt', '~> 3.1.7')
  spec.add_dependency('devise', '~> 4.4', '>= 4.4.3')
  spec.add_dependency('dotenv-rails')

  spec.add_dependency('grape', '~> 1.2', '>= 1.2.4')
  spec.add_dependency('grape-active_model_serializers', '~> 1.5', '>= 1.5.2')
  spec.add_dependency('grape-rails-cache')
  spec.add_dependency('grape-swagger', '~> 1.4')
  spec.add_dependency('grape-swagger-rails', '~> 0.3.1')

  spec.add_dependency('api-pagination', '~> 4.7')
  spec.add_dependency('kaminari', '~> 1.0', '>= 1.0.1')

  spec.add_dependency('rack-cors')
  spec.add_dependency('ransack', '~> 2.3')

  spec.add_dependency('carrierwave', '~> 2.0', '>= 2.0.2')
end
