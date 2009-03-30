module ApplicationHelper
  def render_price(price)
    number_to_currency(price, :unit => '£', :precision => 0)
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
