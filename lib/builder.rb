# Various methods for search/replace, deleting/renaming files and more
module Builder
  extend self

  require 'rubygems'
  require 'fileutils'
  require 'zip'

  # Copy theme to temp folder
  def temp
    FileUtils.copy_entry('theme_base', $base_theme_directory)
  end

  # Used to either keep text between tags or delete it from the template depending
  # on if the answer is no. Tags in theme files are {{{foo}}} {{{/foo}}}
  def keep_feature_if_yes(tag_var, answer)
    set_tags(tag_var)

    if answer == 'yes'
      remove_outer_tags(@tag_open, @tag_close)
    else
      remove_tags_and_inner_content(@tag_open, @tag_close)
    end
  end

  # Used to either keep text between tags or delete it from the template depending
  # on if the answer is no. Tags in theme files are {{{foo}}} {{{/foo}}}
  def keep_feature_if_no(tag_var, answer)
    set_tags(tag_var)

    if answer == 'no'
      remove_outer_tags(@tag_open, @tag_close)
    else
      remove_tags_and_inner_content(@tag_open, @tag_close)
    end
  end

  # Loop through every file and perform search and replace
  def write_replace(find_replace_var, skip = 'none')

    # First set the file locations only if the correct extension
    files = Dir.glob("#{$base_theme_directory}/**/**.{php,css,txt,scss,js,json}")

    files.each do |file_name|

      # Skip if file passed into method
      # TODO: Find more efficient way to skip the node_modules folder

      if skip != 'none'
        next if file_name == skip
      end

      next if file_name =~ /node_modules/i

      write_replace_file(find_replace_var, file_name)
    end
  end

  # Does a find and replace on a specific file
  def write_replace_file(find_replace_var, file_name)
    text = File.read(file_name)
    replace = text.gsub(find_replace_var.fetch(:original), find_replace_var.fetch(:replacement))
    File.open(file_name, 'w') { |file| file.puts replace }
  end

  # Deletes a file or directory depending on answer.
  def remove_file_or_dir_if_no(file_or_directory, answer = "no")
    file_or_directory = $base_theme_directory + file_or_directory
    if answer == 'no'
      if File.directory?(file_or_directory)
        FileUtils.rm_rf(file_or_directory)
      else
        File.delete(file_or_directory)
      end
    end
  end

  # Builds file includes string and calls write_replace method
  def file_includes(files_array, tag_to_replace)
    tag_replacement = ''

    files_array.each_with_index do |file, index|

      # Move to new line if not the first file
      if index == 0
        file_place = "require get_template_directory() . '/#{file}';"
      else
        file_place = "\nrequire get_template_directory() . '/#{file}';"
      end

      tag_replacement = tag_replacement + file_place
    end

    # Put includes into functions.php
    find_replace_var = { replacement: tag_replacement, original: tag_to_replace }
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

  private

  # Remove tags from the outside of
  def remove_outer_tags(tag_open, tag_close)
    delete_open = { original: tag_open, replacement: '' }
    delete_close = { original: tag_close, replacement: '' }
    write_replace(delete_open)
    write_replace(delete_close)
  end

  # Remove tags and the inner content
  def remove_tags_and_inner_content(tag_open, tag_close)
    between = tag_open + '[\s\S]*?' + tag_close
    reg_between = Regexp.new(between, Regexp::IGNORECASE);
    find_replace_var = { original: reg_between, replacement: '' }
    write_replace(find_replace_var)
  end

  # Sets tags to be used in tag replace delete methods
  def set_tags(tag_var)
    @tag_open = '{{{' + tag_var + '}}}'
    @tag_close = '{{{/' + tag_var + '}}}'
  end
end