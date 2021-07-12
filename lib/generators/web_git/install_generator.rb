module WebGit
  class InstallGenerator < Rails::Generators::Base
    def generate_server
      
      filename = Rails.root.join("config.ru")

      log :insert, "Updating config.ru to run apps in parallel."
      if File.exists?(filename) && already_installed?
        log :identical, "Skipping overrides."
      else
        contents = <<~RUBY

        if Rails.env.development?
          map '/git' do
            run WebGit::Server
          end
        end
  
        map '/' do
        RUBY
  
        filename = "config.ru"
        match_text = "run Rails.application"
  
        insert_into_file filename, contents, before: match_text
        insert_into_file filename, "\nend", after: match_text, force: true
        gsub_file filename, match_text, "\t#{match_text}"
      end

      expect_installed = run("which expect")

      unless expect_installed
        log :insert, "Installing expect."
        run "sudo apt install -y expect"
      else
        log :identical, "expect already installed."
      end
    end

    def already_installed?
      filename = Rails.root.join("config.ru")
      contents = open(filename).read

      contents.match?(/if\s*Rails.env.development\?\s*map\s*'\/git'\s*do\s*run\s*WebGit::Server\s*end\s*end/)
    end
  end
end
