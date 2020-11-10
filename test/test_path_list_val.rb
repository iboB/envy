require_relative '../lib/envy'
require 'test/unit'

include Envy

class TestPathListVal < Test::Unit::TestCase
  class MockSys
    def self.path_exists?(path)
      path == '/foo/bar'
    end
  end

  def test_casts
    pl = PathListVal.new(MockSys, ['/foo/bar'])

    assert_equal pl.type, :"path list"
    assert pl.list?
    assert_equal pl.ar, ['/foo/bar']

    assert_nil pl.invalid_description

    other = ListVal.new(['xx'])
    assert !pl.accept_assign?(other)

    other = PathListVal.new(MockSys, ['/bar/baz'])
    assert pl.accept_assign?(other)

    other.ar.clear
    assert_equal other.invalid_description, 'empty list'

    item = StringVal.new('xx')
    assert !pl.accept_item?(item)

    item = PathVal.new(MockSys, '/xx')
    assert pl.accept_item?(item)
  end
end