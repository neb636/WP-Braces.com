# app.rb
$:.push File.expand_path('../', __FILE__)
require 'fileutils'
require 'lib/builder'
require 'lib/questions'

class BuilderRoutes < Sinatra::Base
  set :public_folder, 'public'

  @@error_message = ''

  get '/' do
    erb :index
  end

  get '/validation_error' do
    erb :form_validate, locals: { error_message: @@error_message }
  end

  not_found do
    status 404
    erb :form_validate, locals: { error_message: '404' }
  end

  post '/basetheme' do
    begin
      set_variables

      set_base_theme_directory

      # Copy files to temp folder
      Builder.temp

      # Load up all parameter methods
      load_questions

      # Zip and save as variable
      zip_and_send_files

      # Delete temp files created
      File.delete("public/temp/builder_theme#{@temp_number}.zip")
      FileUtils.rm_rf($base_theme_directory)

    # If there is an error send users to the error page
    rescue => exception
      FileUtils.rm_rf($base_theme_directory)
      erb :error
    end
  end

  private

  def set_variables
    @theme_name = params[:theme_name].gsub('*/', '')
    @author_name = params[:author_name].gsub('*/', '')
    @author_url = params[:author_url].gsub('*/', '')
    @theme_url = params[:theme_url].gsub('*/', '')
    @description = params[:description].gsub('*/', '')
    @language = params[:language_support]
    @sass = params[:sass]
    @compass = params[:compass]
    @gulp = params[:gulp]
    # @custom_post_types = params[:custom_post_types]
    # @custom_post_types_number = params[:cpt_number]
  end

  def set_base_theme_directory
    # Be naughty and polute the global namespace for convienence
    $base_theme_directory = 'public/temp/theme_1/'
    @temp_number = 1

    # Change value of $base_theme_directory until the file name does not appear
    until !File.exist?($base_theme_directory)
      @temp_number = @temp_number + 1
      $base_theme_directory = 'public/temp/theme_' + @temp_number.to_s + '/'
    end
  end

  def zip_and_send_files
    Builder.zip_file(@temp_number)
    content_type(:zip)
    File.read("public/temp/builder_theme#{@temp_number}.zip")
  end

  def load_questions
    Questions.language_support(@language)
    Questions.sass_support(@sass)
    Questions.compass_support(@sass, @compass)
    Questions.gulp_support(@gulp)
    Questions.theme_name_write(@theme_name)
    Questions.author_name_write(@author_name)
    Questions.author_url_write(@author_url)
    Questions.theme_url_write(@theme_url)
    Questions.project_prefix_write(@theme_name)
    Questions.theme_description_write(@description)
  end
end
