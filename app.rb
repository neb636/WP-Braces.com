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
      author_url = params[:author_url].gsub('*/', '')
      theme_url = params[:theme_url].gsub('*/', '')
      description = params[:description].gsub('*/', '')
      language = params[:language_support]
      sass = params[:sass]
      compass = params[:compass]
      gulp = params[:gulp]
      # custom_post_types = params[:custom_post_types]
      # custom_post_types_number = params[:cpt_number]

      @url_regex = Regexp.new('(https?:\\/\\/)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)')

      # Be naughty and polute the global namespace for convienence
      $base_theme_directory = 'public/temp/theme_1/'
      temp_number = 1

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
      author_url_write(author_url)
      theme_url_write(theme_url)
      project_prefix_write(theme_name)
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
      FileUtils.rm_rf($base_theme_directory)
      erb :error
    end
  end

  private

  # Sets up gulp support for theme
  def gulp_support(gulp)
    form_validate(gulp)
    Builder.remove_file_or_dir_if_no('gulpfile.js', gulp)
    Builder.remove_file_or_dir_if_no('package.json', gulp)
    Builder.remove_file_or_dir_if_no('javascripts/compiled', gulp)
    Builder.keep_feature_if_yes('GULP', gulp)
    Builder.keep_feature_if_no('NONGULP', gulp)
  end

  # Sets up language support for theme
  def language_support(language)
    form_validate(language)
    Builder.remove_file_or_dir_if_no('languages', language)
    Builder.keep_feature_if_yes('LANG', language)
  end

  # Sets up sass support for theme. If sass is not needed truncate the css file.
  def sass_support(sass)
    form_validate(sass)
    Builder.remove_file_or_dir_if_no('sass', sass)

    if sass == 'no'
      File.open('public/temp/theme_1/css/styles.css', 'w') { |file| file.truncate(0) } # Empty contents of css file
    end
  end

  # Sets up custom post support for theme
  def custom_post_type_support(custom_post_types)
    form_validate(custom_post_types)

    Builder.keep_feature_if_yes('CUSTOM-POSTS', custom_post_types)
    Builder.custom_post_types_create_if_yes(custom_post_types)
    Builder.remove_file_or_dir_if_no('extensions/custom-post-types', custom_post_types)
  end

  # Only set up compass if sass and compass is yes
  def compass_support(sass, compass)
    if sass == 'yes'
      form_validate(compass)
      Builder.keep_feature_if_yes('GULPCOMPASS', compass)
      Builder.keep_feature_if_no('SASSGULP', compass)
      Builder.remove_file_or_dir_if_no('config.rb', compass)
    end
  end

  # Sets up prefix for theme and has custom error message
  def project_prefix_write(prefix)
    @@error_message = "#{prefix} is not a valid prefix. Please go back and try again."
    prefix = prefix.gsub(' ', '_').gsub('-', '_').downcase
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
  def theme_url_write(theme_url)
    @@error_message = "#{theme_url} is not a valid URL. Please go back and try again."
    form_validate(theme_url, @url_regex)

    find_replace_var = { replacement: theme_url, original: '{%= theme_uri %}'}
    Builder.write_replace(find_replace_var)
  end

  # Sets up author uri and has a custom error message
  def author_url_write(author_url)
    @@error_message = "#{author_url} is not a valid URL. Please go back and try again."
    form_validate(author_url, @url_regex)

    find_replace_var = { replacement: author_url, original: '{%= author_uri %}'}
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