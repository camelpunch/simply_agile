$(document).ready(function() {
  // no JS support for shit browsers
  if (!$.support.boxModel) {
    var message = "<p>Your browser does not support modern web standards. "+
    "Please upgrade to a more recent browser for a better experience.</p>";

    if ($('.important_message')[0]) {
      $('.important_message div').prepend(message);
    } else {
      $('#content').after('<div class="important_message"><div>'+message+'</div></div>');
    }

    $('.important_message')
      .css({position: 'absolute', textAlign: 'center', opacity:0.9});
    $('.important_message div')
      .css({width:'auto', 
            margin:0});
    return false; 
  }
  $('#container').addClass('javascript');

  // highlight first erroneous field / auto focus field
  var first_error_field = $('.field_with_errors')[0];
  if (first_error_field) first_error_field.focus();
  else $('.auto_focus').focus();

  // stories/show
  if ($('body#stories_show')) AcceptanceCriteria.init();

  // iterations/new
  if ($('#stories_available')[0]) {
    // start swapper
    StorySwapper.init();
    
    // AJAXy story adding
    new NewStoryAdder();
  }

  // iterations/show when active
  if ($('body').hasClass('iteration_active')) {
    new DraggableStories();
    // don't enhance stories
  } else if (!$('body#home_show')[0]) {
    // normal story enhancements
    $('#content .story').each( function() { new Story(this) });
  }
  
  // backlog
  if ($('body#stories_backlog')[0]) {
    BacklogPrioritisation.init();
  }

});

// add header to AJAX requests to play nice with Rails' content negotiation
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript")
  } 
});
