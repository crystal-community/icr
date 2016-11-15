require "../spec_helper"

describe "icr command" do
  context "passing flag arguments" do
    it "returns nothing for invalid option -c" do
      icr("", "-c").should eq ""
    end

    it "returns the version for option -v" do
      icr("", "-v").should contain(Icr::VERSION)
    end

    it "returns the help menu for option -h" do
      icr("", "-h").should contain("Usage: icr [options]")
    end

    describe "using the -r option" do
      it "requires the colorize lib" do
        input = <<-CODE
          "hello".responds_to?(:colorize)
        CODE
        icr(input, "-r colorize").should match /true/
      end

      it "requires multiple libs colorize and http" do
        input = <<-CODE
          typeof(HTTP).name.responds_to?(:colorize)
        CODE
        icr(input, "-r http", "-r colorize").should match /true/
      end

      it "fails when colorize is not required first" do
        input = <<-CODE
          "hello".responds_to?(:colorize)
        CODE
        icr(input).should match /false/
      end
    end
  end

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

  it "allows to define records" do
    input = <<-CRYSTAL
      record Person, first_name : String, last_name : String do
        def full_name
          first_name + " " + last_name
        end
      end
      Person.new("Mike", "Nog").full_name
    CRYSTAL
    icr(input).should match /Mike Nog/
  end

  it "allows to define struct" do
    input = <<-CRYSTAL
      struct N
        property name : String
        @name : String
        def initialize
          @name = "Default"
        end
        def name : String
        end
        def name=(@name : String)
        end
      end
      N.new.name = "Struct"
    CRYSTAL
    icr(input).should match /Struct/
  end

  it "allows to define multi line hash" do
    input = <<-CRYSTAL
      module Screen
        TILES = {
          0 => {:white, nil},
          2 => {:black, :white}
        }
      end
      Screen::TILES[2]
    CRYSTAL
    icr(input).should match /{:black, :white}/
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

  describe "using an alias" do
    it "aliases Mod to M" do
      input = <<-CRYSTAL
      module Mod
        def self.exe
          1 + 1
        end
      end
      alias M = Mod
      M.exe
      CRYSTAL
      icr(input).should match /2/
    end
  end
end
