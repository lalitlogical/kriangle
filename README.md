# Kriangle

Kriangle is a library (gem) built upon ruby to create the Modules (Model, Controller, Serialiser, APIs and much more) in rails project.

Any modules can be consists of below components.
1. Model
2. Controller (APIs)
3. Serialiser
5. Swagger Docs
6. much more ...

Kriangle can create any module easily by using it’s [Generators](#generators). You can control the module generation with [skip options](#skip-options). Also you can choose the [options](#options) as per your requirements.

## Contents

- [Getting Started](#getting-started)
  - [Generators](#generators)
  - [Initial Setup](#initial-setup)
  - [Module Generator](#module-generator)
- [Options](#options)
  - [Associations](#associations)
  - [Columns](#columns)
  - [Controller Actions](#controller-actions)
  - [Skip Options](#skip-options)
  - [Advanced Options](#advanced-options)
    - [Database](#database)
    - [Wrapper](#wrapper)
    - [APIs Routes](#apis-routes)
    - [Parent Reference](#parent-reference)
    - [Self Association](#self-association)
- [Example](#example)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Getting started

Kriangle works with Rails 5.1 onwards (< 6). Add the following line to your Gemfile:

```ruby
gem 'kriangle'
```

Then run `bundle install`

Kriangle dependent on [Devise](https://github.com/heartcombo/devise) gem for its authentication module. So we have to generate its intialiser file by installing it.

```ruby
bundle exec rails g devise:install
```

Next, you need to run the generators:

### Generators

Kriangle provides two generator for this purpose:
1. [Initial Setup](#initial-setup) - Install the Kriangle and it's dependencies into the existing project.
2. [Module Generator](#module-generator) - Create new modules into the existing project.

Always remember the hierarchy of modules. So if any module behave as child of any other module then parent module should be generated before the child module. So when you generate the modules, it should follow the hierarchy. i.e. if you enable the counter cache on `Post` model for it's owners, `User` module must created before `Post` module. So hierarchy should be like `User`, `Post`, `Comment`, `Like`, etc for a blog rails application.

### Initial Setup

In intial setup, it's create the intialiser files, authentication module (login, register, forgot password, etc), swagger setup, etc. Swagger help to create the APIs docs. This command can be run single time per project and always before module generator.

In the following command you will replace `MODEL` with the class name used for the application’s users. This will create a model (if one does not exist) and configure it with the authentication module. The generator also configures your config/routes.rb file to point to the authentications controller.This command can be run single time per project and always before module generator.

`rails g kriangle:install MODEL PATH [column_name:type]`

i.e. if you want to generate the User model with Authentication model (for authentication purpose), so you can type below command.

```ruby
rails g kriangle:install User Auth first_name last_name gender age
```
Note: `email`, `password`, other columns and authetication related table will be added automatically.

### Module Generator

In above command we have setup the initial authetication module. We can generate the new modules with below command. You have to take care of sequence of options as below.

`rails g kriangle:module MODULE [association type] [column_name:type] [controller actions] [skip options]`

if you want to generate `Post` model with title, content columns, you can type below.

```ruby
rails g kriangle:module Post title:string content:text
```

By default, generated the model does not refered to current logged in user. You can enable it by passing reference=true and other arguments as below.

```ruby
rails g kriangle:module Post title:text:false:_cont_any content:text:false:_cont_any published:boolean:false::false index show create update destroy --reference=true --reference_name=current_user --association_type=has_many --skip_tips=true --creation_method=new
```

If you want to enable counter cache on user's record, you should use below command.

```ruby
rails g kriangle:module Post title:text:false:_cont_any content:text:false:_cont_any published:boolean:false::false index show create update destroy --reference=true --reference_name=current_user --association_type=has_many --counter_cache=true --skip_tips=true --creation_method=new
```

## Options

Kriangle support different arguments to control the code generation.

### Associations

If you have rails knowledge, you are already aware about the associations (has_many, belongs_to, etc). You can control this with [Generate New module](#generate-new-module) command. This options support below items in same sequence.

`ma:association_type:association_name:dependent_type:validate_presence:counter_cache:touch_record:accepts_nested_attributes:foreign_key:class_name`

Let understand the every options and its supported values. By default false or nil depedents on arguments.

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

Let understand the every arguments and its supported values. By default false or nil depedents on arguments.

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

By default, all CRUD APIs generated. But if you want to control it, you have to mentioned the required action. It will generate only those APIs.

Valid actions mentioned as below.
1. index
2. show
3. create
4. update
5. destroy
6. create_or_destroy - Will update the controller's action according to like dislike feature respective to authenticator model (i.e. User).

### Skip Options

There are a lot of skip options available. You can check below.

| Skip Options            | Default   |                            Description                     |
|:---	                    |:---	      |:---                                                        |
| `skip_swagger`            | `false`   | Skip the swagger documentation. **Only** valid with `install` generator |
| `skip_avatar`            | `true`   | Skip the user's avatar feature. **Only** valid with `install` generator |
| `skip_model`            | `false`   | Skip the model creation if model aleady created and you do not want to override it. |
| `skip_controller`            | `false`   | Skip the controller (APIs) generation. |
| `skip_migration`            | `false`   | Skip the table migration if table aleady created and you do not want to override it. |
| `skip_tips`            | `false`   | Skip the tips or comments into files. |
| `skip_authentication`            | `false`   | Skip the authentication for whole APIs of given module. |
| `skip_serializer`            | `false`   | Skip the serialiser. |
| `skip_timestamps`            | `false`   | Skip the timestamps columns (created_at and updated_at) into migration |
| `skip_pagination`            | `false`   | Skip the pagination from index API of controller. |

### Advanced Options

Kriangle support some additional arguments also for generate code as per requirement.

#### Database

By default, Kriangle generate code based on `sqlite3` database, mostly migration files depends on it. But you can provide the database to generate the code based on that.

```ruby
--database=postgresql
```

Supported databases: `postgresql`, `mysql`, `sqlite3`. You have to add **adapter/gem** based on your database in your **Gemfile**


#### Wrapper

Kriangle generate all APIs under `app/controllers/api/v1` folder. You can change the wrapper name (v1) as per you need with `wrapper` arguments as below.

```ruby
--wrapper=V2
```

#### APIs Routes

Kriangle by default use the model name for routes. So if do not pass it will determined with model name. i.e. For `Post` model api routes will be `posts` and whole end points will be like `api/v1/posts`. You can change it by passing your desired path as below.

```ruby 
--controller_path=blogs
```

Now all APIs points to `/api/v1/blogs` but model will be `Post`.

#### Parent Reference

Kriangle provides mechanism to add parent reference with previously created model (i.e. `User`, `Post` ) or `current_user`.

If you want that newly created records associate with current logged in user, you have to pass below arguments.

```ruby
--reference=true --reference_name=current_user --association_type=has_many
```
There are other options also available under this Parent Reference.

| Option         | Default   |                            Description                     |
|:---	           |:---   |:---                                                        |
| `reference` | `false` | Current model's association sets up a one-to-one connection with selected model, such that each instance of the declaring model 'belongs to' one instance of the selected model. |
| `reference_name` | | `current_user` or previously created model name i.e. `User`, `Post` |
| `association_type` | `has_many` | `has_many` or `has_one` |
| `counter_cache` | `false` | Default false. Instead of counting the associated records in the database every time the page loads, ActiveRecord’s counter caching feature allows storing the counter and updating it every time an associated object is created or removed. Parent model should be defined before this model. |
| `touch_record` | `false` | In rails touch is used to update the parent's updated_at field for persisted objects. |
| `accepts_nested_attributes` | `false` | Nested attributes allow you to save attributes on associated records through the parent. By default nested attribute updating is turned off and you can enable it using the accepts_nested_attributes_for class method. When you enable nested attributes an attribute writer is defined on the model. |

#### Self Association

Kriangle provides mechanism to add self reference within the model.

If you want that newly created records associate with existing record of same table, you have to pass below arguments.

```ruby
--self_reference=true --parent_association_name=parent --child_association_name=replies
```

You can chose your desired association name through `parent_association_name` and `child_association_name` arguments.

## Example

To understand the uses of Kriangle, we will provide a example of **Blogger** rails application.

Let's create a rails project.

```ruby
rails _5.2.3_ new blogger
```

Now follow the [Getting Started](#getting-started) to setup the Kriangle gem into your newly created **blogger** rails project. After that we run its generators to create new modules into the **blogger** rails project as below.

Let generate the **authentication** module. Its a **mendatory** step.

```ruby
rails g kriangle:install User email:string:true name:string:true --skip_avatar=true --skip_tips=true --controller_path=Auth
```

Let now generate the two modules.
1. Blog
2. Comment

Kriangle provide you different arguments to control the module generation. So we will use some of them mentioned below.

A full fledge command which contains approx all arguments will be like something below.
1. It will generate the `Blog` model with title, description, published columns and with enabling searching on title and description columns.
2. It will also create all CRUD APIs.
3. It will also associate the records with `current_user` during CRUD.
4. It will also enable counter caching on users table to store the blogs_count.

```ruby
rails g kriangle:module Blog ma:has_many:comments:delete_all:false:false:false:false: title:string:false:_cont_any description:text:false:_cont_any published:boolean:false::false index show create update destroy --reference=true --reference_name=current_user --association_type=has_many --counter_cache=true --skip_tips=true --creation_method=new
```

Next command will generate the `Comment` model associated with `Blog` model with message column. Its also provide the self reference mechanism to itself table to store the replies on the comments.

```ruby
rails g kriangle:module Comment ma:belongs_to:user::true:false:false:false: message:text:false index show create update destroy --reference=true --reference_name=Blog --association_type=has_many --counter_cache=true --self_reference=true --parent_association_name=parent --child_association_name=replies --skip_tips=true --creation_method=new
```
When you are done with these commands, please run `rake db:migrate` to complete the migration.

Now run the application and go to **/swagger** routes to check the APIs documentation. Also you can check the rails project which will magically contains the generated code.

This is the example of Kriangle which can be use to create a full working module with these generators. Play it!

Hope you like it!. if you face any issue, please feel free to contact me :)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kriangle project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lalitlogical/kriangle/blob/master/CODE_OF_CONDUCT.md).
