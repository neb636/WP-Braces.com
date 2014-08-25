# app.rb
$:.push File.expand_path('../', __FILE__)
require 'fileutils'
require 'builder'
require 'pony'

class BuilderRoutes < Sinatra::Base
  set :public_folder, 'public'

  @@error_message = ''

  get '/' do
    erb :index
  end

  get '/validation_error' do
    erb :form_validate, locals: { error_message: @@error_message }
  end

  post '/basetheme' do
    begin
      theme_name = params[:theme_name].gsub('*/', '')
      author_name = params[:author_name].gsub('*/', '')
      url = params[:url].gsub('*/', '')
      prefix = params['prefix']
      description = params[:description].gsub('*/', '')
      language = params[:language_support]
      sass = params[:sass]
      compass = params[:compass]
      gulp = params[:gulp]
      # @custom_post_types = params[:custom_post_types]
      # @custom_post_types_number = params[:cpt_number]

      # Be naughty and polute the global namespace for convienence
      $base_theme_directory = 'public/temp/theme_1/'
      temp_number = 1

      @url_regex = Regexp.new('(https?:\\/\\/)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)')

      # Change value of $base_theme_directory until the file name does not appear
      until !File.exist?($base_theme_directory)
        temp_number = temp_number + 1
        $base_theme_directory = 'public/temp/theme_' + temp_number.to_s + '/'
      end

      # Copy files to temp folder
      Builder.temp

      ## Load up all parameter methods
      language_support(language)
      sass_support(sass)
      compass_support(sass, compass)
      gulp_support(gulp)
      theme_name_write(theme_name)
      author_name_write(author_name)
      author_uri_write(url)
      theme_uri_write(url)
      project_prefix_write(prefix)
      theme_description_write(description)

      # Zip and save as variable
      Builder.zip_file(temp_number)
      content_type(:zip)
      content = File.read("public/temp/builder_theme#{temp_number}.zip")

      # Delete temp files created
      File.delete("public/temp/builder_theme#{temp_number}.zip")
      FileUtils.rm_rf($base_theme_directory)

      # Return the content so it starts auto download
      content

    # If there is an error send users to the error page and send email about
    # the error to me
    rescue => exception

      Pony.mail :to => 'neb636@gmail.com',
                :from => 'admin@wp-braces.com',
                :subject => 'WP-Braces Error',
                :body => exception

      erb :error
    end
  end

  private

  # Sets up gulp support for theme
  def gulp_support(gulp)
    form_validate(gulp)
    Builder.file_or_dir_delete('gulpfile.js', gulp)
    Builder.file_or_dir_delete('package.json', gulp)
    Builder.file_or_dir_delete('javascripts/compiled', gulp)
    Builder.tag_replace_delete('GULP', gulp, true)
    Builder.tag_replace_delete('NONGULP', gulp)
  end

  # Sets up language support for theme
  def language_support(language)
    form_validate(language)
    Builder.file_or_dir_delete('languages', language)
    Builder.tag_replace_delete('LANG', language)
  end

  # Sets up sass support for theme. If sass is not needed truncate the css file.
  def sass_support(sass)
    form_validate(sass)
    Builder.file_or_dir_delete('sass', sass)
    Builder.tag_replace_delete('SASSGULP', sass, true)

    if sass == 'no'
      File.open('public/temp/theme_1/css/styles.css', 'w') { |file| file.truncate(0) } # Empty contents of css file
    end
  end

  # Sets up custom post support for theme
  def custom_post_type_support(custom_post_types)
    form_validate(custom_post_types)
    if custom_post_types == 'yes'
      Builder.tag_replace_delete('CUSTOM-POSTS', custom_post_types, true)
      Builder.custom_post_types_create
    else
      FileUtils.rm_rf('extensions/custom-post-types')
      Builder.tag_replace_delete('CUSTOM-POSTS', 'n')
    end
  end

  # Only set up compass if sass and compass is yes
  def compass_support(sass, compass)
    if sass == 'yes'
      form_validate(compass)
      Builder.tag_replace_delete('COMPASS', compass)
      Builder.tag_replace_delete('GULPCOMPASS', compass, true)
      Builder.tag_replace_delete('GULPNONCOMPASS', compass)
      Builder.file_or_dir_delete('config.rb', compass)
    end
  end

  # Sets up prefix for theme and has custom error message
  def project_prefix_write(prefix)
    @@error_message = "#{prefix} is not a valid prefix. Please go back and try again."
    form_validate(prefix, /^[a-z][a-z_]+[a-z]$/)

    find_replace_var = { replacement: prefix, original: '{%= prefix %}'}
    find_replace_var_capitalize = { replacement: prefix.capitalize, original: '{%= prefix_capitalize %}' } # for classes

    Builder.write_replace(find_replace_var)
    Builder.write_replace(find_replace_var_capitalize)
  end

  # Sets up theme name for theme
  def theme_name_write(theme_name)
    form_validate(theme_name)
    find_replace_var = { replacement: theme_name, original: '{%= title %}' }
    find_replace_var_capitalize = { replacement: theme_name.capitalize, original: '{%= title_capitalize %}' }

    Builder.write_replace(find_replace_var)
    Builder.write_replace(find_replace_var_capitalize)
  end

  # Sets up author name for theme
  def author_name_write(author_name)
    form_validate(author_name)
    find_replace_var = { replacement: author_name, original: '{%= author %}'}
    Builder.write_replace(find_replace_var)
  end

  # Sets up theme description for theme
  def theme_description_write(description)
    find_replace_var = { replacement: description, original: '{%= description %}'}
    Builder.write_replace(find_replace_var)
  end

  # Sets up theme uri and has a custom error message
  def theme_uri_write(url)
    @@error_message = "#{url} is not a valid URL. Please go back and try again."
    form_validate(url, @url_regex)

    find_replace_var = { replacement: url, original: '{%= theme_uri %}'}
    Builder.write_replace(find_replace_var)
  end

  # Sets up author uri and has a custom error message
  def author_uri_write(url)
    @@error_message = "#{url} is not a valid URL. Please go back and try again."
    form_validate(url, @url_regex)
    find_replace_var = { replacement: url, original: '{%= author_uri %}'}
    Builder.write_replace(find_replace_var)
  end

  # Method used to validate form server side and send to error page if does not match.
  # If regex is not set it becomes set to default to check against yes and no and if it
  # is set it checks through regex.
  def form_validate(form_input, regex = 'default')

    if regex == 'default'
      if form_input.nil?
        @@error_message = 'Looks like you forgot to fill out a required field. Please go back and try again.'
        FileUtils.rm_rf($base_theme_directory)
        redirect '/validation_error'
      end
    else
      if form_input !~ regex
        FileUtils.rm_rf($base_theme_directory)
        redirect '/validation_error'
      end
    end
  end
end