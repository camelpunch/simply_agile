function NewStoryAdder() {
  $('a#contextual_new_story').click( function() {
    new Request({
      url: this.href,

      final: {
        selector: 'input#acceptance_criterion_criterion', 
        afterOpen: function() {
          $('#acceptance_criteria').after('<p class="guidance">You can edit acceptance criteria after you\'ve finished planning the iteration.</p>');
        }
      },

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
              // add the story to the list
              $($('ol li.story')[0]).before(html);

              new Story($('ol>li.story:first-child'));

              // re-initialise the page
              StorySwapper.initStories();
              $('a.move').remove();
              StorySwapper.convertCheckBoxes();
              StorySwapper.updateEstimates();
            }
          });
        }
      }
    }); 
    return false;
  });
}
