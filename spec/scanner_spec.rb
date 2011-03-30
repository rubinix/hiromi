require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Scanner" do

  context "when scanning plain text" do

    it "tokenizes plain text" do
      text = "Hello, world!"
      scanner = Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[0]
      token.should == [:static, "Hello, world!"]
    end

  end

  context "when scanning text with variable tags" do

    it "tokenizes plain text" do
      text = "Hello, {{ target }}!"
      scanner = Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[0]
      token.should == [:static, "Hello, "]
    end

    it "tokenizes variable tags" do
      text = "Hello, {{ target }}!"
      scanner = Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[1]
      token.should == [:variable_tag, "{{ target }}"]
    end
  end

  context "when scanning text with block tags" do
    it "tokenizes block tags" do
      text = "{% if passes_spec? %}"
      scanner = Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[0]
      token.should == [:block_tag, "{% if passes_spec? %}"]
    end
  end

end

