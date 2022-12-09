module CodeDoctor
  class Snippet
    def initialize(content=nil)
      @content = content
      enumerate_entities
    end
    def language
      CodeDoctor::Languages.detect_language(self)
    end

    def select_entity(entity_type,entity_name)
      entity = @entities[entity_type][entity_name]
      line_index = @file.split('\n')[entity[:start_line]]
      cursor = index_from_line(entity[:start_line],0)
      return @file.select(cursor: cursor, length:entity.length)
    end

    def index_from_line(line_index, line_number)
      return @file.split("\n")[0,line_number-1].sum(&:length)+line_index
    end

    def enumerate_entities
      @entities = {}
      self.language.entity_types.each do |type_name|
        @entities[self.pluralize(type_name)] = {}
      end
      numbered_lines.each do |data|
        language.entity_types.each do |entity_type|
          selector = language.selector_for(entity_type)
          if(data[:line].match(selector))
            name = data[:line].match(selector)["#{entity_type}_name"]
            if(name.include?("<"))
              super_entity = name.split("<")[1].lstrip.rstrip
              name = name.split("<")[0].lstrip.rstrip
            else
              super_entity = "Object"
            end
            @entities["modules"][name] = {
                              entity_type:entity_type,
                              start_line: data[:i]
                              }
            if(!!super_entity)
              @entities["modules"][name]["super_#{entity_type}".to_sym] = super_entity
            end
          end
        end
      end
      language.entity_types.each do |entity_type|
        if(self.send("#{entity_type}_names").length > 1)
          self.send("#{entity_type}_names").each_with_index do |name,i|
            list_for_entity_type = pluralize(entity_type)
            entity = @entities[list_for_entity_type][name]
            start_line = @entities[list_for_entity_type][name][:start_line]
            if(name != self.send("#{entity_type}_names").last)
              next_entity = @entities[list_for_entity_type][self.send("#{entity_type}_names")[i+1]]
              search_start = @entities[list_for_entity_type][name][:start_line]
              search_end = next_entity[:start_line]-1
              require 'pry';binding.pry
              @entities[list_for_entity_type][name][:end_line] = numbered_lines[search_start,search_end].select{|l| l[:line].match(/end/)}.last[:i]
            else
              @entities[list_for_entity_type][name][:end_line] = numbered_lines.select{|l| l[:line].match(/\s*end[\z\s]*/)}.last[:i]
            end
            line_count = @entities[list_for_entity_type][name][:end_line]-@entities[list_for_entity_type][name][:start_line]
            @entities[list_for_entity_type][name][:body] = Selection.new(parent:@file,cursor:@file.lines[0,@entities[list_for_entity_type][name][:start_line]].join('').length, length:line_count)
          end
        elsif(self.send("#{entity_type}_names").length > 0)
          name = self.send("#{entity_type}_names").first
          list_for_entity_type = pluralize(entity_type)
          entity = @entities[list_for_entity_type][name]
          entity[:end_line] = numbered_lines.reverse.select{|l| l[:line].match(/\s*end[\z\s]*/)}.first[:i]
        end

      end
    end
    def enumerated?
      return(!!@entities && @entities.keys.any?)
    end
    def numbered_lines
      result = @content.lines.map.with_index{|l,i| {i:i, line:l, expressions:l.split(';')}}
      def result.expressions; self.map{|l| l[:expressions]}; end
    end
  end
end
