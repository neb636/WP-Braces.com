# app.rb
$:.push File.expand_path('../', __FILE__)
require 'fileutils'
require 'builder'

class BuilderRoutes < Sinatra::Base
  set :public_folder, 'public'

  get "/" do
    erb :index
  end

  post '/basetheme' do
    begin
      theme_name = params[:theme_name].gsub('*/', '')
      author_name = params[:author_name].gsub('*/', '')
      url = params[:url].gsub('*/', '')
      prefix = params['prefix']
      description = params[:description].gsub('*/', '')
      language_support = params[:language_support]
      # custom_post_types = params[:custom_post_types]
      # custom_post_types_number = params[:cpt_number]
      sass = params[:sass]
      compass = params[:compass]
      gulp = params[:gulp]

      url_regex = Regexp.new('(https?:\\/\\/)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)')

      # Create the amount of params for each custom post name
      # if custom_post_types_number > 1
      #   index = 1
      #   custom_post_types_number.times do
      #     custom_post_types_array.push(params[:cpt_name_ + index.to_s])
      #     index = index + 1
      #   end
      #   custom_post_types_create(custom_post_types_array)
      # end

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

      ## Language Support
      Builder.check_answer(language_support) # Default checks for yes or no
      Builder.file_or_dir_delete('languages', language_support)
      Builder.tag_replace_delete('LANG', language_support)

      # Custom Post Types
      # if custom_post_types == 'yes' || custom_post_types == 'y'
      #   Builder.tag_replace_delete('CUSTOM-POSTS', custom_post_types, true)
      #   Builder.custom_post_types_create
      # else
      #   FileUtils.rm_rf('extensions/custom-post-types')
      #   Builder.tag_replace_delete('CUSTOM-POSTS', 'n')
      # end

      ## SASS Support
      Builder.check_answer(sass) # Default checks for yes or no
      Builder.file_or_dir_delete('sass', sass)
      Builder.tag_replace_delete('SASSGULP', sass, true)

      if sass == 'y' || sass == 'yes'
        ## Compass Support
        Builder.check_answer(compass) # Default checks for yes or no
        Builder.tag_replace_delete('COMPASS', compass)
        Builder.tag_replace_delete('GULPCOMPASS', compass, true)
        Builder.tag_replace_delete('GULPNONCOMPASS', compass)
        Builder.file_or_dir_delete('config.rb', compass)
      else
        File.open('public/temp/theme_1/css/styles.css', 'w') { |file| file.truncate(0) } # Empty contents of css file
      end

      ## Gulp Support
      Builder.check_answer(gulp) # Default checks for yes or no
      Builder.file_or_dir_delete('gulpfile.js', gulp)
      Builder.file_or_dir_delete('package.json', gulp)
      Builder.file_or_dir_delete('javascripts/compiled', gulp)
      Builder.tag_replace_delete('GULP', gulp, true)
      Builder.tag_replace_delete('NONGULP', gulp)

      ## Theme Name
      find_replace_var = {:replacement=>theme_name, :original=>'{%= title %}'}
      find_replace_var_capitalize = {:replacement=>theme_name.capitalize, :original=>'{%= title_capitalize %}'}
      Builder.write_replace(find_replace_var)
      Builder.write_replace(find_replace_var_capitalize)

      ## Author
      find_replace_var = {:replacement=>author_name, :original=>'{%= author %}'}
      Builder.write_replace(find_replace_var)

      ## Author URI
      Builder.check_answer(url, url_regex)
      find_replace_var = {:replacement=>url, :original=>'{%= author_uri %}'}
      Builder.write_replace(find_replace_var)

      ## Theme URI
      find_replace_var = {:replacement=>url, :original=>'{%= theme_uri %}'}
      Builder.write_replace(find_replace_var)

      ## Project Prefix
      Builder.check_answer(prefix, /^[a-z][a-z_]+[a-z]$/)
      find_replace_var = {:replacement=>prefix, :original=>'{%= prefix %}'}
      find_replace_var_capitalize = {:replacement=>prefix.capitalize, :original=>'{%= prefix_capitalize %}'} # for classes

      Builder.write_replace(find_replace_var)
      Builder.write_replace(find_replace_var_capitalize)

      ## Theme Description
      find_replace_var = {:replacement=>description, :original=>'{%= description %}'}
      Builder.write_replace(find_replace_var)

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
      erb :error
    end
  end
end