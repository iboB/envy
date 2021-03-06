module Envo
  class CmdPath
    Name = 'path'
    def self.register_help(help)
      help.add_cmd "path <args>", <<~EOF
        shorthand for 'list @path <args>'
          shorthand: 'p'
      EOF
    end

    def self.register_cli_parser(parser)
      parser.add_cmd(Name, ->(cmd, args) { parse_cli(args) })
      parser.add_cmd('p', ->(cmd, args) { parse_cli(args) })
    end

    def self.register_script_parser(parser)
      parser.add_cmd(Name, ->(cmd, tokens, opts) { parse_script(tokens, opts) })
    end

    def self.parse_cli(args)
      CmdList.parse_cli(args.unshift('@path'))
    end

    def self.parse_script(tokens, opts)
      CmdList.parse_script(tokens.unshift('@path'), opts)
    end
  end
end
