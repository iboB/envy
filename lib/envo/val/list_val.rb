module Envo
  class ListVal
    def initialize(ar)
      @ar = ar
    end
    attr_reader :ar

    def insert(elem, pos = nil)
      # assume unique elements
      old_index = @ar.index(elem)
      new_index = case pos
        when :front then 0
        when :back then -1
        else old_index
      end

      return @ar << elem if !new_index
      return @ar if new_index == old_index
      return @ar.insert(new_index, elem) if !old_index

      # we need to reorder
      @ar.delete_at(old_index)
      @ar.insert(new_index, elem)
    end
    def delete(elem)
      @ar.delete(elem)
    end
    def delete_at(index)
      @ar.delete_at(index)
    end
    def uniq!
      @ar.uniq!
    end
    def clean!
      uniq!
    end
    def shift(elem, dir)
      i = @ar.index(elem)
      return nil if i == nil
      shift_at(i, dir)
    end
    def shift_at(i, dir)
      return nil if i>@ar.size

      if dir == :front
        return i if i == 0
        elem = ar[i]
        @ar.delete_at i
        @ar.unshift(elem)
        0
      elsif dir == :back
        return i if i == (@ar.size-1)
        elem = ar[i]
        @ar.delete_at i
        @ar << elem
        @ar.size-1
      elsif dir == :up
        return i if i == 0
        @ar[i-1], @ar[i] = @ar[i], @ar[i-1]
        i - 1
      elsif dir == :down
        return i if i == (@ar.size-1)
        @ar[i+1], @ar[i] = @ar[i], @ar[i+1]
        i + 1
      else
        -1
      end
    end

    def pretty_print(ctx)
      ctx.puts "["
      @ar.each_with_index do |v, i|
        str = @ar.count(v) > 1 ? 'D ' : '  '
        str += "#{i}:".ljust(4)
        str += v
        ctx.puts str
      end
      ctx.puts ']'
    end

    # casts
    def type
      :list
    end
    def accept_assign?(other)
      other.list?
    end
    def invalid_description
      @ar.empty? ? "empty list" : nil
    end
    def list?
      true
    end
    def to_list
      return self
    end
    def accept_item?(item)
      true
    end
    def to_s
      raise StandardError.new "list can't be converted to String"
    end
  end
end
