$(document).ready(function () {
  M.AutoInit();
  $('.dropdown-trigger').dropdown({
    hover: true,
  });
  $('.tabs').tabs({
    swipeable: false,
  });
  $('#sidenav').sidenav({
    edge: 'left'
  });
  $('.fixed-action-btn').floatingActionButton({
  });
  $('.collapsible').collapsible({
    accordion: false
  });
  $('.modal').modal({
    
  });
  $('.scrollspy').scrollSpy({
    scrollOffset: 100
  });
  $('.tooltipped').tooltip({

  });
  $(document).on('click', 'div.collapsible-header', function () {
    $(this).trigger('shown');
  })
  $(document).on('click', 'li.tab a', function () {
    $(this).trigger('shown');
  });
  $(document).on('click', 'div.card', function () {
    $(this).trigger('shown');
  });
  $(document).on('click', 'div.fixed-action-btn', function () {
    $(this).trigger('shown');
  })
});
