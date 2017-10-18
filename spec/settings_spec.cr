require "./spec_helper"
require "../src/icr/settings"

module Icr
  describe Settings do
    it "holds a path to a setting file" do
      Settings::PATH.should_not be_nil
    end

    it "has print_usage_warning Bool flag" do
      Settings.load.print_usage_warning.should be_true
    end

    describe "#save" do
      it "can save settings to a file" do
        begin
          settings = Settings.load
          settings.save
        ensure
          File.exists?(Settings::PATH).should be_true
        end
      end
    end
  end
end
