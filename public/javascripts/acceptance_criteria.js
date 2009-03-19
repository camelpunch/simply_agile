var AcceptanceCriteria = {
  init: function() {
    AcceptanceCriteria.formInit();
    AcceptanceCriteria.createCheckBoxes();
    AcceptanceCriteria.bindCheckBoxes();
    AcceptanceCriteria.anchorInit();
  },

  bindCheckBoxes: function() {
    var form, checked;

    $('input[type=checkbox][name=acceptance_criterion[complete]]').change( function() {
      checked = $(this).attr('checked');
      form = $(this).parents('form');

      if (!checked) {
        $(this).before('<input type="hidden" value="false" name="acceptance_criterion[complete]" />');
      }

      form.ajaxSubmit({
        success: function(data, status) { 
          new Flash({notice: data})
        }
      });
    });
  },

  createCheckBoxes: function() {
    var hidden, checked;

    $('input[name=acceptance_criterion[complete]]').each( function() {
      // checked status needs to be opposite of hidden field value
      checked = $(this).val() == 'true' ? '' : ' checked="checked"';

      // add the checkbox with correct checked status
      $(this).before('<input type="checkbox" value="true" name="acceptance_criterion[complete]"'+checked+' />');

      // remove hidden field
      $(this).remove();
    });
  },

  formInit: function() {
    $('#acceptance_criteria .delete form, #acceptance_criteria form.add').ajaxForm({
      target: '#acceptance_criteria .content',
      resetForm: true,
      error: function(xhr) { alert(xhr.responseText) },
      success: function() {
        $('input#acceptance_criterion_criterion').focus();
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
            $('input#edit_acceptance_criterion_criterion').focus();

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
