module WebGit
  class CommandsController < ::ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :force_/.*/_sign_in, raise: false

    def status
      Dir.chdir(Rails.root) do
        
        unless Dir.exist?(".git")
          puts "Initialize a git repository"
          `git init`
        end
        @status = `git status`
        @current_branch = `git symbolic-ref --short HEAD`.chomp

        @origin_url = nil
        origin = `git config --get remote.origin.url`

        if origin.present?
          url = origin.chomp.gsub(".git", "")
          url_obj = GitCloneUrl.parse(url)
          array = url_obj.path.gsub(/\A\//, '').split("/")
          @user, @repo = array[0], array[1]

          @origin_url = "https://github.com/#{@user}/#{@repo}.git"
        end

        diff = `git diff`

        unless diff.blank?
          @diff_html = WebGit::Diff.diff_to_html(diff)
        else
          last_diff = WebGit::Diff.get_last_diff
          @last_diff_html = WebGit::Diff.last_to_html(last_diff)

          @last_commit_message = `git log -1 --pretty=%B`
        end

        @branches = `git branch --sort=-committerdate`.split - ["*"]

        # @log = `git log --branches --remotes --tags --graph --oneline --decorate --pretty=format:"#%h %d %s - %cr"`
        shell_script_path = WebGit::Engine.root.to_s + "/ansi2html.sh"

        @log_html = `git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n%C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --branches --remotes --tags | sh #{shell_script_path} --bg=dark`
      end

      render layout: "web_git/application"
    end

  end

end
