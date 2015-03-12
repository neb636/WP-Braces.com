# app.rb
$:.push File.expand_path('../', __FILE__)
require 'fileutils'
require 'mandrill'
require 'yaml'
require 'zip'

class BuilderRoutes < Sinatra::Base
  set :public_folder, 'public'

  # Main Route
  get '/' do
    erb :index
  end

  get '/validation_error' do
    error_message = 'Looks like you forgot a required field. Please go back and try again.'
    erb :error, locals: { error_message: error_message }
  end

  not_found do
    status 404
    erb :error, locals: { error_message: '404' }
  end

  # This is where the theme gets created and sent to user
  post '/basetheme' do
    begin

      set_base_theme_directory

      # Copy files to temp folder
      FileUtils.copy_entry('braces_theme', @base_theme_directory)

      # Lets do the find and replace
      write_replace({ replacement: params[:theme_name], original: 'braces' })
      write_replace({ replacement: params[:theme_name].upcase, original: 'BRACES' })
      write_replace({ replacement: params[:author_name], original: 'Oomph, Inc.' })
      write_replace({ replacement: params[:author_name], original: 'http://www.oomphinc.com'})

      # Zip and save as variable
      zip_file(@temp_number)
      content_type(:zip)
      content = File.read("public/temp/builder_theme#{@temp_number}.zip")

      # Delete temp files created
      File.delete("public/temp/builder_theme#{@temp_number}.zip")
      FileUtils.rm_rf(@base_theme_directory)

      # Return the content so it starts auto download
      content

    rescue => exception

      # Mail the exception
      Mailer.send_message({ error: exception })

      # Remove the half created theme
      FileUtils.rm_rf(@base_theme_directory) if @base_theme_directory

      # Send users to the error page
      error_message = 'There was an error. An email has been sent to the site owner to make sure he fixes the bug.'
      erb :error, locals: { error_message: error_message }
    end
  end

  private

  # Zips the files up
  def zip_file(temp_number)
    zipfile_name = "public/temp/builder_theme#{temp_number}.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Dir[File.join(@base_theme_directory, '**', '**')].each do |file|
        zipfile.add(file.sub(@base_theme_directory, ''), file)
      end
    end
  end

  # Check to see if a theme is already being written
  def set_base_theme_directory
    @base_theme_directory = 'public/temp/theme_1/'
    @temp_number = 1

    # Change value of $base_theme_directory until the folder name does not appear
    until !File.exist?(@base_theme_directory)
      @temp_number = @temp_number + 1
      @base_theme_directory = "public/temp/theme_#{@temp_number.to_s}/"
    end
  end

  # Method used to validate form server side and send to error page if field is empty.
  def form_validate(form_input)
    if form_input.nil?
      FileUtils.rm_rf(@base_theme_directory)
      redirect '/validation_error'
    end
  end

  # Loop through every file and perform search and replace
  def write_replace(find_replace_var, skip = 'none')

    # Validate user input
    form_validate(find_replace_var.fetch(:original))

    # First set the file locations only if the correct extension
    files = Dir.glob("#{@base_theme_directory}/**/**.{php,css,txt,scss,js,json}")

    files.each do |file_name|

      # Skip if file passed into method
      if skip != 'none'
        next if file_name == skip
      end

      text = File.read(file_name)
      replace = text.gsub(find_replace_var.fetch(:original), find_replace_var.fetch(:replacement))
      File.open(file_name, 'w') { |file| file.puts replace }
    end
  end
end

# Uses the Mandrill Rest Api so I do not have to mess with SMTP.
module Mailer
  extend self

  # Sends email to mandrill and then exits
  def send_message(message)
    mandrill = Mandrill::API.new(get_api_key)

    email = {
      subject: 'Exception generated during theme creation',
      from_name: 'WP-Braces Admin',
      text: html_template(message),
      to: [
          {
          email: 'neb636@gmail.com',
          name: 'Nick'
        }
      ],
      html: "<h2>There was a exception during theme creation</h2>
      <p style='font-size: 14px;'>The exception message is <em>#{message}.</em></p>",
      from_email: "Admin@wp-braces.com"
    }

    mandrill.messages.send(email)
  end

  private

  def get_api_key
    client_secrets = YAML.load_file('client_secrets.yml')
    client_secrets['mandrill_api_key']
  end
end
