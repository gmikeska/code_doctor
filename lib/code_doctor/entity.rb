module CodeDoctor
  class Language
    class Entity

      def initialize(**args)
        @name = args[:name]
        @type = args[:type]
        @file = args[:file]
        if(!!args[:selector])
          @selector = args[:selector]
        else
          @selector = {start_line:args[:start_line], end_line:args[:end_line]}
        end
        @selection = args[:selection]
        @expects_types = args[:expects]
      end

      def arity
        return @expects_types.length
      end

    end
  end
end
