# Doorbell

This project was forked from the original project [Knock](https://github.com/nsarno/knock)

Simple JWT authentication for Rails API

## Description

Doorbell is an authentication solution for Rails API-only application based on JSON Web Tokens.

### What are JSON Web Tokens?

[![JWT](http://jwt.io/assets/badge.svg)](http://jwt.io/)

### Why should I use this?

- It's lightweight.
- It's tailored for Rails API-only application.
- It's [stateless](https://en.wikipedia.org/wiki/Representational_state_transfer#Stateless).
- It works out of the box with [Auth0](https://auth0.com/docs/server-apis/rails).

### Is this gem going to be maintained?

Yes.

## Getting Started

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'doorbell'
```

Then execute:

    $ bundle install

Finally, run the install generator:

    $ rails generate doorbell:install

It will create the following initializer `config/initializers/doorbell.rb`.
This file contains all the informations about the existing configuration options.

### Requirements

Doorbell makes one assumption about your user model:

It must have an `from_token_payload` method, to generate a user from a token

### Usage

Include the `Doorbell::Authenticable` module in your `ApplicationController`

```ruby
class ApplicationController < ActionController::API
  include Doorbell::Authenticable
end
```

You can now protect your resources by calling `authenticate_user` as a before_action
inside your controllers:

```ruby
class SecuredController < ApplicationController
  before_action :authenticate_user

  def index
    # etc...
  end

  # etc...
end
```

You can access the current user in your controller with `current_user`.

If no valid token is passed with the request, Doorbell will respond with:

```
head :unauthorized
```

You can modify this behaviour by overriding `unauthorized_entity` in your controller.

You also have access directly to `current_user` which will try to authenticate or return `nil`:

```ruby
def index
  if current_user
    # do something
  else
    # do something else
  end
end
```

_Note: the `authenticate_user` method uses the `current_user` method. Overwriting `current_user` may cause unexpected behaviour._

You can do the exact same thing for any entity. E.g. for `Admin`, use `authenticate_admin` and `current_admin` instead.

If you're using a namespaced model, Doorbell won't be able to infer it automatically from the method name. Instead you can use `authenticate_for` directly like this:

```ruby
class ApplicationController < ActionController::Base
  include Doorbell::Authenticable
    
  private
  
  def authenticate_v1_user
    authenticate_for V1::User
  end
end
```

```ruby
class SecuredController < ApplicationController
  before_action :authenticate_v1_user
end
```

Then you get the current user by calling `current_v1_user` instead of `current_user`.

### Customization

#### Via the entity model

The entity model (e.g. `User`) can implement specific methods to provide
customization over different parts of the authentication process.

- **Find the authenticated entity from the token payload (when authenticating a request)**

By default, Doorbell assumes the payload as a subject (`sub`) claim containing the entity's id
and calls `find` on the model. If you want to modify this behaviour, implement within
your entity model a class method `from_token_payload` that takes the
payload in argument.

E.g.

```ruby
class User < ActiveRecord::Base
  def self.from_token_payload payload
    # Returns a valid user, `nil` or raise
    # e.g.
    #   self.find payload["sub"]
  end
end
```

- **Modify the token payload**

By default the token payload contains the entity's id inside the subject (`sub`) claim.
If you want to modify this behaviour, implement within your entity model an instance method
`to_token_payload` that returns a hash representing the payload.

E.g.

```ruby
class User < ActiveRecord::Base
  def to_token_payload
    # Returns the payload as a hash
  end
end
```

### Authenticated tests

To authenticate within your tests:

1. Create a valid token
2. Pass it in your request

e.g.

```ruby
class SecuredResourcesControllerTest < ActionDispatch::IntegrationTest
  def authenticated_header
    token = Doorbell::AuthToken.new(payload: { sub: users(:one).id }).token

    {
      'Authorization': "Bearer #{token}"
    }
  end

  it 'responds successfully' do
    get secured_resources_url, headers: authenticated_header

    assert_response :success
  end
end
```

#### Without ActiveRecord

If no ActiveRecord is used, then you will need to specify what Exception will be used when the user is not found with the given credentials.

```ruby
Doorbell.setup do |config|

  # Exception Class
  # ---------------
  #
  # Configure the Exception to be used (raised and rescued) for User Not Found.
  # note: change this if ActiveRecord is not being used.
  #
  # Default:
  config.not_found_exception_class_name = 'MyCustomException'
end
```

### Algorithms

The JWT spec supports different kind of cryptographic signing algorithms.
You can set `token_signature_algorithm` to use the one you want in the
initializer or do nothing and use the default one (HS256).

You can specify any of the algorithms supported by the
[jwt](https://github.com/jwt/ruby-jwt) gem.

If the algorithm you use requires a public key, you also need to set
`token_public_key` in the initializer.

## CORS

To enable cross-origin resource sharing, check out the [rack-cors](https://github.com/cyu/rack-cors) gem.

## License

MIT
