# Creates custom post types if needed by asking how many and then asking for a name. If no
# custom post type is needed the custom post type folder is deleted. This method needs lots of refactoring.
#
# TODO: Make this not specific to CPT's but to files that can be created more than once

class CustomPosts

  def initialize
    @original_file = "#{$base_theme_directory}extensions/custom-post-types/custom-post-type.php"
    @files_array = []
  end

  def create(custom_post_types_array)
    if custom_post_types_array.any?

      custom_post_types_array.each do |cpt_name|
        create_file(cpt_name)
      end

      # Delete original file and add includes into functions.php
      File.delete(@original_file)
      Builder.file_includes(@files_array, '{%= post_type_include %}')
    end
  end

  private

  def create_file(cpt_name)
    cpt_file_name = cpt_name.gsub(' ', '-').downcase
    new_file = "#{$base_theme_directory}extensions/custom-post-types/#{cpt_file_name}-post-type-class.php"

    # Push files into files array for includes later
    FileUtils.cp(@original_file, new_file)
    @files_array.push("extensions/custom-post-types/#{cpt_file_name}-post-type-class.php")

    write_new_file(cpt_name, new_file)
  end

  def write_new_file(cpt_name, new_file)
    find_replace_var = {
      replacement: cpt_name.gsub(' ', '_'),
      original: '{%= post_type_name %}'
    }
    find_replace_var_capitalize = {
      replacement: cpt_name.gsub(' ', '').capitalize,
      original: '{%= post_type_name_capitalize %}'
    }

    Builder.write_replace_file(find_replace_var, new_file)
    Builder.write_replace_file(find_replace_var_capitalize, new_file)
  end
end
