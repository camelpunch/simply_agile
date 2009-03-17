var StorySwapper = {
  init: function() {
    // create an iteration stories div
    $('#stories_available')
      .before('<div id="stories_iteration_container"><div class="section" id="stories_iteration"><span class="estimate">Estimate</span><h2>Iteration stories</h2><ol></ol></div></div>');

    // wrap the available div
    var available_div = $('#stories_available').remove();
    $('#stories_iteration_container').after('<div id="stories_available_container"><div class="section" id="stories_available"><span class="estimate">Estimate</span>'+available_div.html()+'</div></div>');

    StorySwapper.init_stories();
    StorySwapper.convert_checkboxes();
  },

  // add the story to the specified ol, maintaining the original order
  append_story: function(story, ol) {
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

    if (!inserted) ol.append(story);
  },

  convert_checkboxes: function() {
    $('input[type="checkbox"]').each( function() {
      // make links that toggle the checkboxes
      $(this).before('<a class="move" href="#'+this.id+'">Move</a>');
    });

    StorySwapper.bind_anchors();
  },

  bind_anchors: function() {
    $('a.move').click( function() {
      var id = this.href.split('#')[1];
      var input = $('input#'+id);
      input.click();
      StorySwapper.move_checkbox_story(input);
      StorySwapper.bind_anchors();
      return false;
    });
  },

  init_stories: function() {
    // store initial order
    StorySwapper.story_order = $.map($('ol li.story'), function(element, i) {
      return element.id
    });

    // move stories to correct ols - order is maintained without doing anything
    // at this stage
    $('ol li.story').each( function() {
      if ($(this).find('input[checked]:checked')[0]) {
        var story = $(this).remove();
        $('#stories_iteration ol').append(story);
      }
    });
  },

  move_checkbox_story: function(checkbox) {
    var checked_before_removal = checkbox.attr('checked');
    var story = checkbox.parents('li.story').remove();

    var append_to = checked_before_removal 
      ? $('#stories_iteration ol') 
      : $('#stories_available ol');

    StorySwapper.append_story(story, append_to);

    // workaround ie6 bug with checkbox values being reset after append
    if (checked_before_removal != checkbox.attr('checked')) checkbox.click();

    // show / hide estimate column heading
    $('#stories_iteration,#stories_available').each( function() {
      if ($(this).find('li.story').length == 0) {
        $(this).find('span.estimate').hide();
      } else {
        $(this).find('span.estimate').show();
      }
    });

    StoryToggler.bind_anchors(story);
  }
}

var StoryToggler = {
  init: function() {
    // collapse all story content
    $('.content').hide();

    // insert expand links
    $('ol li.story').each( function() {
      $(this).find('.content')
      .before('<a class="expand" href="#'+this.id+'">Show Story</a>');
    });

    StoryToggler.bind_anchors();
  },

  // expand functionality for story content
  bind_anchors: function(base) {
    if (base) {
      base.find('a.expand').click(StoryToggler.toggle_content);
    } else {
      $('a.expand').click(StoryToggler.toggle_content);
    }
  },

  toggle_content: function() {
    var id = this.href.split('#')[1];
    $('#'+id+' .content').toggle();
    if ($(this).html() == 'Show Story') {
      $(this).html('Hide Story');
    } else {
      $(this).html('Show Story');
    }
    return false;
  }
}
