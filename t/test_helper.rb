require 'rubygems'
require 'test/unit'
require 'mocha'
require 'rucola'

class TestCase < Test::Unit::TestCase
  def self.test(description, &block)
    define_method("test_#{description.gsub(/\s+/,'_')}", &block)
  end
  def default_test; end
end