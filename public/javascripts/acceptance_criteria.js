var AcceptanceCriteria = {
  init: function() {
    AcceptanceCriteria.formInit();
    AcceptanceCriteria.anchorInit();
  },

  formInit: function() {
    $('#acceptance_criteria .delete form, #acceptance_criteria form.add').ajaxForm({
      target: '#acceptance_criteria .content',
      resetForm: true,
      error: function(xhr) { alert(xhr.responseText) },
      success: function() {
        $('input#acceptance_criterion_criterion').select();
        AcceptanceCriteria.init();
      }
    });
  },

  anchorInit: function() {
    $('#acceptance_criteria tr').each( function() {
      var tr = this;
      $(tr).find('a').click( function() {
        $.ajax({
          url: this.href,
          success: function(html) {
            // first reset the list
            $('tr.display').show();
            $('tr.edit').remove();

            // then insert new content
            $(tr).before(html);

            // select element
            $('input#edit_acceptance_criterion_criterion').select();

            // hide display version
            $(tr).hide();

            AcceptanceCriteria.formInit();
          }
        });

        return false;
      });
    });
  }
}
