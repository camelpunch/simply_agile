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

    // make draggable container for each form
    $('#stories_list form').each( function() {
      $(this).append('<div class="draggables"></div>');
    });

    // make droppables for each input box
    $('input[name="story[status]"]').each( function() {
      var form = $(this).parents('form');
      var container = form.find('.draggables');
      var value = $(this).val();

      form.append('<div id="droppable_' + this.id + '"></div>');

      var droppable = $('#droppable_' + this.id)
        .droppable({ 
          drop: function(ev, ui) { 
            var id_parts = this.id.split('_');
            var story_id = id_parts[id_parts.length - 1];
            $('li#story_'+story_id+' ol input').val([value]); // checks the radio button
            form.find('.ui-droppable').removeClass('ui-state-highlight');
            $(this).addClass('ui-state-highlight');
          }
        });

      // initialisation
      if ($(this).attr('checked')) {
        // make a draggable
        droppable_position = droppable.position();
        droppable.addClass('ui-state-highlight');

        form.append('<div id="draggable_' + this.id + '"></div>');

        $('#draggable_' + this.id)
          .draggable({ axis: 'x' })
          .css('position', 'absolute')
          .css('top', droppable_position.top)
          .css('left', droppable_position.left);
      }
    });
  }
});

// add header to AJAX requests to play nice with Rails' content negotiation
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {
    xhr.setRequestHeader("Accept", "text/javascript")
  } 
});
