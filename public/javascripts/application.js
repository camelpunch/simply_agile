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

function Request(options) {
  this.url = options.url;

  var request = this;

  $.ajax({ 
    url: this.url, 
    success: function(html) { request.draw(html) }
  });

  if (options.beforeClose) {
    this.beforeClose = options.beforeClose;
  }
}

Request.prototype = {
  autoFocus: function() {
    $('#request .auto_focus').focus(); 
  },

  bindForms: function() {
    var request = this;

    // special cases
    if ($('input#acceptance_criterion_criterion')[0]) {
      AcceptanceCriteria.init();

    } else {
      // generic form binding
      $('#request form').ajaxForm({
        error: function(xhr, status) { request.handleFormError(xhr, status) },
        success: function(data, status) { request.handleFormSuccess(data, status) },
        complete: function(xhr, status) { request.handleFormCompletion(xhr, status) }
      });
    }
  },

  draw: function(html) {
    $('body').prepend('<div id="request_container"><div id="request">'+html+'</div></div>');
    this.createCloseLink();
    this.bindForms();
    this.autoFocus();
  },

  handleFormError: function(xhr, status) {
    $('#request').html(xhr.responseText);
    this.bindForms();
    this.createCloseLink();
    this.autoFocus();
  },

  handleFormSuccess: function(data, status) {
    this.close();
  },

  handleFormCompletion: function(xhr, status) {
    if (xhr.status == 201) {
      var loc = xhr.getResponseHeader('Location');
      this.close();
      new Request({ url: loc,
                    beforeClose: this.beforeClose });
    }
  },

  close: function() {
    this.beforeClose();
    $('#request_container').remove();
    return false;
  },

  createCloseLink: function() {
    var request = this;
    $('#request').prepend('<a id="close_request" href="#close" accesskey="c">Close</a>');
    $('a#close_request').click( function() { request.close() });
  }
}

// add header to AJAX requests to play nice with Rails' content negotiation
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript")
  } 
});
