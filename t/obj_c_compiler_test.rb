require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../../obj_c_compiler', __FILE__)

class ObjCCompilerBundleTest < TestCase
  def setup
    super
    
    @bundle = ObjCCompiler::Bundle.new('lib/SearchKit/Match', 'CoreServices')
  end
  
  test "uses an output directory in the project root path build directory" do
    assert_equal(@temporary_directory + '/build/bundles', ObjCCompiler::Bundle.output_directory)
  end
  
  test "can ensure the output directory" do
    ObjCCompiler::Bundle.ensure_output_directory!
    assert File.exists?(ObjCCompiler::Bundle.output_directory)
  end
  
  test "extracts the class name from the supplied path" do
    assert_equal('Match', @bundle.class_name)
  end
  
  test "coerces to a symbol representing the class name" do
    assert_equal(:Match, @bundle.to_sym)
  end
  
  test "uses a bundle path in the projet root path build directory" do
    assert_equal(@temporary_directory + '/build/bundles/Match.bundle', @bundle.path)
  end
  
  test "knows which file should contain the implementation" do
    assert_equal(@temporary_directory + '/lib/SearchKit/Match.m', @bundle.implementation_file)
  end
  
  test "raises a compile error when there is no initialize stub in the implementation file" do
    @bundle.stubs(:implementation_file).returns(File.expand_path("../../f/Wrong.m", __FILE__))
    assert_raises(ObjCCompiler::CompileError) do
      @bundle.verify_implementation_file
    end
  end
  
  test "does not raise a compile error when there is an initialize stub in the implementation file" do
    @bundle.stubs(:implementation_file).returns(File.expand_path("../../f/Match.m", __FILE__))
    assert_nothing_raised do
      @bundle.verify_implementation_file
    end
  end
  
  test "compiles a class" do
    @bundle.stubs(:implementation_file).returns(File.expand_path("../../f/Match.m", __FILE__))
    @bundle.compile
    
    assert File.exist?(@bundle.path)
    assert File.size(@bundle.path) > 0
  end
end

class ObjCCompilerTest < TestCase
  test "compiles, requires and imports a class written in Obj-C" do
    lib_directory = File.expand_path('lib', @temporary_directory);
    FileUtils.mkdir_p(lib_directory)
    FileUtils.cp(File.expand_path('../../f/Match.h', __FILE__), lib_directory)
    FileUtils.cp(File.expand_path('../../f/Match.m', __FILE__), lib_directory)
    
    ObjCCompiler.require('lib/Match', 'CoreServices')
    
    assert_nothing_raised do
      match = OSX::Match.alloc.init
      match.score = 12
      assert_equal 12, match.score
    end
  end
end