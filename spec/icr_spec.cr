require "./spec_helper"

describe Icr do

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

    it "fails when colorize is not required first" do
      input = <<-CODE
      "hello".responds_to?(:colorize)
      CODE
      icr(input).should match /false/
    end
  end
end
