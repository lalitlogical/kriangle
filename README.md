# Kriangle

Kriangle is the library (gem) built upon ruby to create the Modules (Model, Controller, Serialiser, APIs and much more) in existing rails project. 

Any modules can be consists of below components.
1. Model
2. Controller (APIs)
3. Serialiser
5. Swagger Docs

Kriangle can create any module easily by using it’s [Generators](#generators). You can control the module generation with [skip options](#skip-options). Also you can choose the [options](#options) as per your requirements.

## Contents

- [Getting Started](#getting-started)
  - [Generators](#generators)
  - [Initial Setup](#initial-setup)
  - [Module Generator](#module-generator)
- [Example](#example)
- [Options](#options)
  - [Associations](#associations)
  - [Columns](#columns)
  - [Controller Actions](#controller-actions)
  - [Skip Options](#skip-options)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

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

### Generators

Kriangle provides two generator for this purpose:
1. [Initial Setup](#initial-setup) - Install the Kriangle and it's dependencies into the existing project.
2. [Module Generator](#module-generator) - Create new modules into the existing project.

### Initial Setup

In intial setup, it's create the intialiser files, authentication module (login, register, forgot password, etc), swagger setup, etc. Swagger help to create the APIs docs. This command can be run single time per project and always before module generator.

In the following command you will replace `MODEL` with the class name used for the application’s users. This will create a model (if one does not exist) and configure it with the authentication module. The generator also configures your config/routes.rb file to point to the authentications controller.This command can be run single time per project and always before module generator.

`rails g kriangle:install MODEL PATH [column_name:type]`

i.e. if you want to generate the User model with Authentication model (for authentication purpose), so you can type below command.

```ruby
rails g kriangle:install User Auth first_name last_name
```
Note: Email column will be added automatically.

### Module Generator

In above command we have setup the initial authetication module. We can generate the new modules with below command. You have take care of sequence of options as below.

`rails g kriangle:module MODULE [association type] [column_name:type] [controller actions] [skip options]`

if you want to generate Post model with title, content column, you can type below.

```ruby
rails g kriangle:module Post title:string content:text
```

By default generated the module not referenced to User model. You can enable it by passing reference: true

```ruby
rails g kriangle:module Post title:string content:text --reference=true
```

If you want has_many association with User model, you should use below command.

```ruby
rails g kriangle:module Post title:string content:text --reference=true --has_many=true
```

## Example

To understand the uses of Kriangle, we will provide a example of `Blog Rails Application`. Please follow the [Getting Started](#getting-started) to setup the Kriangle gem into your newly created Rails project. After that we run its commands to create a modules into projects as following.

Let generate the authentication module. It's compulsary step.

```ruby
rails g kriangle:install User email:string:true name:string:true --skip_avatar=true --skip_tips=true --controller_path=Auth
```

Let now generate the two modules.
1. Blog
2. Comment 

It's provide you different options to control the module generation. So we will use some them mentioned below.

A full fledge command which contains approx all options will be like something below. 
1. It will generate the `Blog` module with title, description with enabling searching on these columns. 
2. It will also create all CRUD APIs. 
3. It will also associate the records with `current_user` during creation.
4. It will also enable counter caching on User table to store the blogs count.

```ruby
rails g kriangle:module Blog ma:has_many:comments:delete_all:false:false:false:false: title:string:false:_cont_any description:text:false:_cont_any published:boolean:false::false index show create update destroy --reference=true --reference_name=current_user --association_type=has_many --counter_cache=true --skip_tips=true --creation_method=new
```

Next command generate the `Comment` module with association with `Blog` model.

```ruby
rails g kriangle:module Comment ma:belongs_to:user::true:false:false:false: message:text:false index show create update destroy --reference=true --reference_name=Blog --association_type=has_many --counter_cache=true --self_reference=true --parent_association_name=parent --child_association_name=replies --skip_tips=true --creation_method=new
```
When you are done with these commands, please run `rake db:migrate` to complete the migration. Now run the application and go to `/swagger` routes to check the APIs documentation. Also you can check the rails project which will magically contains the generated code.

This is the example of Kriangle which can be use to create a full working module with these commands. Play it!

Hope you like it. if you face any issue, please feel free to contact me :) 

## Options

### Associations

If you have rails knowledge, you are already aware about the associations (has_many, belongs_to, etc). You can control this with [Generate New module](#generate-new-module) command. This options support below items in same sequence.

`ma:association_type:association_name:dependent_type:validate_presence:counter_cache:touch_record:accepts_nested_attributes:foreign_key:class_name`

Let understand the every options and its supported values. By default false or nil depedents on options.

| Option            |            Description                         |  Required   |
|:---	              |:---	                                           |:---  |
| `association_type` | `has_many` or `belongs_to` or `has_one`                 | True |
| `association_name` | any previously created model name in lower case   | True |
| `dependent_type`   | `delete_all` or `destroy_all` or `nullify`. Works only with `has_many` and `has_one` association | |
| `validate_presence`   | `true` or `false`. Works only with `belongs_to` association | |
| `counter_cache`   | `true` or `false` | |
| `touch_record`   | `true` or `false` | |
| `accepts_nested_attributes`   | `true` or `false`. Works only with `has_many` and `has_one` association | |
| `foreign_key` | custom foreign key   | |
| `class_name` | any previously created model name   | |

i.e.

`ma:has_many:comments::false:false:false:false:`


### Columns

By default rails support two options into migration. But we have enhance it into Kriangle. It supports as below.

`column name:type:validate_presence:search_by:default value`

Let understand the every options and its supported values. By default false or nil depedents on options.

| Option            |            Description                         |  Required   |
|:---	              |:---	                                           |:---  |
| column name | any valid column name for your model             | True |
| type | `string`, `text`, `boolean`, `integer`, `float`, `date`, `DateTime`, `array`, `attachment`, `Polymorphic`, `json`  | True |
| `validate_presence`   | `true` or `false`. To validate the presence of column value | |
| `search_by`   | `_eq`, `_not_eq`, `_matches`, `_does_not_match`, `_cont`, `_cont_any`, `_cont_all`, `_not_cont`, `_not_cont_any`, `_not_cont_all`, `_true`, `_false` | |
| deafult value   | pass the default value for columns. i.e. `true` or `false` for boolean type of column | |

i.e.

 `title:string:false:_cont_any`

### Controller Actions

By default all controller created (CRUD). But if you want to control it you have to mentioned the required action. It will generate only those action only.

### Skip Options

There are a lot of skip options available. You can check below.

| Skip Options            | Default   |                            Description                     |
|:---	                    |:---	      |:---                                                        |
| `skip_model`            | `false`   | Skip the model creation if model aleady created and you do not want to override it. |
| `skip_controller`            | `false`   | Skip the controller (APIs) generation. |
| `skip_migration`            | `false`   | Skip the table migration if table aleady created and you do not want to override it. |
| `skip_tips`            | `false`   | Skip the tips or comments into files. |
| `skip_authentication`            | `false`   | Skip the authentication for whole APIs of given module. |
| `skip_serializer`            | `false`   | Skip the serialiser. |
| `skip_timestamps`            | `false`   | Skip the timestamps columns (created_at and updated_at) into migration |
| `skip_pagination`            | `false`   | Skip the pagination from index API of controller. |


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kriangle project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kriangle/blob/master/CODE_OF_CONDUCT.md).
