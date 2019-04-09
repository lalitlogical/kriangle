# Kriangle

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/kriangle`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape', '~> 1.0', '>= 1.0.1'
gem 'grape-active_model_serializers', '~> 1.5', '>= 1.5.1'
gem 'grape-swagger', '~> 0.27.3'
gem 'grape-swagger-rails'
gem 'grape-rails-cache'

gem 'kaminari', '~> 1.0', '>= 1.0.1'
gem 'api-pagination', '~> 4.7'
gem 'kriangle'

gem 'carrierwave'
gem 'rack-cors', '~> 0.4.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kriangle

## Usage

Generate Authentication Module

`rails g kriangle:install [MODEL NAME] [MOUNT PATH] [column_name:type]`

i.e. If we want to generate the User model with Auth model (for authentication). So you can type below.

`rails g kriangle:install User Auth first_name`

Generate other module

`rails g kriangle:module MODULE_NAME [column_name:type]`

i.e. If you want to generate Post model with title, content column, you can type below.

`rails g kriangle:module Post title:string content:text`

By default generated the module not referenced to User model. You can enable it by passing reference: true

`rails g kriangle:module Post title:string content:text --reference=true`

If you want has_many association with User model, you should use below command.

`rails g kriangle:module Post title:string content:text --reference=true --has_many=true`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kriangle project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kriangle/blob/master/CODE_OF_CONDUCT.md).
