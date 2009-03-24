var DraggableStories = {

  init: function() {
    // add some guidance
    $('ol.stories').before('<div class="guidance"><p>Drag stories to set their statuses</p></div>');

    DraggableStories.labelColumns();
    DraggableStories.createContainer();
    
    // make droppables for each input box
    $('input[name="story[status]"]').each(DraggableStories.createDroppables);

    // handle resize event
    $(window).resize( function() {
      // remove all JSy elements
      $('.draggables').remove();

      // re-initialise
      DraggableStories.createContainer();
      $('input[name="story[status]"]').each(DraggableStories.createDroppables);
    });
  },

  // should be bound to a single radio button
  createDroppables: function() {
    var form = $(this).parents('form');
    var container = form.find('.draggables');
    var li = $(this).parents('li');
    var content = li.find('.content');
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
          form.ajaxSubmit({
            success: function() {
              if (DraggableStories.previous_status == 'complete' || status == 'complete') {
                var location_parts = location.href.split('/');
                var iteration_id = location_parts[location_parts.length - 1];
                $('#burndown').attr('src',
                                    '/iterations/' + iteration_id +
                                    '/burndown?' + new Date().getTime());
              }

              DraggableStories.previous_status = status;
            }
          });
          
          // change class of elements
          var draggable = container.find('.ui-draggable');
          DraggableStories.setDraggableStatus(draggable, status);

          // custom snapping
          $(ui.draggable).css('left', $(this).position().left);
        }
      });

    // make a draggable if button is checked
    if ($(this).attr('checked')) {
      droppable_position = droppable.position();
      droppable.addClass('ui-state-highlight');

      container.append('<div class="story" id="draggable_' + this.id + '">'+content.html()+'</div>');

      var draggable = $('#draggable_' + this.id);
      draggable.draggable({ 
          revert: 'invalid',
          axis: 'x', 
          containment: 'parent',
          cursor: 'pointer'
        })
        .css('position', 'absolute')
        .css('top', droppable_position.top)
        .css('left', droppable_position.left);

      DraggableStories.setDraggableStatus(draggable, status);
    }

    // remove 'story' class from li
    li.removeClass('story');
  },

  createContainer: function() {
    // make draggable container for each form
    $('ol.stories form').each( function() {
      $(this).append('<div class="draggables"></div>');
    });
  },

  // make headings based on first set of labels
  labelColumns: function() {
    var html = '<div id="headings"><ol>';

    $($('form.edit_story')[0]).find('label').each( function() {
      var label = $(this).html();
      var label_for = $(this).attr('for');
      var class_name = $('#'+label_for).val();

      html += '<li class="'+class_name+'">'+label+'</li>';
    });
    html += '</ol></div>';

    $('ol.stories').before(html);
  },

  setDraggableStatus: function(draggable, status) {
    draggable.removeClass('pending');
    draggable.removeClass('in_progress');
    draggable.removeClass('testing');
    draggable.removeClass('complete');
    draggable.addClass(status);
  }
}
