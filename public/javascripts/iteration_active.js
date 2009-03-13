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

          var previous_element = $(ev.originalTarget.previousElementSibling);
          var next_element = $(ev.originalTarget.nextElementSibling);

          if(previous_element.hasClass('complete') || next_element.hasClass('complete')) {
            $('#burndown').attr('src',
                                '/iterations/5/burndown?' + new Date().getTime());
          }
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
