# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kriangle/version'

Gem::Specification.new do |spec|
  spec.name          = 'kriangle'
  spec.version       = Kriangle::VERSION
  spec.authors       = ['Lalit Kumar Maurya']
  spec.email         = ['lalit.logical@gmail.com']

  spec.summary       = 'Scaffold module (including REST API with documentation) with help of Grape and Swagger.'
  spec.description   = 'Scaffold module (including REST API with documentation) with help of Grape and Swagger.'
  spec.homepage      = 'https://github.com/lalitlogical/kriangle'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.8'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'

  spec.add_dependency('sqlite3', '~> 1.6.4')
  spec.add_dependency('bcrypt', '~> 3.1.7')
  spec.add_dependency('devise', '~> 4.4', '>= 4.4.3')
  spec.add_dependency('dotenv-rails', '~> 2.7', '>= 2.7.6')
  spec.add_dependency('grape', '~> 1.7.0')
  spec.add_dependency('grape-active_model_serializers', '~> 1.5.2')
  spec.add_dependency('grape-rails-cache', '~> 0.1.2')
  spec.add_dependency('grape-swagger', '~> 1.6')
  spec.add_dependency('grape-swagger-rails', '~> 0.5.0')
  spec.add_dependency('api-pagination', '~> 4.7')
  spec.add_dependency('kaminari', '~> 1.0', '>= 1.0.1')
  spec.add_dependency('rack-cors', '~> 2.0')
  spec.add_dependency('ransack')
  spec.add_dependency('carrierwave', '~> 3.0')
end
