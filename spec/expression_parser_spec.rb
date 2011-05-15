require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Hiromi::ExpressionParser" do

  it "parses an AND operator" do
    expression = "true and true"
    parser = Hiromi::ExpressionParser.new(expression)
    parser.parse().should == true
  end

end
