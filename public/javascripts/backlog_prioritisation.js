var BacklogPrioritisation = {
  init: function() {
    // guidance
    $('#backlog')
      .before('<p class="guidance">Drag stories to change priority.</p>');

    // enable sorting
    $('#backlog').sortable({
      axis: 'y',
      stop: function(event, ui) {
        var ids = $(this).sortable('toArray');
        $(ids).each( function(i) {
          var priority = i + 1;
          var field = $('#' + this + ' input[type="text"]');

          // set new field value
          $(field).val(priority);
        });

        // submit form
        $('form.edit_project').ajaxSubmit();
      }
    });
  }
}
