module Envy
  class NoVar
    def initialize(name)
      @name = name
    end
    attr_accessor :name
    def to_env_val
      nil
    end
  end
end
