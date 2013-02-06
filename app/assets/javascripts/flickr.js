$(function(){
  var $container = $('#photo-container');
  
  $container.imagesLoaded( function(){
    $container.masonry({
      itemSelector : '.photo-item',
      isAnimated: true,
      columnWidth: 320
    });
  });
});
