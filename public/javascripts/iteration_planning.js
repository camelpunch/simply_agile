var StorySwapper = {
  init: function() {
    // create an iteration stories table
    $('table#stories_available').before('<table id="stories_iteration"><caption>Iteration stories</caption></table>');
    StorySwapper.init_trs();
    StorySwapper.convert_checkboxes();
  },

  convert_checkboxes: function() {
    $('input[type="checkbox"]').each( function() {
      var label = $('label[for="'+this.id+'"]');

      // hide checkboxes
      $(this).hide();
      label.hide();

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
      StorySwapper.move_checkbox_tr(input);
      StorySwapper.bind_anchors();
      return false;
    });
  },

  init_trs: function() {
    // move trs to correct tables
    $('table tr').each( function() {
      if ($(this).find('input[checked]:checked')[0]) {
        var tr = $(this).remove();
        $('table#stories_iteration').append(tr);
      }
    });
  },

  move_checkbox_tr: function(checkbox) {
    var checked_before_removal = checkbox.attr('checked');
    var tr = checkbox.parent('td').parent('tr').remove();

    if (checked_before_removal) {
      $('table#stories_iteration').append(tr);

      // workaround ie6 bug with checkbox values being reset after append
      if (checked_before_removal != checkbox.attr('checked')) checkbox.click();

    } else {
      $('table#stories_available').append(tr);
    }

    StoryToggler.bind_anchors(tr);
  }
}

var StoryToggler = {
  init: function() {
    // collapse all story content
    $('.content').hide();

    // insert expand links
    $('table tr').each( function() {
      $(this).find('span')
      .after(' <a class="expand" href="#'+this.id+'">Peek</a>');
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
    return false;
  }
}
