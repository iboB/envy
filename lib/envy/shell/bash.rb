module Envy
  module Shell
    module Bash
      extend self

      def self.likely_abs_path?(val)
        !val.empty? && val[0] == '/'
      end
      def self.fix_path(path)
        path
      end

      LIST_SEP = ':'
      def self.likely_list?(val)
        # we have some work
        # if the value includes our list separtor ":", we need to make sure whether a url:port combination is not a better fit
        return false if !val.include?(LIST_SEP)

        sep_cnt = val.count(LIST_SEP)
        return true if sep_cnt > 2

        # match scheme://url
        return false if val =~ /^\w+\:\/\//

        return true if sep_cnt == 2 # everything else with 2 separators is a list

        # match display type strings address:digit.digit
        return false if val =~ /\:\d.\d$/

        # match something:number to be interpreted as addr:port
        !(val =~ /.*\:\d+$/)
      end
      def list_to_ar(list)
        list.split(LIST_SEP)
      end
      def ar_to_list(ar)
        ar.join(LIST_SEP)
      end

      def cmd_set_env_var(name, value)
        escaped = value.to_s.inspect.gsub("'"){ "\\'" }
        "export #{name}=#{escaped}"
      end
      def cmd_unset_env_var(name)
        "unset -v #{name}"
      end
    end
  end
end