require 'timeout'
require 'web_git/exceptions'

module WebGit
  class Heroku
    def self.authenticate(email, password)
      raise ArgumentError.new("Email and password cannot be blank.") if email.blank? || password.blank?
      script = File.join( File.dirname(__FILE__), '/../scripts/heroku_login.exp')

      command = "#{script} #{email} #{password}"
      rout, wout = IO.pipe
      pid = Process.spawn(command, :out => wout)

      begin
        status = Timeout.timeout(30) do
          _, status = Process.wait2(pid)
          wout.close
        end
        stdout = rout.readlines.join("\n")
        rout.close
        message = stdout.match(/Error.*\./).to_s
        raise WebGit::AuthenticationError.new(message) if stdout.include?("Error")

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
