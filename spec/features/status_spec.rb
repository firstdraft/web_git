require "spec_helper"

module WebGit
  RSpec.feature "Git Status", :type => :feature do
    scenario "User wants to see commit history" do
      Capybara.app = Rack::Builder.parse_file(File.dirname(__FILE__) + "/../dummy/config.ru").first

      # TODO not great, since I believe chdir is not threadsage
      Dir.chdir(File.dirname(__FILE__) + "/../dummy/") do
        g = Git.init
        visit "/git"
      end

      p page.text
      expect(page).to have_text("On branch master")

      system! "rm -r #{File.dirname(__FILE__)}/../dummy/.git"
    end
  end
end
