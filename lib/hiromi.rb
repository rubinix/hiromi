require 'scanner'
require 'parser'

class Hiromi

  attr_accessor :node_list

  def initialize(string)
    self.node_list = compile_template(string)
  end

  def compile_template(string)
    scanner = Scanner.new
    tokens = scanner.tokenize(string)

    parser = Parser.new
    self.node_list = parser.parse(tokens)
  end

  def render(context={})
    self.node_list.render(context)
  end

end
