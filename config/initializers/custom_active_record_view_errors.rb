# Changes default Rails behaviour when displaying form fields with errors.
# Instead of wrapping tags in a div, which invalidates the XHTML, we just add a
# class to the element instead
module ActionView
  class Base
    @@field_error_proc = Proc.new do |html_tag, instance| 
      if html_tag.include?('class="')
        html_tag.sub(/class="/, 'class="field_with_errors ')
      else
        html_tag.sub(/<(\w*) /, '<\1 class="field_with_errors" ')
      end
    end
    cattr_accessor :field_error_proc
  end
end
