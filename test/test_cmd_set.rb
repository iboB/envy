require_relative '../lib/envo'
require_relative 'mock_opts'
require_relative 'mock_ctx'
require 'test/unit'

include Envo

class TestCmdSet < Test::Unit::TestCase
  def test_cli_parse
    parsed = CmdSet.parse_cli ['--x', 'foo', '=', 'bar', 'b az', '--y']
    assert_equal parsed.opts, ['--x', '--y']
    assert_instance_of CmdSet, parsed.cmd
    assert_equal parsed.cmd.name, 'foo'
    assert_equal parsed.cmd.value, ['bar', 'b az']

    parsed = CmdSet.parse_cli ['--x', 'foo=', 'bar']
    assert_equal parsed.opts, ['--x']
    assert_instance_of CmdSet, parsed.cmd
    assert_equal parsed.cmd.name, 'foo'
    assert_equal parsed.cmd.value, ['bar']

    parsed = CmdSet.parse_cli ['foo=bar', '--x']
    assert_equal parsed.opts, ['--x']
    assert_instance_of CmdSet, parsed.cmd
    assert_equal parsed.cmd.name, 'foo'
    assert_equal parsed.cmd.value, ['bar']

    parsed = CmdSet.parse_cli ['foo', '=bar']
    assert_equal parsed.opts, []
    assert_instance_of CmdSet, parsed.cmd
    assert_equal parsed.cmd.name, 'foo'
    assert_equal parsed.cmd.value, ['bar']

    parsed = CmdSet.parse_cli ['foo', '=']
    assert_equal parsed.opts, []
    assert_instance_of CmdUnset, parsed.cmd
    assert_equal parsed.cmd.names, ['foo']

    parsed = CmdSet.parse_cli ['foo=']
    assert_equal parsed.opts, []
    assert_instance_of CmdUnset, parsed.cmd
    assert_equal parsed.cmd.names, ['foo']

    assert_raise(Envo::Error.new "set: missing '='. Use 'set <name> = <val>'") do
      CmdSet.parse_cli []
    end

    assert_raise(Envo::Error.new "set: missing '='. Use 'set <name> = <val>'") do
      CmdSet.parse_cli ['a', 'b', 'c', '--foo']
    end

    assert_raise(Envo::Error.new "set: bad name ''. Use 'set <name> = <val>'") do
      CmdSet.parse_cli ['=']
    end

    assert_raise(Envo::Error.new "set: bad name ''. Use 'set <name> = <val>'") do
      CmdSet.parse_cli ['=b']
    end

    assert_raise(Envo::Error.new "set: bad name 'a b'. Use 'set <name> = <val>'") do
      CmdSet.parse_cli ['a', 'b', '=']
    end
  end

  def test_cli_parser
    parser = CliParser.new(MockOpts)
    CmdSet.register_cli_parser(parser)
    parsed = parser.parse(['--foo', 'set', '--bar', 'foo', '=', 'bar', '-z'])
    assert_equal parsed.opts, {foo: true}
    assert_equal parsed.cmds.size, 1
    assert_instance_of CmdSet, parsed.cmds[0].cmd
    assert_equal parsed.cmds[0].cmd.name, 'foo'
    assert_equal parsed.cmds[0].cmd.value, ['bar']
    assert_equal parsed.cmds[0].opts, {bar: true, baz: true}
  end

  def test_script_parser
    parser = ScriptParser.new(MockOpts)
    CmdSet.register_script_parser(parser)
    parsed = parser.parse(['set foo=bar'])
    assert_empty parsed.opts
    assert_equal parsed.cmds.size, 1
    assert_instance_of CmdSet, parsed.cmds[0].cmd
    assert_equal parsed.cmds[0].cmd.name, 'foo'
    assert_equal parsed.cmds[0].cmd.value, ['bar']
    assert_equal parsed.cmds[0].opts, {}
  end

  def test_execute
    ctx = MockCtx.new
    cmd = CmdSet.new('str', StringVal.new('asdf'))

    cmd.execute(ctx)
    assert_equal ctx.sets.keys, ['str']
    assert_same ctx.sets.values[0], cmd.value
    assert_empty ctx.questions

    ctx.reset
    cmd.name = 'foo'
    cmd.execute(ctx)
    assert_equal ctx.sets.keys, ['foo']
    assert_same ctx.sets.values[0], cmd.value
    assert_empty ctx.questions

    ctx.reset
    cmd.name = 'list'
    ctx.answers = [true]
    cmd.execute(ctx)
    assert_equal ctx.sets.keys, ['list']
    assert_same ctx.sets.values[0], cmd.value
    assert_equal ctx.questions, ['Assign string to list?']

    ctx.reset
    ctx.answers = [false]
    assert_raise(Envo::Error.new 'set: assignment of string to list') do
      cmd.execute(ctx)
    end

    ctx.reset
    cmd.name = 'path32'
    cmd.value = PathVal.new(ctx.host, '/foo/bar')
    ctx.answers = [true]
    cmd.execute(ctx)
    assert_equal ctx.sets.keys, ['path32']
    assert_same ctx.sets.values[0], cmd.value
    assert_equal ctx.questions, ['Assign non-existing path to path32?']

    ctx.reset
    ctx.answers = [false]
    assert_raise(Envo::Error.new 'set: assignment of non-existing path to path32') do
      cmd.execute(ctx)
    end
  end
end
