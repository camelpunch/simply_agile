function DraggableStories() {
  var instance = this;

  // add some guidance
  $('ol.stories').before('<div class="guidance"><p>Drag stories to set their statuses</p></div>');

  this.labelColumns();
  this.createContainer();
  
  // make droppables for each input box
  $('input[name="story[status]"]').each( function() {
    new DroppableStatus(this);
  });

  // handle resize event
  $(window).resize( function() {
    // remove all JSy elements
    $('.draggables').remove();

    // re-initialise
    instance.createContainer();
    $('input[name="story[status]"]').each( function() { new DroppableStatus(this) } );
  });
}

function DraggableStory(droppable_status) {
  this.input = droppable_status.input;
  this.droppable = droppable_status.droppable;

  var content = droppable_status.li.find('.content');
  var container = droppable_status.container;
  var status = droppable_status.status;

  droppable_position = this.droppable.position();
  this.droppable.addClass('ui-state-highlight');

  container.append('<div class="story" id="draggable_' + this.input.id + '">'+content.html()+'</div>');

  this.element = $('#draggable_' + this.input.id);
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

function DroppableStatus(input) {
  var instance = this;
  this.input = input;
  this.form = $(this.input).parents('form');
  this.container = this.form.find('.draggables');
  this.li = $(this.input).parents('li');
  this.status = $(this.input).val();

  this.container.append('<div class="'+this.status+'" id="droppable_' + this.input.id + '"></div>');

  this.droppable = $('#droppable_' + this.input.id)
    .droppable({ 
      drop: function(ev, ui) { 
        var id_parts = instance.input.id.split('_');
        var story_id = id_parts[id_parts.length - 1];

        // check the radio button
        $('li#story_'+story_id+' ol input').val([instance.status]);

        // send the request
        instance.form.ajaxSubmit({
          success: function() {
            if (DraggableStories.previous_status == 'complete' || this.status == 'complete') {
              var location_parts = location.href.split('/');
              var iteration_id = location_parts[location_parts.length - 1];
              $('#burndown').attr('src',
                                  '/iterations/' + iteration_id +
                                  '/burndown?' + new Date().getTime());
            }

            DraggableStories.previous_status = this.status;
          }
        });
        
        // change class of elements
        var draggable = instance.container.find('.ui-draggable');
        DraggableStory.setStatus(draggable, instance.status);

        // custom snapping
        $(ui.draggable).css('left', $(this).position().left);
      }
    });

  // make a draggable if button is checked
  if ($(this.input).attr('checked')) {
    new DraggableStory(this); 
  }

  // remove 'story' class from li
  this.li.removeClass('story');
}

DraggableStories.prototype = {

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
