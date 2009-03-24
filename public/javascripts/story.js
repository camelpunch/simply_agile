function Story(element) {
  var instance = this;
  this.element = $(element);
  this.story_content = this.element.find('ol');
  this.acceptance_criteria = this.element.find('.acceptance_criteria');

  this.createContainer();
  this.createLessAnchor();

  if (this.acceptance_criteria[0]) {
    this.createMoreAnchor();
  }
}
Story.prototype = {
  createContainer: function() {
    this.element.find('h3').after('<div class="less_more"></div>');
    this.container = this.element.find('.less_more');
  },

  createMoreAnchor: function() {
    var instance = this;

    // add 'more' link if needed
    this.container
      .append('<a class="more" href="#more">More</a>')

      .find('a.more').click(function() {
        instance.acceptance_criteria.toggle();    
        instance.setMoreHtml();
        return false;
      });

    this.more = this.container.find('a.more');
    this.setMoreHtml();
  },

  setMoreHtml: function() {
    var html;

    if (this.acceptance_criteria.is(':visible')) { 
      html = '« Less'
      this.less.hide();
    } else {
      html = 'More »';
      this.less.show();
    }
    this.more.html(html);
  },

  createLessAnchor: function() {
    var instance = this;

    this.container.append('<a class="less" href="#less">Less</a>');
    this.less = this.container.find('a.less');

    this.less.click(function() {
      instance.story_content.toggle();
      instance.setLessHtml();
      return false;
    });

    this.setLessHtml();
  },

  setLessHtml: function() {
    var html;

    if (this.story_content.is(':visible')) {
      html = '« Less';
      if (this.more) this.more.show();
    } else {
      html = 'More »';
      if (this.more) this.more.hide();
    }

    this.less.html(html);
  }
}
