require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Hirmoi::Scanner" do

  context "when scanning plain text" do

    it "tokenizes plain text" do
      text = "Hello, world!"
      scanner = Hiromi::Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[0]
      token.type.should == :static
      token.contents.should == "Hello, world!"
    end

  end

  context "when scanning text with variable tags" do

    it "tokenizes plain text" do
      text = "Hello, {{ target }}!"
      scanner = Hiromi::Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[0]
      token.type.should == :static
      token.contents.should == "Hello, "
    end

    it "tokenizes variable tags" do
      text = "Hello, {{ target }}!"
      scanner = Hiromi::Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[1]
      token.type.should == :variable_tag
      token.contents.should == "target"
    end
  end

  context "when scanning text with block tags" do
    it "tokenizes block if tags" do
      text = "{% if passes_spec? %}"
      scanner = Hiromi::Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[0]
      token.type.should == :block_tag
      token.contents.should == "if passes_spec?"
    end

    it "tokenizes block endif tags" do
      text = "{% if passes_spec? %} Bam {% endif %}"
      scanner = Hiromi::Scanner.new
      tokens = scanner.tokenize(text)
      token = tokens[2]
      token.type.should == :block_tag
      token.contents.should == "endif"
    end

    it "tokenizes nested block if tags" do
      text = "{% if passes_spec? %}" +
          "The spec passes!" +
          "{% if notify_parties? %}" +
            "Notifying all parties" +
          "{% else %}" +
            "Crickets" +
          "{% endif %}" +
        "{% endif %}"

      scanner = Hiromi::Scanner.new
      tokens = scanner.tokenize(text)
      tokens.size.should == 8
      tokens[4].type.should == :block_tag
      tokens[4].contents.should == "else"
    end
  end

end

