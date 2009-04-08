function objectsFromInput(input) {
  this.form = $(input).parents('form');
  this.container = $('#draggables_for_'+this.form.attr('id'));
  this.li = $(input).parents('li');
  this.status = $(input).val();
  this.droppable = $('#droppable_' + input.id);
}
function DraggableStories() {
  // add some guidance
  $('ol.stories').before('<div class="guidance"><p>Drag stories to set their statuses</p></div>');

  DraggableStories.labelColumns();
  DraggableStories.create();

  // handle resize event
  $(window).resize(function() { 
    DraggableStories.create();
    DraggableStories.recently_resized = true;
    setTimeout('DraggableStories.recently_resized = false', 100);
  });
}
DraggableStories.create = function() {
  if (DraggableStories.recently_resized) return false;

  // size div
  full_width = $(window).width();
  if (full_width < 831) {
    $('#burndown').hide();
    full_width += 370;
  } else {
    $('#burndown').show();
  }
  $('#stories').width(full_width - 430);

  // remove all existing JSy elements
  $('#draggables_container').remove();

  // make a container for all draggables
  $('ol.stories').before('<div id="draggables_container"></div>');

  var container = $('#draggables_container');

  // make draggable container for each form
  $('ol.stories form').each( function() {
    container.append('<div id="draggables_for_'+this.id+'" class="draggables"></div>');
  });

  // make droppables for each radio button
  DraggableStories.droppables = $.map($('input[name="story[status]"]'), function(input, i) { 
    return new DroppableStatus(input);
  });

  DraggableStories.draggables = $.map($('input[name="story[status]"]:checked'), function(input, i) {
    return new DraggableStory(input); 
  });
  
  // set height of each row to the height of the draggable content
  $('.draggables').each( function() {
    var height = $(this).find('.story .content').height() + 9;

    $(this).height(height);
    $(this).find('.ui-droppable').height(height);
  });

  // set positions on each draggable
  $(DraggableStories.draggables).each( function() {
    this.setPosition();
  });
}

// make headings based on first set of labels
DraggableStories.labelColumns = function() {
  var html = '<div id="headings"><ol>';

  $($('form.edit_story')[0]).find('label').each( function() {
    var content = $(this).html();
    var label_for = $(this).attr('for');
    var class_name = $('#'+label_for).val();

    html += '<li class="'+class_name+'">'+content+'</li>';
  });
  html += '</ol></div>';

  $('ol.stories').before(html);
}

function DraggableStory(input) {
  var objects = new objectsFromInput(input);
  this.input = input;
  this.droppable = objects.droppable;

  var content = objects.li.find('.content');
  var acceptance_criteria = objects.li.find('.acceptance_criteria');
  var container = objects.container;
  this.status = objects.status;

  var droppable_position = this.droppable.position();
  this.droppable.addClass('ui-state-highlight');

  var classes = 'story';
  if (objects.li.hasClass('with_team')) {
    classes += ' with_team';
  }

  container.append('<div class="'+classes+'" id="draggable_'+
      this.input.id+
      '"><div class="content">'+
      content.html()+
      '</div></div>');

  this.element = $('#draggable_' + this.input.id);

  if (acceptance_criteria[0]) {
    this.element.find('.content').append('<div class="acceptance_criteria">'+
        acceptance_criteria.html()+
        '</div>');
  }

  this.element.draggable({ 
      revert: 'invalid',
      axis: 'x', 
      containment: 'parent',
      cursor: 'pointer'
    })
    .css('position', 'absolute')
    .width(this.droppable.width());

  Story.setStatus(this.element, this.status);
}
DraggableStory.prototype = {
  setPosition: function() {
    var droppable_position = this.droppable.position();
    this.element
      .css('top', droppable_position.top)
      .css('left', droppable_position.left);
  }
}

function DroppableStatus(input) {
  var instance = this;
  this.input = input;
  var objects = new objectsFromInput(input);
  this.form = objects.form;
  this.container = objects.container;
  this.li = objects.li;
  this.status = objects.status;

  this.container.append('<div class="'+this.status+'" id="droppable_' + input.id + '"></div>');

  this.droppable = $('#droppable_' + input.id);
  this.droppable
    .droppable({ 
      drop: function(ev, ui) { 
        var id_parts = instance.input.id.split('_');
        var story_id = id_parts[id_parts.length - 1];

        // check the radio button
        $('li#story_'+story_id+' ol input').val([instance.status]);

        // send the request
        instance.form.ajaxSubmit({
          success: function() {
            if (DroppableStatus.previous_statuses[story_id] == 'complete' || instance.status == 'complete') {
              var location_parts = location.href.split('/');
              var iteration_id = location_parts[location_parts.length - 1];
              $('#burndown img').attr('src',
                                      '/iterations/' + iteration_id +
                                      '/burndown?width=350&' + new Date().getTime());
            }

            DroppableStatus.previous_statuses[story_id] = instance.status;
          }
        });
        
        // change class of elements
        var draggable = instance.container.find('.ui-draggable');
        Story.setStatus(draggable, instance.status);

        // custom snapping
        $(ui.draggable)
          .css('left', $(this).position().left)
          .css('top', $(this).position().top);
      }
    }); 
}

DroppableStatus.previous_statuses = {};
