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
