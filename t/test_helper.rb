require 'rubygems'
require 'test/unit'
require 'mocha'
require 'rucola'

class TestCase < Test::Unit::TestCase
  def setup
    @temporary_directory = File.expand_path('../_tmp', __FILE__)
    Rucola::RCApp.stubs(:root_path).returns(@temporary_directory)
  end
  
  def teardown
    FileUtils.rm_rf(@temporary_directory)
  end
  
  def self.test(description, &block)
    define_method("test_#{description.gsub(/\s+/,'_')}", &block)
  end
  
  def default_test; end
end