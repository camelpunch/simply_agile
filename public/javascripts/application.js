$(document).ready(function() {
  $('body').addClass('javascript');

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
    DraggableStories.init();
  }
  
  // backlog
  if ($('#backlog')[0]) {
    BacklogPrioritisation.init();
  }
});

function Request(url) {
  $.ajax({ url: url, success: this.draw });
}

Request.prototype = {
  bind_forms: function() {
    // special cases
    if ($('input#acceptance_criterion_criterion')[0]) {
      AcceptanceCriteria.init();
    } else {
      // generic form binding
      $('#request form').ajaxForm({
        error: this.handle_form_error,
        success: this.handle_form_success,
        complete: this.handle_form_completion
      });
    }
  },

  draw: function(html) {
    $('body').prepend('<div id="request_container"><div id="request">'+html+'</div></div>');
    Request.prototype.create_close_link();
    Request.prototype.bind_forms();
  },

  handle_form_error: function(xhr, status) {
    $('#request').html(xhr.responseText);
    Request.prototype.bind_forms();
    Request.prototype.create_close_link();
  },

  handle_form_success: function(data, status) {
    Request.prototype.close();
  },

  handle_form_completion: function(xhr, status) {
    if (xhr.status == 201) {
      var loc = xhr.getResponseHeader('Location');
      Request.prototype.close();
      new Request(loc);
    }
  },

  close: function() {
    $('#request_container').remove();
    return false;
  },

  create_close_link: function() {
    $('#request').prepend('<a id="close_request" href="#close">Close</a>');
    $('a#close_request').click(Request.prototype.close);
  }
}

// add header to AJAX requests to play nice with Rails' content negotiation
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript")
  } 
});
