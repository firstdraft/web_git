Rails.application.routes.draw do
  mount WebGit::Engine => "/web_git"
end
