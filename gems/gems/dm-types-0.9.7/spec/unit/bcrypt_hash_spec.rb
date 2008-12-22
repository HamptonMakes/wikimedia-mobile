require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

include DataMapper::Types

begin
  require 'bcrypt'
rescue LoadError
  skip_tests = true
end

describe "DataMapper::Types::BCryptHash" do
  unless skip_tests

    before(:each) do
      @clear_password = "DataMapper R0cks!"
      @crypted_password = BCrypt::Password.create(@clear_password)
    end

    describe ".dump" do
      it "should return a crypted hash as a BCrypt::Password" do
        BCryptHash.dump(@clear_password, :property).should be_an_instance_of(BCrypt::Password)
      end

      it "should return a string that is 60 characters long" do
        BCryptHash.dump(@clear_password, :property).should have(60).characters
      end

      it "should return nil if nil is passed" do
        BCryptHash.dump(nil, :property).should be_nil
      end
    end

    describe ".load" do
      it "should return the password as a BCrypt::Password" do
        BCryptHash.load(@crypted_password, :property).should be_an_instance_of(BCrypt::Password)
      end

      it "should return the password as a password which matches" do
        BCryptHash.load(@crypted_password, :property).should == @clear_password
      end

      it "should return nil if given nil" do
        FilePath.load(nil, :property).should be_nil
      end
    end
  else
    it "requires the bcrypt-ruby gem to test"
  end
end
