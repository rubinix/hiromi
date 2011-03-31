class Token

  attr_accessor :type, :contents, :line_number

  def initialize(type, contents, line_number=nil)
    self.type = type
    self.contents = contents
    self.line_number = line_number
  end

end
