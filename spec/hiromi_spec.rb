require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Hiromi" do
  it "renders plain text" do
    hiromi = Hiromi.new('Hello, world!')
    hiromi.render.should == 'Hello, world!'
  end

  context "given a context of data" do
    let(:context) do
      {:target => 'world', :name => 'Allen'}
    end

    it "substitutes a string key with it's context value" do
      hiromi = Hiromi.new('Hello, {{target}}!')
      hiromi.render(context).should == 'Hello, world!'
    end

    it "substitutes multiple string tokens with 'X'" do
      hiromi = Hiromi.new('Hello, {{ target }}, my name is {{ name }}!')
      hiromi.render(context).should == 'Hello, world, my name is Allen!'
    end

  end
end
