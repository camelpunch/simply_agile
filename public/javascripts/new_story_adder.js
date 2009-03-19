function NewStoryAdder() {
  $('a#contextual_new_story').click( function() {
    new Request({
      url: this.href,

      // draw button when selector found
      final: 'input#acceptance_criterion_criterion', 

      beforeClose: function() {
        // the following attempts to recognise a story/show url
        var url_parts = this.url.split('/');
        var last_part = url_parts[url_parts.length-1];
        var rejected = $.inArray(last_part, ['stories', 'new']);
        var not_rejected = rejected == -1;

        if (not_rejected) {
          $.ajax({
            url: this.url + '/estimate',
            success: function(html, status) {
              // add the story to the available list
              $('#stories_available>ol').prepend(html)

              // re-initialise the page
              StorySwapper.init_stories();
              $('a.move').remove();
              StorySwapper.convert_checkboxes();
              StorySwapper.update_estimates();

              $('a.expand').remove();
              StoryToggler.init();
            }
          });
        }
      }
    }); 
    return false;
  });
}
