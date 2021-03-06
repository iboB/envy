module Envo
  module Cli
    class InstallerWinCmd
      def each_path_dir
        ENV["Path"].split(';').each { |p| yield p }
      end

      ENVO_RUN_CMD = "envo_run"
      INSTALL_FILE = "envo.bat"
      SOURCE_FILE = "envo.bat"

      def try_install(path)
        if !path
          each_path_dir do |dir|
            if File.file?(File.join(dir, ENVO_RUN_CMD))
              path = dir
              break
            end
          end
          raise Error.new("Couldn't find a good place to install envo. Please use '--path <path>' to provide one") if !path
        end
        raise Error.new("'#{path}' is not an existing directory") if !File.directory?(path)

        src = File.read(File.join(__dir__, SOURCE_FILE))
        target = File.join(path, INSTALL_FILE)
        File.open(target, 'w') do |f|
          f.puts ":: envo #{VERSION}"
          f.write(src)
        end
        puts "Successfully installed #{target}"
      end

      def try_uninstall(path)
        if path
          file = File.join(path, INSTALL_FILE)
          raise Error.new "Couldn't find an existing envo installation in #{path}" if !File.file?(file)
          File.delete(file)
          puts "Sucessfully uninstalled #{file}"
          return
        else
          each_path_dir do |dir|
            file = File.join(dir, INSTALL_FILE)
            next if !File.file?(file)
            File.delete(file)
            puts "Sucessfully uninstalled #{file}"
            return
          end
        end
        raise Error.new "Couldn't find an existing envo installation to uninstall"
      end

      USAGE = <<~EOF
        usage: envo-install [u] [--path <path>]
      EOF
      def run(argv)
        if argv.empty?
          try_install(nil)
          return 0
        end

        if argv[0] == '--help' || argv[0] == '-?'
          puts "installer for envo v#{Envo::VERSION} #{Envo::VERSION_TYPE}"
          puts USAGE
          puts
          puts '             u - uninstall envo'
          puts ' --path <path> - install to or uninstall form a specified directory'
          return 0
        end

        if argv[0] == 'u'
          @uninstalling = true
          argv.shift
        end

        path = nil
        if !argv.empty?
          arg = argv.shift
          if arg != '--path'
            STDERR.puts "Unknown argument #{arg}"
            STDERR.puts USAGE
            return 1
          end
          if argv.empty?
            STDERR.puts "Missing path"
            STDERR.puts USAGE
            return 1
          end
          path = argv.shift
        end

        @uninstalling ? try_uninstall(path) : try_install(path)
        return 0
      end
    end
  end
end
