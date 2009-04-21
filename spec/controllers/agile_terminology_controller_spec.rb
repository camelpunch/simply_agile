require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AgileTerminologyController do

  describe "GET 'project'" do
    it "should be successful" do
      get 'project'
      response.should be_success
    end
  end

  describe "GET 'organisation'" do
    it "should be successful" do
      get 'organisation'
      response.should be_success
    end
  end

  describe "GET 'story'" do
    it "should be successful" do
      get 'story'
      response.should be_success
    end
  end

  describe "GET 'iteration'" do
    it "should be successful" do
      get 'iteration'
      response.should be_success
    end
  end
end
