
# JsonApiPreloader

![CI Workflow](https://github.com/koryushka/json_api_preloader/workflows/CI%20Workflow/badge.svg)
[![Gem Version](https://badge.fury.io/rb/json_api_preloader.svg)](https://badge.fury.io/rb/json_api_preloader)

JsonApiPreloader helps to preload associations based on query `include` parameter in order to avoid N+1 query. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_api_preloader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_api_preloader

## Usage

Let's say you have models:

```ruby
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :images
end

class Image < ApplicationRecord
  belongs_to :post
end

class Comment < ApplicationRecord
  belongs_to :post
end
```

And you're querying `index` action of `users_controller` as following:

`GET /users?include=posts.images,posts.comments`

```ruby
class UsersController < ApplicationController
  include JsonApiPreloader::Core
  setup_query_builder

  def index
    users = User.includes(preloaded) 
    # preloaded will be `{ posts: { images: {}, comments: {} } }`
  end
end
```

You can specify parent model per action:

```ruby
  setup_query_builder "SomeModel", action: :custom_action
```

or with unexistent association:

`GET /users?include=posts.images,posts.comments,posts.unexistent,unexistent`

```ruby
class UsersController < ApplicationController
  include JsonApiPreloader::Core
  setup_query_builder

  def index
    users = User.includes(preloaded) 
    # By default `preloaded` will be `{ posts: { images: {}, comments: {} } }`.
    # If `check_associations` is set to `false` `preloaded` will be:
    # { posts: { images: {}, comments: {}, unexistent: {} }, unexistent: {} }
    # this might help client to understand the usage of endpoint, because error will be returned.
  end
end
```


You can configure JsonApiPreloader:

```ruby
# config/initializers/json_api_preloader.rb
JsonApiPreloader.configure do |config|
  # By default `check_associations` is set to true, which means that nonexistent
  # associations will be ignored and trimmed. 
  config.check_associations = true
  # Set your models` folder, by default it's `./app/models/**/*.rb`
  config.models_folder = './app/models/**/*.rb'
end
```
