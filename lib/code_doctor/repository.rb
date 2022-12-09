module CodeDoctor
  class Repository
    attr_accessor :path, :subpaths, :rx, :files, :current_file

    def initialize(**args)
      @path = args[:path].gsub("~","/home/greg")
      @rx = args[:rx] || Regexp.new("")
      @files = Dir.glob("#{path}/*.rb")
      @subpaths = {}

      self.subpath(:models, "/app/models")
      self.subpath(:components, "/app/components")
    end

    def files(options=nil)
      if(options.is_a?(Hash))
        if(!!options[:path] && options[:path].is_a?(String))
          subpath = options[:path]
        else
          subpath = "/"
        end
        ext_separator = "."
        if(!!options[:type] && options[:type].is_a?(String))
          ext = options[:type]
          if(ext.start_with?(ext_separator))
            ext = ext[1,ext.length]
          end
        elsif(!!options[:type] && options[:type] == :directory)
          ext = ""
          ext_separator = ""
        else
          ext = "*"
        end
        if(!!options[:file] && options[:file].is_a?(String))
          if(!!ext && ext != "")
            file_name = "#{options[:file]}#{ext_separator}#{ext}"
          else
            file_name = "#{options[:file]}.*"
          end
        else
          file_name = "*.#{ext}"
        end
        searchpath_glob = File.join(self.path, subpath, file_name)
        # puts searchpath_glob
      elsif(options.is_a?(String))
        searchpath_glob = options
      elsif(options.nil?)
        searchpath_glob = self.path+"/*.*"
      end
      puts searchpath_glob
      found = Dir.glob(searchpath_glob)
      return FileList.new(self,found)
    end

    def subpath(name,path)
      @subpaths[name.to_sym] = Proc.new{|options={}|options[:path] = path; self.files(options) }
    end

    def types
      CodeDoctor::Languages.detect_repo_type(self)
    end

    def languages
      types.map{|t| CodeDoctor::Languages.language_for(t)}.uniq
    end

    def open_local_file(file_path)
      open_file("#{@path}/#{file_path}")
    end

    def open_file(file_path)
      tenative_name = file_path.split('/').last
      if(!@files[tenative_name].nil?)
        attempts = 1
        while(!@files[tenative_name].nil? && attempts < file_path.split('/').length)
          attempts++
          path_segs = file_path.split('/')
          tenative_name = path_segs[path_segs.length-attempts,attempts]
        end
      end
      @current_file = tenative_name
      @files[tenative_name] = SourceFile.new(file_path)
      return @files[tenative_name]
    end

    def method_missing(m,**args, &block)
      if(!!@subpaths[m.to_sym])
        return @subpaths[m.to_sym].call(**args)
      end
    end
    def query(**selector)
      if(!!selector[:file])
        file = @files[@current_file]
      else
        file = @files[selector[:file]]
      end
      if(!!selector[:rx])

      end
    end

  end
  class FileList < Array
    def initialize(repo, data=nil)
      @repo = repo
      super()
      self.concat(data) if(!!data && data.is_a?(Array))
    end
    def filetypes
      self.collect{|p| p.split('.').last}.uniq
    end
    def method_missing(m)
      if(!!@repo.subpaths[m.to_sym])
        if(!args)
          args = {}
        end
        return @repo.subpaths[m.to_sym].call().to_file_list(@repo)
      elsif(self.filetypes.include?(m.to_sym))
        return self.select{|p| p.split(".").last == m.to_s}.to_file_list(@repo)
      end
    end
  end
end
class Array
  def to_file_list(repo)
    CodeDoctor::FileList.new(repo,self)
  end
end
