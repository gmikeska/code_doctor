module CodeDoctor
  class CallChain
    attr_accessor :base
    attr_reader :calls
    def initialize(**args)
      if(args[:base])
        @base = args[:base]
      end
      @calls = []
      if(args[:calls])
        args[:calls].each do |c|
          self.add_call(c)
        end
      end
    end
    def add_iterative(**args)
      add_call({iterator:args[:iterator], call:args[:call]})
    end
    def add_assignment(**args)
      add_call({assign:args[:value], to:args[:var_name])
    end
    def add_array(name,args)
      add_call({assign:[].concat(args), to:name})
    end
    def add_hash(name,args)
      add_call({assign:args, to:name})
    end
    def add_call(args)
      if(args.is_a?(String) || args.is_a?(Symbol))
        @calls << {call:args.to_sym}
      elsif(args.is_a?(Array))
        @calls << {call:args[0], args:args[1,args.length]}
      elsif(args.is_a?(Hash) && !!args[:call])
        @calls << args
      end
    end
    def revert()
      @calls.pop()
    end
    def to_s
      if(!!@base)
        result = @base.name
      else
        result = "Base"
      end
      puts "result = #{result}"
      @calls.each do |mc|
        call_text = "result = result.#{mc[:call]}"
        if(mc[:proc])
          call_text = "#{call_text}(&:#{mc[:proc]})"
        elsif(!!mc[:args] || !!mc[:args_splat] || !!mc[:args_double_splat])
          if(!mc[:args])
            mc[:args] = []
          end
          if(!!mc[:args_splat])
            args_text = mc[:args].concat(mc[:args_splat]).join(',')
          elsif(!!mc[:args_double_splat])
            args_text = [mc[:args].join(','),mc[:args_double_splat].collect{|k,v|v = "\"#{v}\"" if(v.is_a?(String)); "#{k}:#{v}"}].flatten.join(',')
          else
            args_text = mc[:args].join(',')
          end

          puts "#{call_text}(#{args_text})"
        else
          puts "#{call_text}()"
        end
      end
    end
    def call(base=nil)
      if(!base)
        base = @base
      end
      @calls.each do |call|
        if(call[:call].is_a? CallChain)
          base = call[:call].call(base)
        else
          if(call[:args_splat])
            base = base.send(call[:call],*call[:args_splat])
          elsif(call[:args_double_splat])
            base = base.send(call[:call],*call[:args],**call[:args_double_splat])
          elsif(call[:proc])
            base = base.send(call[:call], &call[:proc])
          else
            base = base.send(call[:call],*call[:args])
          end
        end
      end
      return base
    end
    def serialize_base
      if(@base.respond_to?(:pointer))
        @base.pointer
      else
        if(!!@base)
          return "_model_#{@base.name}"
        else
          return nil
        end
      end
    end
    def to_json(*args)
      {JSON.create_id  => self.class.name,
        'a'             => {base:serialize_base, calls:@calls}
      }.to_json(*args)
    end
    def self.json_create(data)
      data = data.deep_symbolize_keys[:a]
      if(!!data[:base] && data[:base].match(/_model_(?<model_name>\w*)/))
        data[:base] = data[:base].match(/_model_(?<model_name>\w*)/)["model_name"].constantize
      elsif(!!data[:base] && ApplicationRecord.is_pointer?(data[:base]))
        data[:base] = ApplicationRecord.resolve_pointer(data[:base])
      end
      result = self.new(**data)

    end
    # def self.from_json(call_chain_json)
    #   data = JSON.parse(call_chain_json).symbolize_keys
    #   data[:base] = ApplicationRecord.resolve_pointer(data[:base])
    #   data[:calls] = data[:calls].map do |c|
    #     c = c.symbolize_keys
    #     if(c[:args_double_splat])
    #       c[:args_double_splat] = c[:args_double_splat].symbolize_keys
    #     end
    #     c
    #   end
    #   return self.new(**data)
    # end
  end
end
