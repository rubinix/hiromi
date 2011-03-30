require 'scanner'
require 'parser'

class Hiromi

  attr_accessor :node_list

  def initialize(string)
    self.node_list = compile_template(string)
  end

  def compile_template(string)
    scanner = Scanner.new
    parser = Parser.new(scanner.tokenize(string))
    self.node_list = parser.parse()
  end

  def render(context={})
    self.node_list.render(context)
  end

end
