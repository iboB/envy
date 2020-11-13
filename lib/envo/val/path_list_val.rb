module Envo
  class PathListVal < ListVal
    def initialize(host, ar)
      super(ar)
      @host = host
    end
    def type
      :"path list"
    end
    def accept_assign?(other)
      other.type == type
    end
    def accept_item?(item)
      item.type == :path
    end
    def pp_attribs(elem)
      super + (@host.path_exists?(elem) ? ' ' : 'N')
    end
    def clean!
      super
      @ar.select! { |s| @host.path_exists?(s) }
    end
  end
end