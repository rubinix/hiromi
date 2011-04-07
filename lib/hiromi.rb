require 'scanner'
require 'parser'
require 'context'
require 'railtie'

module Hiromi

  class Template

    attr_accessor :node_list

    def initialize(string)
      self.node_list = compile_template(string)
    end

    def self.from_file(path)
      template_string = ''
      File.open(path, 'r') do |file|
        template_string = file.read()
      end
      self.new(template_string)
    end

    def render(context={})
      self.node_list.render(context)
    end

    private

    def compile_template(string)
      scanner = Hiromi::Scanner.new
      parser = Hiromi::Parser.new(scanner.tokenize(string))
      self.node_list = parser.parse()
    end

  end

end
