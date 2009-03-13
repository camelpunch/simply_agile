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
});

var DraggableStories = {

  draggable_left_offset: 33,

  init: function() {
    DraggableStories.label_columns();
    DraggableStories.create_container();
    
    // make droppables for each input box
    $('input[name="story[status]"]').each(DraggableStories.create_droppables);
  },

  // should be bound to a single radio button
  create_droppables: function() {
    var form = $(this).parents('form');
    var container = form.find('.draggables');
    var status = $(this).val();
    var id = this.id;

    container.append('<div class="'+status+'" id="droppable_' + this.id + '"></div>');

    var droppable = $('#droppable_' + id)
      .droppable({ 
        drop: function(ev, ui) { 
          var id_parts = id.split('_');
          var story_id = id_parts[id_parts.length - 1];

          // check the radio button
          $('li#story_'+story_id+' ol input').val([status]);

          // send the request
          form.ajaxSubmit();
          
          // change class of elements
          container.find('.ui-droppable').removeClass('ui-state-highlight');
          $(this).addClass('ui-state-highlight');
          $(ui.draggable)
          .css('left', 
               $(this).position().left + DraggableStories.draggable_left_offset);
        }
      });

    // make a draggable if button is checked
    if ($(this).attr('checked')) {
      droppable_position = droppable.position();
      droppable.addClass('ui-state-highlight');

      container.append('<div id="draggable_' + this.id + '"></div>');

      $('#draggable_' + this.id)
        .draggable({ 
          revert: 'invalid',
          opacity: 0.5,
          axis: 'x', 
          containment: 'parent',
          cursor: 'pointer'
        })
        .css('position', 'absolute')
        .css('top', droppable_position.top)
        .css('left', 
             droppable_position.left + DraggableStories.draggable_left_offset);
    }
  },

  create_container: function() {
    // make draggable container for each form
    $('#stories_list form').each( function() {
      $(this).append('<div class="draggables"></div>');
    });
  },

  // make headings based on first set of labels
  label_columns: function() {
    var html = '<ol id="headings">';

    $($('form.edit_story')[0]).find('label').each( function() {
      var label = $(this).html();
      var label_for = $(this).attr('for');
      var class_name = $('#'+label_for).val();

      html += '<li class="'+class_name+'">'+label+'</li>';
    });
    html += '</ol>';

    $('#stories_list').before(html);
  }

}

// add header to AJAX requests to play nice with Rails' content negotiation
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript")
  } 
});
