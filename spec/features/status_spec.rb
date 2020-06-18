require "spec_helper"

module WebGit
  RSpec.feature "Widget management", :type => :feature do
    scenario "User wants to see commit history" do
      Capybara.app = Rack::Builder.parse_file(File.dirname(__FILE__) + "/../dummy/config.ru").first
      visit "/git"
      # visit("http://localhost/git")
      p page.text
      expect(page).to have_text("On branch master")
    end
  end
end
