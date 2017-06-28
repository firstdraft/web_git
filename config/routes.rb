WebGit::Engine.routes.draw do
  root to: 'commands#status'
  get "status" => "commands#status"
  resource :branch, only: [:create, :show, :destroy]
  resources :commits, only: :create
  post "commits/stash"
  get "commits/push"
  get "commits/pull"
  get "commits/add"
end
