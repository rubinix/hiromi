require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Hirmoi:VariableNode" do

  context "with an invalid bracket" do

    it "raises a TemplateSyntaxError" do
      # lambda {Hiromi::VariableNode.new("name {")}.should raise_error(Hiromi::TemplateSyntaxError)
    end

  end

  context "with valid content" do
    let(:context) { Hiromi::Context.new(:name => 'Name', :child => Struct.new("Child", :name).new("Name")) }

    it "renders plain variables" do
      node = Hiromi::VariableNode.new("name")
      node.render(context).should == 'Name'
    end

    it "renders content that can receive messages" do
      node = Hiromi::VariableNode.new("child.name")
      node.render(context).should == 'Name'
    end

  end

end
