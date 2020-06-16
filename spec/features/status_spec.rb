require "spec_helper"

module WebGit
  RSpec.feature "Widget management", :type => :feature do
    scenario "User wants to see commit history" do
      visit "/git"
      # visit("http://localhost/git")
      p page.text
      expect(page).to have_text("On branch master")
    end
  end
end
