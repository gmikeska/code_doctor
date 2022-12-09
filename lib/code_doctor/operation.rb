module CodeDoctor
  class Operation
    attr_accessor :files, :entitites
    def initialize(project, path=nil, **options)
      @options = options
      @project = project
      @save_path = path
      @files = {}
      @entities = {}
      @call_chain = CallChain.new()
    end

    def add_file(name,source_file_path=nil)
      if(!source_file_path)
        file = @project.files[name]
      else
        file = @project.open_local_file(source_file_path)
      end
      @files[name] = file
    end

    def select_entity(file_name, entity_type, entity_name,**args)
      if(!args[:as])
        if(!!@options[:namespace_entity_types])
          args[:as] = "#{entity_type}.#{entity_name}"
        else
          args[:as] = entity_name
        end
      end
      @entities[args[:as]] = {file_name:file_name,entity_type:entity_type,entity_name:entity_name,body:@files[file_name].select_entity(entity_type,entity_name)}
    end

    def add_action(**args)
      @call_chain.add_call(**args)
    end

    def get_pointer(entity_as_name)
      pointer_data = {file:@entities[entity_as_name][:file_name], type:@entities[entity_as_name][:entity_type], name:@entities[entity_as_name][:entity_name]}
      return "#{pointer_data[:file]}@#{pointer_data[:entity_type]}:#{pointer_data[:entity_name]}"
    end
    def parse_pointer(pointer)
      pointer_data = pointer.scan(/(?<file>[^@]*)@(?<type>[^:]*):(?<name>.*)/)
      return {file:pointer_data["file"], type:pointer_data["type"], name:pointer_data["name"]}
    end

  end
end
