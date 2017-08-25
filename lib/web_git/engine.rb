module WebGit
  class Engine < ::Rails::Engine
    isolate_namespace WebGit

    initializer 'web_git.routes' do |app|
      app.routes.append { mount WebGit::Engine, at: "/git" }
    end
  end
end
