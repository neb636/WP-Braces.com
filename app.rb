# app.rb
$:.push File.expand_path('../', __FILE__)
require 'fileutils'
require 'lib/mailer'
require 'zip'

class BuilderRoutes < Sinatra::Base
  set :public_folder, 'public'

  @error_message = ''

  get '/' do
    erb :index
  end

  get '/validation_error' do
    erb :form_validate, locals: { error_message: @error_message }
  end

  not_found do
    status 404
    erb :form_validate, locals: { error_message: '404' }
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

      puts exception

      # Remove the half created theme
      FileUtils.rm_rf(@base_theme_directory) if @base_theme_directory

      # Send users to the error page
      erb :error
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

    # Change value of $base_theme_directory until the file name does not appear
    until !File.exist?(@base_theme_directory)
      @temp_number = @temp_number + 1
      @base_theme_directory = "public/temp/theme_#{@temp_number.to_s}/"
    end
  end

  # Method used to validate form server side and send to error page if field is empty.
  def form_validate(form_input)
    if form_input.nil?
      @error_message = 'Looks like you forgot to fill out a required field. Please go back and try again.'
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

      next if file_name =~ /node_modules/i

      text = File.read(file_name)
      replace = text.gsub(find_replace_var.fetch(:original), find_replace_var.fetch(:replacement))
      File.open(file_name, 'w') { |file| file.puts replace }
    end
  end
end