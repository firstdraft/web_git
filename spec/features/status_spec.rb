require "spec_helper"
require "web_git"

module WebGit
  RSpec.feature "Widget management", :type => :feature do
    scenario "User creates a new widget" do
      visit "/git"
      # visit("http://localhost/git")
      p page.text
      expect(page).to have_text("On branch master")
    end
  end
end
