# app.rb
set :public_folder, 'public'


get "/" do
  erb :index
end

post '/form' do
  theme_name = params[:theme_name]
  author_name = params[:author_name]
  url = params[:url]
  prefix = params['prefix']
  description = params[:description]
  language_support = params[:language_support]
  custom_post_types = params[:custom_post_types]
  sass = params[:sass]
  compass = params[:compass]

  # Copy files to temp folder
  Builder.temp

  # Language Support
  Builder.file_or_dir_delete('temp/theme_1/languages', language_support)
  Builder.tag_replace_delete('LANG', language_support)

  # SASS
  Builder.file_or_dir_delete('sass', sass)
  Builder.file_or_dir_delete('codekit-config.json', sass)
  if sass == 'n'
    File.open('temp/theme_1/css/styles.css', 'w') { |file| file.truncate(0) } # Empty contents of css file
  else
    Builder.tag_replace_delete('COMPASS', compass)
    Builder.file_or_dir_delete('config.rb', compass)
  end

  # Theme Name
  theme_name = theme_name.gsub('*/', '') # Don't close PHP comments
  find_replace_var = {:replacement=>theme_name, :original=>'{%= title %}'}
  Builder.write_replace(find_replace_var)

  # Author
  author_name = author_name.gsub('*/', '') # Don't close PHP comments
  find_replace_var = {:replacement=>author_name, :original=>'{%= author %}'}
  Builder.write_replace(find_replace_var)

  # Author URL
  url = url.gsub('*/', '') # Don't close PHP comments
  find_replace_var = {:replacement=>url, :original=>'{%= author_uri %}'}
  Builder.write_replace(find_replace_var)

  # Prefix
  find_replace_var = {:replacement=>prefix, :original=>'{%= prefix %}'}
  find_replace_var_capitalize = {:replacement=>prefix.capitalize, :original=>'{%= prefix_capitalize %}'} # for classes
  Builder.write_replace(find_replace_var)
  Builder.write_replace(find_replace_var_capitalize)

  # Description
  description = description.gsub('*/', '') # Don't close PHP comments
  find_replace_var = {:replacement=>description, :original=>'{%= description %}'}
  Builder.write_replace(find_replace_var)

  
  # Custom post types
  # if answer == 'yes' || answer == 'y'
  #   custom_post_types_create
  # else
  #   FileUtils.rm_rf('extensions/custom-post-types')
  #   tag_replace_delete(answer, 'CUSTOM-POSTS')
  # end
 
end


# Various methods for search/replace, deleting/renaming files and more
module Builder
  class << self
   
    require 'fileutils'

    def temp
      FileUtils.copy_entry 'theme_base', 'temp/theme_1'
    end

    # Used to either keep text between tags or delete it from the template.
    # Tags in theme files are {{{foo}}} {{{/foo}}}
    def tag_replace_delete(tag_var, answer)
      tag_open = '{{{' + tag_var + '}}}'
      tag_close = '{{{/' + tag_var + '}}}'

      if answer == 'yes'
        delete_open = {:original=>tag_open, :replacement=>''}
        delete_close = {:original=>tag_close, :replacement=>''}
        write_replace(delete_open)
        write_replace(delete_close)
      elsif answer == 'no'
        between = tag_open + '[\s\S]*?' + tag_close
        reg_between = Regexp.new(between, Regexp::IGNORECASE);
        find_replace_var = {:original=>reg_between, :replacement=>''}
        write_replace(find_replace_var)
      end
    end

    # Loop through every file and perform search and replace
    def write_replace(find_replace_var, skip = 'none')

      # First set the file locations only if the correct extension
      files = Dir.glob('temp/theme_1/**/**.{php,css,txt,scss}')

      files.each do |file_name|
        # Skip if file passed into method
        if skip != 'none'
          next if file_name == skip
        end

        text = File.read(file_name)
        replace = text.gsub(find_replace_var[:original], find_replace_var[:replacement])
        File.open(file_name, 'w') { |file| file.puts replace }
      end
    end

    # Deletes a file or directory depending on answer.
    def file_or_dir_delete(file_or_directory, answer = "no")
      file_or_directory = file_or_directory + 'temp/theme_1'
      if answer == 'no'
        if File.directory? file_or_directory
          FileUtils.rm_rf(file_or_directory)
        else
          File.delete file_or_directory
        end
      end
    end
  end
end