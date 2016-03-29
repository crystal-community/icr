require "../spec_helper"

describe "icr command" do
  it "returns the passed value" do
    icr("13").should match /\=> 13/
    icr("\"Saluton\"").should match /\=> "Saluton"/
  end

  it "does simple arithmetic" do
    icr("2 + 2").should match /\=> 4/
  end

  it "allows to define variables" do
    input = <<-CRYSTAL
      a = 10
      b = 20
      c = a + b
    CRYSTAL
    icr(input).should match /\=> 10.*\=> 20.*\=> 30/m
  end

  it "does not repeat previous output" do
    input = <<-CRYSTAL
      puts "Saluton"
      puts "mondo!"
    CRYSTAL
    icr(input).should match /Saluton.*=> nil.*mondo!.* => nil/m
  end

  it "allows to require files" do
    input = <<-CRYSTAL
      require "io/**"
      MemoryIO.new("abc").to_s
    CRYSTAL
    icr(input).should match /\=> ok.*\=> "abc"/m
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
      icr(input).should match /unexpected token: >>.*=> 13/m
    end

    it "prints compilation error without crashing" do
      input = <<-CRYSTAL
        var
        13
      CRYSTAL
      output = icr(input)
      output.should match /undefined local variable or method 'var'/
      output.should match /13/
    end

    it "prints runtime error without crashing" do
      input = "\"5a\".to_i"
      output = icr(input)
      output.should match /invalid Int32: 5a \(ArgumentError\)/
    end
  end

  describe "quiting" do
    it "allows to quit with 'exit' command" do
      input = <<-CRYSTAL
        exit
        1313
      CRYSTAL
      icr(input).should_not match /1313/
    end

    it "allows to quit with 'quit' command" do
      input = <<-CRYSTAL
        quit
        1313
      CRYSTAL
      icr(input).should_not match /1313/
    end

    it "do not exit if 'exit' or 'quit' is part of other code" do
      input = <<-CRYSTAL
        puts "I do not want to exit"
        puts "nor quit"
      CRYSTAL
      icr(input).should match /I do not want to exit/
      icr(input).should match /nor quit/
    end
  end

  describe "assignment with operator" do
    it "allows to execute *= operation" do
      input = <<-CRYSTAL
        a = 123
        a *= 2
      CRYSTAL
      icr(input).should match /246/
    end
  end
end
