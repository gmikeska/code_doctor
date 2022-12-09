module CodeDoctor
  class Language
    attr_reader :default_file_type, :file_types, :repo_types, :file_extension, :entity_types

  end
  module Languages
    def self.language_for(repo_type)
      self.constants.map do |lang|
        if(lang.repo_types.keys.include?(repo_type))
          lang
        end
      end
    end
    def self.detect_repo_type(repo)
      # require "pry"; binding.pry
      results = []
      self.constants.each do |lang|
        lang = CodeDoctor::Languages.const_get(lang).new()
        lang.repo_types.each do |type, type_data|
          require "pry";binding.pry
          if(Dir[File.join(repo.path, type_data[:has_file])].count > 0)
            results << type
          end
        end
      end
      return results
    end
    def self.detect_language(source_file)
      result = nil
      ext = source_file.file_name.extname[1, source_file.file_name.extname.length]
      self.constants.each do |lang|
        lang = CodeDoctor::Languages.const_get(lang).new()
        if(lang.file_types.include?(ext.to_sym))
          result = lang
        end
      end
      return result
    end
  end
end
