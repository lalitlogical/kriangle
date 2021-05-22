# Kriangle

It is the library (gem) built upon ruby to create the Modules (Model, Controller, Serialiser, APIs and much more) in existing rails project. 

Any modules can be consists of below components.
1. Model
2. Controller (APIs)
3. Serialiser
5. Swagger Docs

Its can create any module easily by using it’s commands. You can control the module generation with required components as mentioned above.

By default in first setup, it's create the authentication module (login, register, forgot password, etc). It can setup the swagger docs to access APIs docs easily which can be useful for developers to share the docs.

It provides two commands for this purpose.
1. Setup Kriangle (create required files) into the existing project.
2. Create new modules into the existing project.
 

## Getting started

Kriangle works with Rails 5.1 onwards. Add the following line to your Gemfile:

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

Then run `bundle install`

Next, you need to run the generator:

In the following command you will replace `MODEL` with the class name used for the application’s users. This will create a model (if one does not exist) and configure it with the authentication modul. The generator also configures your config/routes.rb file to point to the authentications controller.

`rails g kriangle:install MODEL PATH [column_name:type]`

i.e. if you want to generate the User model with Auth model (for authentication). So you can type below. Email column add automatically.

`rails g kriangle:install User Auth first_name last_name`

### Generate New module

In above command we have setup the initial authetication module. Now we can generate new modules which be generated with below command.

`rails g kriangle:module MODULE_NAME [column_name:type]`

If you want to generate Post model with title, content column, you can type below.

`rails g kriangle:module Post title:string content:text`

More options are listed below
`skip_controller`
`skip_authentication`
`skip_timestamps`

By default generated the module not referenced to User model. You can enable it by passing reference: true

`rails g kriangle:module Post title:string content:text --reference=true`

If you want has_many association with User model, you should use below command.

`rails g kriangle:module Post title:string content:text --reference=true --has_many=true`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kriangle project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kriangle/blob/master/CODE_OF_CONDUCT.md).
