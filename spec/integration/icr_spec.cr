require "../spec_helper"

describe "icr command" do
  it "returns the passed value" do
    icr("13").should eq "=> 13"
    icr("\"Saluton\"").should eq "=> \"Saluton\""
  end

  it "does simple arithmetic" do
    icr("2 + 2").should eq "=> 4"
  end

  it "allows to define variables" do
    input = <<-CRYSTAL
      a = 10
      b = 20
      c = a + b
    CRYSTAL
    icr(input).should eq "=> 10\n => 20\n => 30"
  end

  it "prints output once" do
    input = <<-CRYSTAL
      puts "Saluton"
      puts "mondo!"
    CRYSTAL
    icr(input).should eq "Saluton\n => nil\nmondo!\n => nil"
  end

  it "allows to require files" do
    input = <<-CRYSTAL
      require "io/**"
      MemoryIO.new("abc").to_s
    CRYSTAL
    icr(input).should eq "=> nil\n => \"abc\""
  end

  it "allows to define multiple line methods method" do
    input = <<-CRYSTAL
      def sqr(x)
        x * x
      end
      sqr(13)
    CRYSTAL
    icr(input).should match /\=> 169/
  end

  it "allows to define modules" do
    input = <<-CRYSTAL
      module MathModule
        def self.sqr(x)
          x * x
        end
      end
      MathModule.sqr(13)
    CRYSTAL
    icr(input).should match /\=> 169/
  end

  it "allows to define classes" do
    input = <<-CRYSTAL
      class MathClass
        def sqr(x)
          x * x
        end
      end
      MathClass.new.sqr(13)
    CRYSTAL
    icr(input).should match /\=> 169/
  end

  describe "errors" do
    it "prints syntax error without crashing" do
      input = <<-CRYSTAL
        >>
        13
      CRYSTAL
      icr(input).should eq "unexpected token: >>\n => 13"
    end

    it "prints runtime error without crashing" do
      input = <<-CRYSTAL
        var
        13
      CRYSTAL
      output = icr(input)
      output.should match /undefined local variable or method 'var'/
      output.should match /13/
    end
  end

  describe "quiting" do
    it "allows to quit with 'exit' command" do
      input = <<-CRYSTAL
        exit
        13
      CRYSTAL
      icr(input).should_not match /13/
    end

    it "allows to quit with 'quit' command" do
      input = <<-CRYSTAL
        quit
        13
      CRYSTAL
      icr(input).should_not match /13/
    end
  end
end
