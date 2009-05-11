require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../../obj_c_compiler', __FILE__)

class ObjCCompilerTest < TestCase
  def setup
    @temporary_directory = File.expand_path('../_tmp', __FILE__)
    Rucola::RCApp.stubs(:root_path).returns(@temporary_directory)
  end
  
  def teardown
    FileUtils.rm_rf(@temporary_directory)
  end
  
  test "extracts the class name from the supplied path" do
    assert_equal('Match', ObjCCompiler.send(:klass, 'lib/SearchKit/Match'))
  end
  
  test "uses an output directory in the project root path build directory" do
    assert_equal(@temporary_directory + '/build/bundles', ObjCCompiler.send(:output_directory))
  end
  
  test "can ensure the output directory" do
    ObjCCompiler.send(:ensure_output_directory!)
    assert File.exists?(ObjCCompiler.send(:output_directory))
  end
  
  test "uses a bundle path in the projet root path build directory" do
    assert_equal(@temporary_directory + '/build/bundles/searchkit.bundle', ObjCCompiler.send(:bundle_path, '/path/to/searchkit'))
  end
  
  test "knows which file should contain the implementation" do
    assert_equal(@temporary_directory + '/lib/SearchKit/Match.m', ObjCCompiler.send(:implementation_file, 'lib/SearchKit/Match'))
  end
  
  test "raises a compile error when there is no initialize stub in the implementation file" do
    path = 'f/Wrong'
    ObjCCompiler.stubs(:implementation_file).returns(File.expand_path("../../#{path}.m", __FILE__))
    
    assert_raises(ObjCCompiler::CompileError) do
      ObjCCompiler.send(:verify_implementation_file, path)
    end
  end
  
  test "does no raise a compile error when there is an initialize stub in the implementation file" do
    path = 'f/Match'
    ObjCCompiler.stubs(:implementation_file).returns(File.expand_path("../../#{path}.m", __FILE__))
    
    assert_nothing_raised do
      ObjCCompiler.send(:verify_implementation_file, path)
    end
  end
  
  test "compiles a class" do
    path = 'f/Match'
    ObjCCompiler.stubs(:implementation_file).returns(File.expand_path("../../#{path}.m", __FILE__))
    ObjCCompiler.send(:compile, path)
  end
end