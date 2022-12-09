module CodeDoctor
  class SourceFile < Snippet
    attr_accessor :entities
    def initialize(file_path, **args)
      @path = file_path
      if(!args[:open] || args[:open] == false)
        self.open()
        super(@file)
      end
    end
    def file_name
      result = @path.split("/").last
      def result.basename()
        File.basename(self, self.extname)
      end
      def result.extname()
        File.extname(self)
      end

      result
    end
    def open
      f = File.open(@path)
      @file = f.read
      f.close
      @lines = @file.lines.map.with_index{|l,i| {i:i, line:l}}
      read_entities
    end
    def save
      File.write(@path,@file)
    end
    def method_missing(m,*args)
      if(m.to_s.include?("_names") && language.entity_types.include?(m.to_s.split('_').first))
        et = m.to_s.split('_').first
        @entities[pluralize(et)].keys
      end
    end
    private
    def pluralize(str)
      if(str.end_with?("s"))
        return str+"es"
      else
        return str+"s"
      end
    end
  end
end
