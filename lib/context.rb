class Context

  def initialize(data)
    data.each do |key, value|
      self.class.send(:define_method, key) {value}
    end
  end

  def put(key, value)
      self.class.send(:define_method, key) {value}
  end

end

class ForLoopContext
  attr_accessor :counter, :counter0, :revcounter, :revcounter0, :first, :last, :parentloop
end
