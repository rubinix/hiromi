module Hiromi

  class Context

    attr_accessor :frames

    def initialize(data={})
      self.frames = []
      self.push(data)
    end

    def get(resolver)
      result = @current[resolver.key]
      return resolver.key if result.nil?

      result = result.instance_eval(resolver.message) if resolver.message
      result
    end

    def put(key, value)
      @current[key] = value
    end

    def push(data={})
      data = @current.merge(data) if @current
      @current = data
      self.frames << data
      data
    end

    def pop()
      self.frames.pop
      @current = frames[-1]
    end

  end

  class InvocationResolver

    attr_accessor :key, :message

    def initialize(contents)

      if numeric?(contents)
        self.key = Float(contents)
      elsif contents =~ /^\s*(true|false)\s*$/
        self.key = contents == true
      else
        parts = contents.split(".")
        key = parts.shift
        self.key = key.to_sym
        self.message = parts.join(".") unless parts.empty?
      end

    end

    def numeric?(object)
      true if Float(object) rescue false
    end

  end

  class ForLoopContext
    attr_accessor :counter, :counter0, :revcounter, :revcounter0, :first, :last, :parentloop
  end

end
