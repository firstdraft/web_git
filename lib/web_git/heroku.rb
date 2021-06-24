require 'timeout'
module WebGit
  class Heroku
    def self.authenticate(email, password)
      raise ArgumentError.new("Email and password cannot be blank.") if email.blank? || password.blank?
      script = File.join( File.dirname(__FILE__), '/../scripts/heroku_login.exp')
      script_pid = Process.spawn("#{script} #{email} #{password}")
      begin
        status = Timeout.timeout(30) do
          # TODO how to check if auth fails? 
          p Process.wait(script_pid)
        end
        puts "--------"
        p status
      rescue Timeout::Error
        Process.kill('TERM', script_pid)
        raise Timeout::Error.new("Sign in took longer than 30 seconds.")
      end
    end

    def self.whoami
      `heroku whoami`.chomp
    end
  end
end
