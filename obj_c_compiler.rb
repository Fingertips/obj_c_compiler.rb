# ObjCCompiler is a simple module that allows you to compile Obj-C classes into a bundle so you can test them with Rucola.
module ObjCCompiler
  class CompileError < ::StandardError; end
  
  class << self
    def require(path, *frameworks)
      compile path, *frameworks
      Kernel.require bundle_path(path)
      OSX.ns_import klass(path).to_sym
    end
    
    private
    
    def klass(path)
      File.basename(path)
    end
    
    def output_directory
      File.join(Rucola::RCApp.root_path, 'build', 'bundles')
    end
    
    def ensure_output_directory!
      FileUtils.mkdir_p(output_directory) unless File.exist?(output_directory)
    end
    
    def bundle_path(path)
      File.join(output_directory, "#{klass(path)}.bundle")
    end
    
    def implementation_file(path)
      File.join(Rucola::RCApp.root_path, "#{path}.m")
    end
    
    def verify_implementation_file(path)
      full_path = implementation_file(path)
      function = "void Init_#{klass(path)}"
      unless File.read(full_path).include?(function)
        raise CompileError, "Implementation file `#{full_path}' does not contain the necessary Ruby init function `#{function}() {}'."
      end
    end
    
    def compile(path, *frameworks)
      verify_implementation_file(path)
      full_path = implementation_file(path)
      ensure_output_directory!
      frameworks.unshift 'Foundation'
      
      command = "gcc -o #{bundle_path(path)} -flat_namespace -undefined suppress -bundle #{frameworks.map { |f| "-framework #{f}" }.join(' ')} -I#{File.dirname(full_path)} #{full_path}"
      unless system(command)
        raise CompileError, "Unable to compile class `#{klass(path)}' at path: `#{full_path}'."
      end
    end
  end
end