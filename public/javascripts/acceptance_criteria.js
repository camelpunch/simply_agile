var AcceptanceCriteria = {
  init: function() {
    AcceptanceCriteria.formInit();
    AcceptanceCriteria.createMissingTables();
    AcceptanceCriteria.createCheckBoxes();
    AcceptanceCriteria.bindCheckBoxes();
    AcceptanceCriteria.anchorInit();
  },

  bindCheckBoxes: function(base) {
    var form, checked, checked_before_removal, tr;

    if (!base) base = $('body');

    $(base).find('input[type=checkbox][name=acceptance_criterion[complete]]').click( function() {
      checked = $(this).attr('checked');
      form = $(this).parents('form');
      criterion = $(this).parents('tr');

      if (!checked) {
        $(this).before('<input type="hidden" value="false" name="acceptance_criterion[complete]" />');
      }

      form.submit();
    });
  },

  createCheckBoxes: function() {
    var id, hidden, checked, name_td, name;

    $('input[name=acceptance_criterion[complete]]').each( function() {
      id = $(this).attr('id');
      name_td = $(this).parents('tr').find('td.name');
      name = name_td.html();

      // checked status needs to be opposite of hidden field value
      checked = $(this).val() == 'true' ? '' : ' checked="checked"';

      // add the checkbox with correct checked status
      $(this).before(
        '<input id="'+id+'" type="checkbox" value="true" name="acceptance_criterion[complete]"'+checked+' />'
      );

      // wrap name in a label
      name_td.html('<label for="'+id+'">'+name+'</label>');

      // remove hidden field
      $(this).remove();
    });
  },

  createMissingTables: function() {
    if (!$('#completed table')[0]) $('#completed').prepend('<table></table>');
    if (!$('#uncompleted table')[0]) $('#uncompleted').prepend('<table></table>');
  },

  formInit: function(base) {
    if (!base) base = $('#acceptance_criteria');
    $(base).find('.delete form, form.add').ajaxForm({
      target: '#acceptance_criteria .content',
      resetForm: true,
      error: function(xhr) { alert(xhr.responseText) },
      success: function() {
        $('input#acceptance_criterion_criterion').focus();
        AcceptanceCriteria.init();
      }
    });
  },

  anchorInit: function(base) {
    if (!base) base = $('#acceptance_criteria tr');
    $(base).each( function() {
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
