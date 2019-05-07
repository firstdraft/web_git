module WebGit
  class CommandsController < ::ApplicationController
    skip_before_action :authenticate_user!, raise: false

    def status
      Dir.chdir(Rails.root) do
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
          @diff_html = `diff2html --style=side --output=stdout`.
            gsub("<h1>Diff to HTML by <a href=\"https://github.com/rtfpessoa\">rtfpessoa</a></h1>", "").
            gsub("<a class=\"d2h-file-switch d2h-hide\">hide</a>", "").
            gsub("<a class=\"d2h-file-switch d2h-show\">show</a>", "")
        else
          @last_diff_html = `diff2html --style=line --output=stdout -- -M HEAD~1`.
            gsub("<h1>Diff to HTML by <a href=\"https://github.com/rtfpessoa\">rtfpessoa</a></h1>", "").
            gsub("<a class=\"d2h-file-switch d2h-hide\">hide</a>", "").
            gsub("<a class=\"d2h-file-switch d2h-show\">show</a>", "")

          @last_commit_message = `git log -1 --pretty=%B`
        end

        @branches = `git branch --sort=-committerdate`.split - ["*"]

        # @log = `git log --branches --remotes --tags --graph --oneline --decorate --pretty=format:"#%h %d %s - %cr"`
        shell_script_path = WebGit::Engine.root.to_s + "/ansi2html.sh"

        @log_html = `git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --branches --remotes --tags | sh #{shell_script_path} --bg=dark`
      end

      render layout: "web_git/application"
    end
  end
end
