var StorySwapper = {
  init: function() {
    // create an iteration stories div
    $('#stories_available')
      .before('<div id="stories_iteration_container"><div class="section" id="stories_iteration"><span class="estimate">Story Points (<span class="numeric">0</span>)</span><h2>Iteration stories</h2><ol class="stories"></ol></div></div>');

    // wrap the available div
    var available_div = $('#stories_available').remove();
    $('#stories_iteration_container').after('<div id="stories_available_container"><div class="section" id="stories_available"><span class="estimate">Story Points (<span class="numeric">0</span>)</span>'+available_div.html()+'</div></div>');

    StorySwapper.initStories();
    StorySwapper.convertCheckBoxes();
    StorySwapper.bindEstimates();
    StorySwapper.updateEstimates();
  },

  // add the story to the specified ol, maintaining the original order
  appendStory: function(story, ol) {
    var stories = ol.find('li.story');

    var source_index = $.inArray(story.attr('id'), StorySwapper.story_order);

    var inserted = false;

    stories.each( function() {
      destination_index = $.inArray(this.id, StorySwapper.story_order);

      var above = source_index <= destination_index;

      if (above) {
        $(this).before(story);
        inserted = true;
        return false; // break
      }
    });

    if (!inserted) {
      ol.append(story);
    }
  },

  convertCheckBoxes: function() {
    $('input[type="checkbox"]').each( function() {
      // make links that toggle the checkboxes
      $(this).before('<a class="move" href="#'+this.id+'">Move</a>');
    });

    StorySwapper.bindAnchors();
  },

  bindAnchors: function() {
    $('a.move').click( function() {
      var id = this.href.split('#')[1];
      var input = $('input#'+id);
      input.click();
      StorySwapper.moveCheckBoxStory(input);
      StorySwapper.bindAnchors();
      return false;
    });
  },

  initStories: function() {
    // store initial order
    StorySwapper.story_order = $.map($('ol li.story'), function(element, i) {
      return element.id
    });

    // move stories to correct ols - order is maintained without doing anything
    // at this stage
    $('ol li.story').each( function() {
      if ($(this).find('input[checked]:checked')[0]) {
        var story = $(this).remove();
        $('#stories_iteration>ol').append(story);
      }
    });
  },

  moveCheckBoxStory: function(checkbox) {
    var checked_before_removal = checkbox.attr('checked');
    var story = checkbox.parents('li.story').remove();

    var append_to = checked_before_removal 
      ? $('#stories_iteration>ol') 
      : $('#stories_available>ol');

    StorySwapper.appendStory(story, append_to);

    // workaround ie6 bug with checkbox values being reset after append
    if (checked_before_removal != checkbox.attr('checked')) checkbox.click();

    StorySwapper.updateEstimates();
    StorySwapper.bindEstimates();

    new Story(story);
  },

  bindEstimates: function() {
    $('div.estimate input').keyup(StorySwapper.updateEstimates);
  },

  updateEstimates: function() {
    var points;
    var integer;

    $('#stories_iteration,#stories_available').each( function() {
      if ($(this).find('li.story').length == 0) {
        $(this).find('span.estimate').hide();
      } else {
        points = 0;
        $(this).find('div.estimate input').each( function() {
          integer = parseInt($(this).val());
          if (integer) points += integer;
        });
        $(this).find('span.estimate span.numeric').html(points);
        $(this).find('span.estimate').show();
      }
    });

  }
}

