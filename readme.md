## WordPress Custom Base Theme Generator

Sinatra app that runs <a href="http://wp-braces.com">wp-braces.com</a>

All of the logic lies in app.rb

### Variables in Ruby

```ruby
# Local Variable
foo = 'bar'

# Instance Variable
@foo = 'bar'

# Class Variable
@@foo = 'bar'

# Global Variable
$foo = 'bar'

# Constant
FOO = 'bar'
```

### Routes

```ruby
# Fetches the index.erb template
erb :index

# Gets wp-braces.com/ route and sends to index template
get '/' do
  erb :index
end

# Fetches the error.erb template and give variable error_message that
# can be used inside the template
erb :error, locals: { error_message: '404' }
```

### How the theme building takes place

- Users fill out form fields and submit form
- Takes the braces theme and copies it to a temp directory
- Does a string replace with the fields the user fills out
- Zips the temp folder
- Deletes the temp folder and zip file
- Returns the zipped theme folder for the user to download

### How do I get started?

```bash
# Install Ruby dependencies
$ bundle install

# Install Node dependencies(for development only)
$ npm install

# Starts a local server
$ rerun 'rackup' ` to start a local server

# When working on styles or javascript to recompile
$ gulp
```