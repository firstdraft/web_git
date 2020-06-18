# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

map '/git' do
  run WebGit::Server
end

map '/' do
  run Rails.application
end
