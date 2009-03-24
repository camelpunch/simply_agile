$(document).ready(function() {
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
    
    // start toggles
    StoryToggler.init();

    // AJAXy story adding
    new NewStoryAdder();
  }

  // iterations/show when active
  if ($('body#iterations_show .section form.edit_story')[0]) {
    new DraggableStories();
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
