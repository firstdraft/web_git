module WebGit
  class Heroku
    def self.authenticate(email, password)
      script = File.join( File.dirname(__FILE__), '/../scripts/heroku_login.exp')
      `#{script} #{email} #{password}`
    end

    def whoami
      `heroku whoami`.chomp
    end
  end
end
