function Flash(messages) {
  this.messages = messages;
  this.draw();
}

Flash.prototype = {
  draw: function() {
    var insert_after, actions;
    actions = $('#actions');
    insert_after = actions[0] ? actions : $('h1');

    // remove previous messages
    this.remove();

    insert_after.after('<div class="flash"></div>')
    if (this.messages.notice && $.trim(this.messages.notice) != '') {
      $('.flash').append('<div class="notice"><h2>Notice</h2><p>'+this.messages.notice+'</p></div>');
    }
  },

  remove: function() {
    $('.flash').remove();
  }
}
