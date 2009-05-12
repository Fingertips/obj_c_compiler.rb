# ObjCCompiler is a simple module that allows you to compile Obj-C classes into a bundle so you can test them with Rucola.
module ObjCCompiler
  
  # Raised when something is wrong with compilation
  class CompileError < ::StandardError; end
  
  # Encapsulates the bundle to be built.
  class Bundle
    attr_accessor :short_path, :frameworks
    
    def initialize(short_path, *frameworks)
      self.short_path = short_path
      self.frameworks = frameworks
    end
    
    def class_name
      File.basename(short_path)
    end
    
    def to_sym
      class_name.to_sym
    end
    
    def path
      File.join(self.class.output_directory, "#{class_name}.bundle")
    end
    
    def implementation_file
      File.join(Rucola::RCApp.root_path, "#{short_path}.m")
    end
    
    def verify_implementation_file
      full_path = implementation_file
      function = "void Init_#{class_name}"
      unless File.read(full_path).include?(function)
        raise CompileError, "Implementation file `#{full_path}' should include the necessary Ruby init function `#{function}() {}'."
      end
    end
    
    def stale?
      return true if !File.exist?(path)
      return true if File.mtime(implementation_file) >= File.mtime(path)
      false
    end
    
    def compile
      if stale?
        verify_implementation_file
        self.class.ensure_output_directory!
        
        frameworks.unshift 'Foundation'
        command = "gcc -o #{path} -flat_namespace -undefined suppress -bundle #{frameworks.map { |f| "-framework #{f}" }.join(' ')} -I#{File.dirname(implementation_file)} #{implementation_file}"
        unless system(command)
          raise CompileError, "Unable to compile class `#{class_name}' at path: `#{full_path}'."
        end
      end
    end
    
    def self.output_directory
      File.join(Rucola::RCApp.root_path, 'build', 'bundles')
    end
    
    def self.ensure_output_directory!
      FileUtils.mkdir_p(output_directory) unless File.exist?(output_directory)
    end
  end
  
  def self.require(path, *frameworks)
    bundle = Bundle.new(path, *frameworks)
    bundle.compile
    Kernel.require bundle.path
    OSX.ns_import bundle.to_sym
  end
end