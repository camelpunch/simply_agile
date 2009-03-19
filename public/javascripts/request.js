function Request(options) {
  this.url = options.url;

  var request = this;

  $.ajax({ 
    url: this.url, 
    success: function(html) { request.draw(html) }
  });

  if (options.beforeClose) this.beforeClose = options.beforeClose;
  if (options.final) this.final = options.final;
}

Request.prototype = {
  autoFocus: function() {
    $('#request .auto_focus').focus(); 
  },

  bindForms: function() {
    var request = this;

    // special cases - make modular when we have > 1
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
                    beforeClose: this.beforeClose,
                    final: this.final });
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

    if (this.final && $(this.final)[0]) {
      $('#request_body').append('<button type="button" id="done_request">Done</button>');
    }

    $('a#close_request,button#done_request').click( function() { 
      request.close(); 
      return false;
    });
  }
}
