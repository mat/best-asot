require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asot do
  before(:each) do
    @valid_attributes = {
      :no => "1",
      :di_url => "value for di_url",
      :di_votes => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    Asot.create!(@valid_attributes)
  end
end
