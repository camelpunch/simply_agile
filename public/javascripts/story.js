function Story(element) {
  var instance = this;
  this.element = $(element);
  this.story_content = this.element.find('ol');
  this.acceptance_criteria = this.element.find('.acceptance_criteria');

  if (this.element.hasClass('pending')) this.status = 'pending';
  if (this.element.hasClass('in_progress')) this.status = 'in_progress';
  if (this.element.hasClass('testing')) this.status = 'testing';
  if (this.element.hasClass('complete')) this.status = 'complete';

  this.createContainer();
  this.createLessAnchor();

  // add 'more' link if needed
  if (this.acceptance_criteria[0]) {
    this.createMoreAnchor();
  }

  Story.setStatus(this.element, this.status);
}

Story.setStatus = function(element, status) {
  element.removeClass('pending');
  element.removeClass('in_progress');
  element.removeClass('testing');
  element.removeClass('complete');
  element.addClass(status);

  // draw the little fella
  if (!element.hasClass('with_team')) return;

  var img = element.find('img').remove();

  if (status == 'in_progress' || status == 'testing') {
    var html = '<img src="/images/fella_'+status+'.gif" alt="" />';
    element.find('.header').append(html);
  }
}
Story.prototype = {
  createContainer: function() {
    this.element.find('.less_more').remove();
    this.element.find('h3').before('<div class="less_more"></div>');
    this.container = this.element.find('.less_more');
  },

  createMoreAnchor: function() {
    var instance = this;

    this.container
      .append('<a class="more" href="#more">More »</a>')

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
    } else if (!this.story_content.is(':visible')) {
      this.more.hide();
    } else {
      html = 'More »';
      this.less.show();
    }
    this.more.html(html);
  },

  createLessAnchor: function() {
    var instance = this;

    this.container.find('a.less').remove();
    this.container.append('<a class="less" href="#less">« Less</a>');
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
