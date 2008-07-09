require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  include UserSpecHelper
  
  before(:each) do
    @user = User.new valid_user_attributes
    @token = TemporaryLink.new
    @user.temporary_links << @token
    @user.save!
    # @token.user = @user
  end
  
  after(:each) do
    @token.destroy
    @user.destroy
  end
  
  it "should be able to find the temporary token associated with it with the finder find_by_temporary_token" do
    User.find_by_temporary_token(@token.token).should == @user
  end
  it "should be able to add a temporary link with the helper method" do
    tl = @user.create_temporary_link
    User.find_by_temporary_token(tl.token).should == @user
  end
  it "should be able to find an active temporary token" do
    tl = @user.create_temporary_link
    User.find_by_active_temporary_token(tl.token).should == @user
  end
  it "should be able to call the latest temporary link" do
    3.times {@user.create_temporary_link}
    @token = TemporaryLink.new
    @user.temporary_links << @token
    @user.find_latest_active_temporary_link.should == @token
  end
end
