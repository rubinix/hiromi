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

    context "when handling if blocks" do
      it "renders the text in the true branch upon evaluating to true" do
        context[:is_tall_enough] = true
        hiromi = Hiromi.new('Hello Allen{% if is_tall_enough %}, you are tall.{% endif %}')
        hiromi.render(context).should == 'Hello Allen, you are tall.'
      end
      it "renders the text outside of the true branch upon evaluating to false" do
        context[:is_tall_enough] = false
        hiromi = Hiromi.new('Hello Allen{% if is_tall_enough %}, you are tall.{% endif %}')
        hiromi.render(context).should == 'Hello Allen'
      end
      it "renders the text in else branch upon evaluating to false" do
        context[:is_tall_enough] = false
        hiromi = Hiromi.new("Hello Allen{% if is_tall_enough %}, you are tall.{% else %}, sorry, you aren't tall enough.{% endif %}")
        hiromi.render(context).should == "Hello Allen, sorry, you aren't tall enough."
      end
    end

  end
end
