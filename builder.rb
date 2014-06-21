module Builder

  class << self

    require 'rubygems'
    require 'fileutils'
    require 'zip'

    # Copy theme to temp folder
    def temp
      FileUtils.copy_entry('theme_base', $base_theme_directory)
    end

    # Used to either keep text between tags or delete it from the template.
    # Tags in theme files are {{{foo}}} {{{/foo}}}
    #
    # TODO: Find a better way to inverse code
    def tag_replace_delete(tag_var, answer, inverse_delete = false)
      tag_open = '{{{' + tag_var + '}}}'
      tag_close = '{{{/' + tag_var + '}}}'

      if inverse_delete == true
        if answer == 'yes' || answer == 'y'
          remove_outer_tags(tag_open, tag_close)
        else
          remove_tags_and_inner_content(tag_open, tag_close)
        end
      else
        if answer == 'yes' || answer == 'y'
          remove_outer_tags(tag_open, tag_close)
        else
          remove_tags_and_inner_content(tag_open, tag_close)
        end
      end
    end

    # Loop through every file and perform search and replace
    def write_replace(find_replace_var, skip = 'none')

      # First set the file locations only if the correct extension
      files = Dir.glob("#{$base_theme_directory}/**.{php,css,txt,scss,js,json}")

      files.each do |file_name|

        # Skip if file passed into method
        # TODO: Find more efficient way to skip the node_modules folder

        if skip != 'none'
          next if file_name == skip
        end

        next if file_name =~ /node_modules/i

        text = File.read(file_name)
        replace = text.gsub(find_replace_var[:original], find_replace_var[:replacement])
        File.open(file_name, 'w') { |file| file.puts replace }
      end
    end

    # Deletes a file or directory depending on answer.
    def file_or_dir_delete(file_or_directory, answer = "no")
      file_or_directory = $base_theme_directory + file_or_directory
      if answer == 'no' || answer == 'n'
        if File.directory?(file_or_directory)
          FileUtils.rm_rf(file_or_directory)
        else
          File.delete(file_or_directory)
        end
        puts "\n#{file_or_directory} deleted"
      elsif answer == 'yes' || answer == 'y'
        puts "\n#{file_or_directory} kept"
      end
    end

    # Builds file includes string and calls write_replace method
    def file_includes(files_array, tag_to_replace)
      tag_replacement = ''

      files_array.each_with_index do |file, index|

        # Move to new line if not the first file
        if index == 0
          file_place = "require get_template_directory() . '/" + file + "';"
        else
          file_place = "\nrequire get_template_directory() . '/" + file + "';"
        end

        tag_replacement = tag_replacement + file_place
      end

      # Put includes into functions.php
      find_replace_var = {:replacement=>tag_replacement, :original=>tag_to_replace}
      write_replace(find_replace_var)
    end

    # Zips the files up
    def zip_file(temp_number)
      zipfile_name = "public/temp/builder_theme#{temp_number}.zip"

      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        Dir[File.join($base_theme_directory, '**', '**')].each do |file|
          zipfile.add(file.sub($base_theme_directory, ''), file)
        end
      end
    end

    # Creates custom post types if needed by asking how many and then asking for a name. If no
    # custom post type is needed the custom post type folder is deleted. This method needs lots of refactoring.
    #
    # TODO: Make this not specific to CPT's but to files that can be created more than once
    def custom_post_types_create
      puts "\nHow many custom post types do you need?"
      amount = gets.chomp.to_i

      if amount > 0

        original_file = $base_theme_directory + 'extensions/custom-post-types/custom-post-type.php'
        files_array = Array.new
        index = 0

        # Loop through number of custom post types specified and create them
        amount.times do
          index = index + 1
          puts "\nWhat should the post type #{index} be named?"
          puts "(At least three characters, first and last characters letters only, letters and _'s for the rest.)"

          new_file = $base_theme_directory + 'extensions/custom-post-types/' + answer.gsub(' ', '-') + '-post-type-class.php'

          # Make sure not duplicate answer
          files_array.each do |file|
            if new_file == file
              until new_file != file
                puts "\nPost type name already used"
                puts "\nWhat should the post type #{index} be named?"
                puts "\n(At least three characters, first and last characters letters only, letters and _'s for the rest.)"

                new_file = $base_theme_directory + 'extensions/custom-post-types/' + answer.gsub(' ', '-') + '-post-type-class.php'
              end
            end
          end

          # Push files into files array for includes later
          FileUtils.cp(original_file, new_file)
          files_array.push(new_file)

          # Find and replace variables
          find_replace_var = {:replacement=>answer, :original=>'{%= post_type_name %}'}
          find_replace_var_capitalize = {:replacement=>answer.capitalize, :original=>'{%= post_type_name_capitalize %}'}

          write_replace(find_replace_var, original_file)
          write_replace(find_replace_var_capitalize, original_file)
          puts "\nCreated #{new_file}"
        end

        # Delete original file and add includes into functions.php
        File.delete(original_file)
        file_includes(files_array, '{%= post_type_include %}')
      end
    end

    private

    # Remove tags from the outside of
    def remove_outer_tags(tag_open, tag_close)
      delete_open = {:original=>tag_open, :replacement=>''}
      delete_close = {:original=>tag_close, :replacement=>''}
      write_replace(delete_open)
      write_replace(delete_close)
    end

    # Remove tags and the inner content
    def remove_tags_and_inner_content(tag_open, tag_close)
      between = tag_open + '[\s\S]*?' + tag_close
      reg_between = Regexp.new(between, Regexp::IGNORECASE);
      find_replace_var = {:original=>reg_between, :replacement=>''}
      write_replace(find_replace_var)
    end
  end
end