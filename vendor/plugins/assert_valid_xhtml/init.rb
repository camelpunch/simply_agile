require 'xml/libxml'
require 'md5'
require 'assert_valid_xhtml'
Test::Unit::TestCase.class_eval do 
  include AssertValidXhtmlInstance
end

