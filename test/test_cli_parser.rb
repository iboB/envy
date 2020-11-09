require_relative '../lib/envy'
require 'test/unit'

include Envy

class TestCliParser < Test::Unit::TestCase
  def test_basic
    parser = CliParser.new

    parser.add_cmd('foo', ->(cmd, args) {
      assert_equal cmd, 'foo'
      assert_equal args, ['stuff', '--for', 'cmd foo']
      123
    })
    parser.add_cmd('bar', ->(cmd, args) {
      assert_equal cmd, 'bar'
      assert_equal args, ['cmdbar', 'things']
      567
    })

    res = parser.parse(['foo', 'stuff', '--for', 'cmd foo'])
    assert_equal res.size, 2
    assert_equal res[:cmd], 123
    assert_equal res[:opts], {}

    res = parser.parse(['--opt1', '-opt2', 'bar', 'cmdbar', 'things'])
    assert_equal res.size, 2
    assert_equal res[:cmd], 567
    assert_equal res[:opts], {'--opt1' => true, '-opt2' => true}

    assert_raise(Envy::Error.new 'missing command') do
      parser.parse(['--opt1', '-opt2'])
    end

    assert_raise(Envy::Error.new "unknown command 'baz'") do
      parser.parse(['--opt1', 'baz', '-opt2'])
    end
  end
end
