# app.rb
$:.push File.expand_path('../', __FILE__)
require 'fileutils'
require 'lib/builder'
require 'lib/mailer'
require 'lib/questions'
require 'lib/custom_posts'

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

  # This is where the theme gets created and sent to user
  post '/basetheme' do
    begin

      set_variables

      set_base_theme_directory

      # Copy files to temp folder
      Builder.temp

      # Load up all parameter methods
      load_questions

      # Zip and save as variable
      Builder.zip_file(@temp_number)
      content_type(:zip)
      content = File.read("public/temp/builder_theme#{@temp_number}.zip")

      # Delete temp files created
      File.delete("public/temp/builder_theme#{@temp_number}.zip")
      FileUtils.rm_rf($base_theme_directory)

      # Return the content so it starts auto download
      content

    rescue => exception

      # Mail the exception
      Mailer.send_message({ error: exception })

      # Remove the half created theme
      FileUtils.rm_rf($base_theme_directory) if $base_theme_directory

      # Send users to the error page
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
    @custom_post_types = params[:custom_post_types]
    @custom_post_types_number = params[:cpt_number].to_i

    create_post_type_array
  end

  def create_post_type_array
    @post_type_array = []

    if @custom_post_types == 'yes'
      @custom_post_types_number.times do |index|
        index += 1
        @post_type_array.push(params["cpt_name_#{index}"])
      end
    end

    puts @post_type_array.inspect
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

  def load_questions
    Questions.language_support(@language)
    Questions.sass_support(@sass)
    Questions.compass_support(@sass, @compass)
    Questions.gulp_support(@gulp)
    Questions.custom_post_type_support(@custom_post_types, @post_type_array)
    Questions.theme_name_write(@theme_name)
    Questions.author_name_write(@author_name)
    Questions.author_url_write(@author_url)
    Questions.theme_url_write(@theme_url)
    Questions.project_prefix_write(@theme_name)
    Questions.theme_description_write(@description)
  end
end
