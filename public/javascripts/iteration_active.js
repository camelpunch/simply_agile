function DraggableStories() {
  var instance = this;

  // add some guidance
  $('ol.stories').before('<div class="guidance"><p>Drag stories to set their statuses</p></div>');

  this.labelColumns();
  this.createContainer();
  
  // make droppables for each input box
  $('input[name="story[status]"]').each( function() {
    instance.createDroppable(this)
  });

  // handle resize event
  $(window).resize( function() {
    // remove all JSy elements
    $('.draggables').remove();

    // re-initialise
    instance.createContainer();
    $('input[name="story[status]"]').each( function() { instance.createDroppable(this) } );
  });
}

function DraggableStory(input, droppable) {
  var li = $(input).parents('ol.stories>li');
  var content = li.find('.content');
  var form = $(input).parents('form');
  var container = form.find('.draggables');
  var status = $(input).val();

  droppable_position = droppable.position();
  droppable.addClass('ui-state-highlight');

  container.append('<div class="story" id="draggable_' + input.id + '">'+content.html()+'</div>');

  this.element = $('#draggable_' + input.id);
  this.element.draggable({ 
      revert: 'invalid',
      axis: 'x', 
      containment: 'parent',
      cursor: 'pointer'
    })
    .css('position', 'absolute')
    .css('top', droppable_position.top)
    .css('left', droppable_position.left);

  DraggableStory.setStatus(this.element, status);
}
DraggableStory.setStatus = function(element, status) {
  element.removeClass('pending');
  element.removeClass('in_progress');
  element.removeClass('testing');
  element.removeClass('complete');
  element.addClass(status);
}

DraggableStories.prototype = {

  createDroppable: function(input) {
    var instance = this;
    var form = $(input).parents('form');
    var container = form.find('.draggables');
    var li = $(input).parents('li');
    var content = li.find('.content');
    var status = $(input).val();
    var id = input.id;

    container.append('<div class="'+status+'" id="droppable_' + id + '"></div>');

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
          DraggableStory.setStatus(draggable, status);

          // custom snapping
          $(ui.draggable).css('left', $(this).position().left);
        }
      });

    // make a draggable if button is checked
    if ($(input).attr('checked')) {
      new DraggableStory(input, droppable); 
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
  }
}
