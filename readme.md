## WordPress Custom Base Theme Generator

Sinatra app that runs <a href="http://wp-braces.com">wp-braces.com</a>

All of the logic lies in app.rb

The @ symbol indicates that a variable is a instance variable

### How the theme building takes place

- Users fill out form fields and submit form
- Takes the braces theme and copies it to a temp directory
- Does a string replace with the fields the user fills out
- Zips the temp folder
- Deletes the temp folder and zip file
- Returns the zipped theme folder for the user to download

### How do I get started?

'bundle install'

'npm install'

then type ` $ rerun 'rackup' ` to start a local server

When working on styles or javascript type gulp to recompile