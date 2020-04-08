module WebGit
  class InstallGenerator < Rails::Generators::Base
    def generate_server
      
      log :insert, "Updating config.ru to run apps in parallel."
      
      contents = <<-RUBY.gsub(/^      /, "")
      # This file is used by Rack-based servers to start the application.

      require_relative 'config/environment'

      if Rails.env.development?
        map '/git' do
          run WebGit::Server
        end
      end

      map '/' do
        run Rails.application
      end
      RUBY

      filename = "config.ru"
      match_text = "run Rails.application"

      # insert_into_file filename, before: match_text do contents
      # end

      # gsub_file filename, match_text, "\t" + match_text
      gsub_file filename, match_text, contents

      # append_config
      
      # append_file filename do "\nend"
      # end
    end
    
    private 

    def append_config
      append_file "config.ru" do "\nend"
      end
    end
  end
end
