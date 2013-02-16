$(function(){
  var $container = $('#photo-container');

  var showShareres = function(event, visible){
    $target = $(event.target);
    if (visible == true) {
      twttr.widgets.load();
      gapi.plusone.render($target.find('.g-plusone').get(0), {"size":"medium", "annotation": "none"});
    }
  };

  // hide photo items
  $container.find(".photo-item").css({ opacity: 0 });

  // hide page navigation
  $('.pagination').hide();

  // load images
  $container.imagesLoaded( function(){
    var $items = this.find('.photo-item');

    // apply masonry
    $container.masonry({
      itemSelector : '.photo-item',
      columnWidth: 320
    });

    // display the items
    $items.animate({opacity: 1});

    // add sharer show event listener
    $items.find('.share-buttons.with-google-twitter').one('inview', showShareres);
    $(window).scroll();
  });

  // setup infinite scroll
  $container.infinitescroll({
    // debug                 : true,
    navSelector           : 'div.pagination',
    nextSelector          : '.pagination a.next-page',
    itemSelector          : 'div.photo-item',
    pixelsFromNavToBottom : 50,
    bufferPx: 800,
    loading: {
        finishedMsg: 'No more pages to load.',
        msgText: "<em>Loading...</em>"
      }
    },
    // trigger Masonry as a callback
    function( newElements ) {
      // hide new items while they are loading
      var $newElems = $( newElements ).css({ opacity: 0 });

      // ensure that images load before adding to masonry layout
      $newElems.imagesLoaded(function(){
        // show new elems now that they're ready
        $newElems.animate({ opacity: 1 });

        // apply masonry
        $container.masonry( 'appended', $newElems, true );

        // add sharer show event listener
        this.find('.share-buttons.share-buttons.with-google-twitter').one('inview', showShareres);
        $(window).scroll();
      });
    }
  );
});
