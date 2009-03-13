$(document).ready(function() {
  $('body').addClass('javascript');

  // highlight first erroneous field / auto focus field
  var first_error_field = $('.field_with_errors')[0];
  if (first_error_field) first_error_field.focus();
  else $('.auto_focus').focus();

  // stories/show
  if ($('body#stories_show')) AcceptanceCriteria.init();

  // iterations/new
  if ($('table#stories_available')[0]) {
    // start swapper
    StorySwapper.init();
    
    // start toggles
    StoryToggler.init();
  }

  // iterations/show when active
  if ($('body#iterations_show .section form.edit_story')[0]) {
    DraggableStories.init();
  }

  // backlog
  if ($('#backlog')) {
    // guidance
    $('#backlog')
      .before('<p class="guidance">Drag stories to change priority.</p>');

    // enable sorting
    $('#backlog').sortable({
      axis: 'y',
      stop: function(event, ui) {
        var ids = $(this).sortable('toArray');
        $(ids).each( function(i) {
          var priority = i + 1;
          var field = $('#' + this + ' input[type="text"]');

          // set new field value
          $(field).val(priority);
        });

        // submit form
        $('form.edit_project').ajaxSubmit();
      }
    });
  }
});

// add header to AJAX requests to play nice with Rails' content negotiation
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript")
  } 
});
