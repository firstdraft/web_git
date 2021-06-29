
  require "diffy"
  require "git"
  class Diff

    def self.get_diff
      # Dir.chdir(Rails.root) do
        `git diff`
      # end
    end

    def self.get_each_left(diff)
      filenames = get_file_names("")
      files = file_diffs(diff)
      lefts = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line[0] != "+"
              file_content += "#{line_number}| " + line + "\n"
              line_number += 1
            end
          else
            current_line_index = 0
            # The line numbers in the output of a git diff match this regex
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If left, starting line number is the first one in a split Array
            start_line = numbers[0].split(" ")[0].
              split(",")[0].to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        lefts[filenames[i]] = file_content.chomp "\n"
      end
      lefts
    end

    def self.get_each_right(diff)
      filenames = get_file_names("")
      files = file_diffs(diff)
      rights = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        start_line = 0
        current_line_index = 0
        line_number = start_line + current_line_index
        lines.each do |line|
          # The line numbers in the output of a git diff match this regex
          # @@ -61,18 +61,15 @@
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line[0] != "-"
              file_content += "#{line_number}| " + line + "\n"
              line_number += 1
            end
          else
            current_line_index = 0
            numbers = line.scan(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/).map(&:join)
            # If right, start line is the second in a split Array
            start_line = numbers[0].split(" ")[1].
              split(",")[0].to_i.abs
            line_number = start_line + current_line_index
            file_content += "\n"
          end
        end
        rights[filenames[i]] = file_content.chomp "\n"
      end
      rights
    end

    def self.get_last_commit_hash
      working_dir = Dir.pwd
      git = Git.open(working_dir)
      git.log.first.sha.slice(0, 7)
    end

    def self.file_diffs(diff)
      diff.scan(/diff --git.*?(?=diff --git|\z)/m)
    end

    def self.match_other_files(line, file, filenames)
      filenames.each do |other_file|
        if file != other_file
          # It looks like:
          #   --- a/<path-to-file>
          #   +++ b/<path-to-file>
          if line.include?('diff --git a/' + other_file + ' b/' + other_file)
            return true
          end
        end
      end
      false
    end

    def self.get_file_names(commit)
      git = Git.open(Dir.pwd)
      if commit.empty?
        filenames = git.status.changed.keys
      else
        filenames = git.diff(commit, "HEAD").map(&:path)
      end
      filenames
    end

    def self.get_last_diff
      # Dir.chdir(Rails.root) do
        `git diff -M HEAD~1`
      # end
    end

    def self.get_last_left(diff)
      filenames = get_file_names("HEAD~1")
      files = file_diffs(diff)
      ones = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        lines.each do |line|
          # The line numbers in the output of a git diff match this regex
          # @@ -61,18 +61,15 @@
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line[0] != "+"
              line.slice!(0)
              file_content += line + "\n"
            end
          else
            file_content += "\n"
          end
        end
        ones[filenames[i]] = file_content.chomp "\n"
      end
      ones
    end

    def self.get_last_right(diff)
      filenames = get_file_names("HEAD~1")
      files = file_diffs(diff)
      ones = {}
      files.each_with_index do |file, i|
        file_content = ""
        lines = file.split("\n").drop(4)
        lines.each do |line|
          if !line.match?(/@@ ([-]\d+,\d+\s[+]\d+,\d+) @@/)
            if line[0] != "+"
            elsif line[0] == "+"
              line.slice!(0)
              file_content += line + "\n"
            end
          else
            file_content += "\n"
          end
        end
        ones[filenames[i]] = file_content.chomp "\n"
      end
      ones
    end

    def self.last_to_html(diff)
      left_hash = get_last_left(diff)
      right_hash = get_last_right(diff)

      html_output = '<link rel="stylesheet"' +
        'href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/' +
        'bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/' +
        '1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">'
      html_output += '<style>'
      html_output += Diffy::CSS
      html_output += '</style>'
      html_output += '<div class="card" style="overflow-y: scroll;max-height:400px">'
      left_hash.keys.each do |file|
        html_output += '<div class="file mb-4 p-1">'
        html_output += '<h4>' + file + '</h4>'
        html_output += Diffy::Diff.new(
          left_hash[file],
          right_hash[file],
          :include_plus_and_minus_in_html => true,
          :allow_empty_diff => false
        ).to_s(:html)
        html_output += '</div>'
      end
      html_output += '</div>'
      html_output
    end

    def self.diff_to_html(diff)
      left_hash = get_each_left(diff)
      right_hash = get_each_right(diff)
      html_output = '<div style="overflow-y: scroll;height:400px">'
      html_output += '<style>'
      html_output += Diffy::CSS
      html_output += '</style>'
      html_output += '<div class="row mb-3">'
      html_output += '<div class="col-md-12 offset" style="overflow-y: scroll;">'

      left_hash.keys.each do |file|
        html_output += '<div class="row text-center">
          <div class="col-12">
            <h4>'
        html_output+= file.to_s
        html_output += '</h4>
          </div>
        </div>
          <div class="row mb-4">
            <div class="col-6">'
        html_output += Diffy::SplitDiff.new(
          left_hash[file],
          right_hash[file],
          :format => :html
          ).left

        html_output +=
            '</div>
            <div class="col-6">'
        html_output += Diffy::SplitDiff.new(
          left_hash[file],
          right_hash[file],
          :format => :html
        ).right

        html_output += '</div></div>'
      end
      html_output += "</div>"
      html_output += "</div>"
      html_output += "</div>"
      html_output

    end
  end
