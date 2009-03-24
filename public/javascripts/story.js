function Story(element) {
  var instance = this;
  this.element = $(element);
  this.acceptance_criteria = this.element.find('.acceptance_criteria');

  // add 'more' link if needed
  if (this.element.find('.acceptance_criteria')[0]) {
    this.element.find('ol li:last-child')
      .css({position: 'relative'})
      
      .append('<a class="more" href="#more">More</a>')

      .find('a.more').click(function() {
        var acceptance_criteria = $(this).parents('.story').find('.acceptance_criteria');
        acceptance_criteria.toggle();    

        instance.setMoreHtml();

        return false;
      });

    this.setMoreHtml();
  }
}
Story.prototype = {
  setMoreHtml: function() {
    this.element.find('a.more')
      .html(this.acceptance_criteria.is(':visible') ? '« Less' : 'More »')
  }
}
