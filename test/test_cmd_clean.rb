require_relative '../lib/envo'
require_relative 'mock_opts'
require_relative 'mock_ctx'
require 'test/unit'

include Envo

class TestCmdClean < Test::Unit::TestCase
  def test_cli_parse
    parsed = CmdClean.parse_cli ['--x', 'foo', 'bar', '--y']
    assert_equal parsed.opts, ['--x', '--y']
    assert_instance_of CmdClean, parsed.cmd
    assert_equal parsed.cmd.names, ['foo', 'bar']

    assert_raise(Envo::Error.new 'clean: no names provided') do
      CmdClean.parse_cli []
    end

    assert_raise(Envo::Error.new 'clean: no names provided') do
      CmdClean.parse_cli ['--a', '-b']
    end
  end

  def test_cli_parser
    parser = CliParser.new(MockOpts)
    CmdClean.register_cli_parser(parser)
    parsed = parser.parse(['--foo', 'clean', '--bar', 'name', '-z'])
    assert_equal parsed.opts, {foo: true}
    assert_equal parsed.cmds.size, 1
    assert_instance_of CmdClean, parsed.cmds[0].cmd
    assert_equal parsed.cmds[0].cmd.names, ['name']
    assert_equal parsed.cmds[0].opts, {bar: true, baz: true}
  end

  def test_script_parser
    parser = ScriptParser.new(MockOpts)
    CmdClean.register_script_parser(parser)
    parsed = parser.parse(['{baz,bar} clean name'])
    assert_empty parsed.opts
    assert_equal parsed.cmds.size, 1
    assert_instance_of CmdClean, parsed.cmds[0].cmd
    assert_equal parsed.cmds[0].cmd.names, ['name']
    assert_equal parsed.cmds[0].opts, {bar: true, baz: true}
  end
end
