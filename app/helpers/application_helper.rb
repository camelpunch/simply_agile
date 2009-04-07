module ApplicationHelper
  def next_steps(&block)
    content = '<div id="next_steps"><h2>Next Steps</h2>'
    content += yield if block_given?
    content += '</div>'
  end

  def card_number(last_four_digits)
    last_four_digits.to_s.rjust(4, '0').rjust(16, '*')
  end

  def session_url_with_protocol(options = {})
    if RAILS_ENV == 'production'
      session_url(options.merge(:protocol => 'https'))
    else
      session_url options
    end
  end
  
  def users_url_with_protocol(options = {})
    if RAILS_ENV == 'production'
      users_url(options.merge(:protocol => 'https'))
    else
      users_url options
    end
  end

  def google_analytics_tag(id)
    if controller.google_analytics?
      
      <<JAVASCRIPT
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("#{id}");
pageTracker._initData();
pageTracker._trackPageview();
</script>
JAVASCRIPT
    end
  end

  def story_format(content)
    return nil if content.blank?
    items = content.split("\n")

    xml = Builder::XmlMarkup.new
    xml.ol do
      items.each do |item|
        xml.li do |li|
          li << h(item)
        end
      end
    end
  end

  def contextual_new_story_path
    if @iteration && !@iteration.new_record? && @iteration.pending?
      [:new, @project, @iteration, :story]
    elsif @project
      [:new, @project, :story]
    else
      new_story_path
    end
  end

  def body_classes
    @body_classes ||= [controller.controller_name]
  end

  def render_flash
    return nil if flash.keys.empty?
    xml = Builder::XmlMarkup.new
    xml.div :class => 'flash' do
      flash.each do |type, message|
        next if message.blank?
        xml.div :class => type do
          xml.h2 type.to_s.titleize
          xml.p do |p|
            p << message
          end
        end
      end
    end
  end

end
