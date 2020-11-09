module Envy
  module Shell
    module WinCmd
      extend self

      def self.likely_abs_path?(val)
        val =~ /^[a-zA-Z]\:\\/
      end
      def self.fix_path(path)
        path.gsub('/', '\\')
      end

      LIST_SEP = ';'
      def self.likely_list?(val)
        val.include?(LIST_SEP)
      end
      def list_to_ar(list)
        list.split(LIST_SEP)
      end
      def ar_to_list(ar)
        ar.join(LIST_SEP)
      end

      def cmd_set_env_var(name, value)
        escaped = value # TODO
        "set #{name}=#{escaped}"
      end
      def cmd_unset_env_var(name)
        "set #{name}="
      end
    end
  end
end