module WebGit
  class << self
    attr_accessor :heroku_enabled
    def heroku_enabled
      @heroku_enabled || false
    end

    def config(&block)
      yield self
    end
  end
end
