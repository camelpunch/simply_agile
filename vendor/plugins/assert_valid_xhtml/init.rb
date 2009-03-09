require 'active_support/test_case'
require 'xml/libxml'
require 'md5'
require 'assert_valid_xhtml'
ActiveSupport::TestCase.class_eval do 
  include AssertValidXhtmlInstance
end

