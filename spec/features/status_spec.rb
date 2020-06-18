require "spec_helper"

module WebGit
  RSpec.feature "Git Status", :type => :feature do
    scenario "User wants to see what branch they're on" do
      Capybara.app = Rack::Builder.parse_file(File.dirname(__FILE__) + "/../dummy/config.ru").first

      # TODO not great, since I believe chdir is not threadsage
      Dir.chdir(File.dirname(__FILE__) + "/../dummy/") do
        g = Git.init
        g.add(:all=>true) 
        g.commit_all("Init")
        visit "/git"
      end

      p page.text
      expect(page).to have_text(/on branch master/i)

      FileUtils.rm_r("#{File.dirname(__FILE__)}/../dummy/.git")

    end
  end
end
