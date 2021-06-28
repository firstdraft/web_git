module WebGit
  class InstallGenerator < Rails::Generators::Base
    def generate_server
      
      log :insert, "Updating config.ru to run apps in parallel."
      
      contents = <<-RUBY.gsub(/^      /, "")

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

      expect_installed = run("which expect")

      unless expect_installed
        log :insert, "Installing expect."
        run "sudo apt install -y expect"
      end
    end
  end
end
