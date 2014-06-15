/**
 * The images preload plugin
 */
(function(jQuery) {
	jQuery.fn.preload = function(options) {
		var opts 	= jQuery.extend({}, jQuery.fn.preload.defaults, options),
			o		= jQuery.meta ? jQuery.extend({}, opts, this.data()) : opts;
		return this.each(function() {
			var $e	= jQuery(this),
				t	= $e.attr('rel'),
				i	= $e.attr('href'),
				l	= 0;
			jQuery('<img/>').load(function(i){
				++l;
				if(l==2) o.onComplete();
			}).attr('src',i);	
			jQuery('<img/>').load(function(i){
				++l;
				if(l==2) o.onComplete();
			}).attr('src',t);	
		});
	};
	jQuery.fn.preload.defaults = {
		onComplete	: function(){return false;}
	};
	
  jQuery.fn.hint = function (blurClass) {
    if (!blurClass) {
      blurClass = 'blur';
    }
    return this.each(function () {
		  jQuery('label span').remove();
      var $input = jQuery(this),
        title = $input.prev('label').text(),
        $form = jQuery(this.form),
        $win = jQuery(window);
				$input.prev('label').remove();				
				if(!title) {
					title = $input.parent().prev('label').text();								
					$input.parent().prev('label').remove();
				}						
      function remove() {
        if ($input.val() === title && $input.hasClass(blurClass)) {
          $input.val('').removeClass(blurClass);
        }
      }
      if (title) {
        $input.blur(function () {
          if (this.value === '') {
            $input.val(title).addClass(blurClass);
          }
        }).focus(remove).blur();
        $form.submit(remove);
        $win.unload(remove);
      }
    });
  };

})(jQuery);
			
			//
			
jQuery(function() {
	//some elements..
	var $ps_container	   	= jQuery('#ps_container'),
		$ps_image_wrapper 	= $ps_container.find('.ps_image_wrapper'),
		$ps_next		      	= $ps_container.find('.ps_next'),
		$ps_prev			      = $ps_container.find('.ps_prev'),
		$ps_nav				      = $ps_container.find('.ps_nav'),
		$tooltip		      	= $ps_container.find('.ps_preview'),
		$ps_preview_wrapper = $tooltip.find('.ps_preview_wrapper'),
		$links				      = $ps_nav.children('li').not($tooltip),
		total_images		    = $links.length,
		currentHovered	  	= -1,
		current				      = 0,
		$loader			      	= jQuery('#loader');
	
	/*check if you are using a browser*/	
	var ie 				= false;
	if (jQuery.browser.msie) {
		ie = true;//you are not!Anyway let's give it a try
	}
	if(!ie)
		$tooltip.css({
			opacity	: 0
		}).show();
		
		
	/*first preload images (thumbs and large images)*/
	var loaded	= 0;
	$links.each(function(i){
		var $link 	= jQuery(this);
		$link.find('a').preload({
			onComplete	: function(){			
				++loaded;
				if(loaded == total_images){ 
					//all images preloaded,
					//show ps_container and initialize events
					$loader.hide();
					$ps_container.show();
					//when mouse enters the pages (the dots),
					//show the tooltip,
					//when mouse leaves hide the tooltip,
					//clicking on one will display the respective image	
					
					$links.bind('mouseenter',showTooltip)
						  .bind('mouseleave',hideTooltip)
						  .bind('click',showImage);
					//navigate through the images
					$ps_next.bind('click',nextImage);
					$ps_prev.bind('click',prevImage);
				}
			}
		});
	});
	
	function showTooltip(){
		var $link			= jQuery(this),
			idx				= $link.index(),
			linkOuterWidth	= $link.outerWidth(),
			//this holds the left value for the next position
			//of the tooltip
			left			= parseFloat(idx * linkOuterWidth) - $tooltip.width()/2 + linkOuterWidth/2,
			//the thumb image source
			$thumb			= jQuery('a', $link).attr('rel'),
			imageLeft;
		
		//if we are not hovering the current one
		if(currentHovered != idx){
			//check if we will animate left->right or right->left
			if(currentHovered != -1){
				if(currentHovered < idx){
					imageLeft	= 75;
				}
				else{
					imageLeft	= -75;
				}
			}
			currentHovered = idx;
			
			//the next thumb image to be shown in the tooltip
			var $newImage = jQuery('<img/>').css('left','0px').attr('src',$thumb);
			
			//if theres more than 1 image 
			//(if we would move the mouse too fast it would probably happen)
			//then remove the oldest one (:last)
			if($ps_preview_wrapper.children().length > 1)
				$ps_preview_wrapper.children(':last').remove();
			
			//prepend the new image
			$ps_preview_wrapper.prepend($newImage);
			
			var $tooltip_imgs		= $ps_preview_wrapper.children(),
				tooltip_imgs_count	= $tooltip_imgs.length;
				
			//if theres 2 images on the tooltip
			//animate the current one out, and the new one in
			if(tooltip_imgs_count > 1){
				$tooltip_imgs.eq(tooltip_imgs_count-1)
							 .stop()
							 .animate({
								left:-imageLeft+'px'
							  },150,function(){
									//remove the old one
									jQuery(this).remove();
							  });
				$tooltip_imgs.eq(0)
							 .css('left',imageLeft + 'px')
							 .stop()
							 .animate({
								left:'0px'
							  },150);
			}
		}
		//if we are not using a "browser", we just show the tooltip,
		//otherwise we fade it
		//
		if(ie)
			$tooltip.css('left',left + 'px').show();
		else
		$tooltip.stop()
				.animate({
					left		: left + 'px',
					opacity		: 1
				},150);
	}
	
	function hideTooltip(){
		//hide / fade out the tooltip
		if(ie)
			$tooltip.hide();
		else
		$tooltip.stop()
			    .animate({
					opacity		: 0
				},150);
	}
	
	function showImage(e){ 
		var $link			      = jQuery(this),
			idx					      = $link.index(),
			$image				    = $link.find('a').attr('href'),
			$title				    = $link.find('a').text(),
			$currentImage 		= $ps_image_wrapper.find('img'),
			currentImageWidth	= $currentImage.width();
		
		//if we click the current one return
		if(current == idx) return false;
		
		//add class selected to the current page / dot
		$links.eq(current).removeClass('selected');
		$link.addClass('selected');
		
		//the new image element
		var $newImage = jQuery('<img/>').css('left',currentImageWidth + 'px')
								   .attr('src',$image);
		
		//if the wrapper has more than one image, remove oldest
		if($ps_image_wrapper.children().length > 1) {
			$ps_image_wrapper.children(':last').remove();
			$ps_image_wrapper.children('projecttitle').remove();
		}
			
		
		//prepend the new image
		$ps_image_wrapper.prepend($newImage).prepend('<projecttitle>' + $title + '</projecttitle>');
		
		//the new image width. 
		//This will be the new width of the ps_image_wrapper
		var newImageWidth	= $newImage.width();
	
		//check animation direction
		if(current > idx){
			$newImage.css('left',-newImageWidth + 'px');
			currentImageWidth = -newImageWidth;
		}	
		current = idx;
		//animate the new width of the ps_image_wrapper 
		//(same like new image width)
		$ps_image_wrapper.stop().animate({
		    width	: newImageWidth + 'px'
		},350);
		//animate the new image in
		$newImage.stop().animate({
		    left	: '0px'
		},350);
		//animate the old image out
		$currentImage.stop().animate({
		    left	: -currentImageWidth + 'px'
		},350);
	
		e.preventDefault();
	}				
	
	function nextImage(){
		if(current < total_images){
			$links.eq(current+1).trigger('click');
		}
	}
	function prevImage(){
		if(current > 0){
			$links.eq(current-1).trigger('click');
		}
	}
});			
			
			//
						
Drupal.behaviors.initOPCV = {
	attach: function(context) {
	  jQuery('.menu-239 a').attr('href', '#featured_projects');
		jQuery('.menu-240 a').attr('href', '#contact');	
		jQuery('.menu-343 a').attr('href', '#work');
		jQuery('.menu-342 a').attr('href', '#about');	
		
		jQuery('.form-text, .form-textarea').hint();		
	
    jQuery('.projects li figure a img').animate({'opacity' : 1}).hover(function() {
				jQuery(this).animate({'opacity' : .5});
			}, function() {
				jQuery(this).animate({'opacity' : 1});
			});
			jQuery('.zoom img').animate({'opacity' : 1}).hover(function() {
				jQuery(this).animate({'opacity' : .5});
			}, function() {
				jQuery(this).animate({'opacity' : 1});
			});

			jQuery("a[rel=work]").fancybox({
				'transitionIn'		: 'elastic',
				'transitionOut'		: 'elastic',
				'titlePosition' 	: 'over',
				'titleFormat'		: function(title, currentArray, currentIndex, currentOpts) {
					return '<span id="fancybox-title-over">Image ' + (currentIndex + 1) + ' / ' + currentArray.length + (title.length ? ' &nbsp; ' + title : '') + '</span>';
				}
			});
			jQuery("a[rel=recent_work]").fancybox({
				'transitionIn'		: 'elastic',
				'transitionOut'		: 'elastic',
				'titlePosition' 	: 'over',
				'titleFormat'		: function(title, currentArray, currentIndex, currentOpts) {
					return '<span id="fancybox-title-over">Image ' + (currentIndex + 1) + ' / ' + currentArray.length + (title.length ? ' &nbsp; ' + title : '') + '</span>';
				}
			});
						
			var $nCurrentActive;
      var scrolling = 1;
      var $nav = jQuery('navigation li');
      $nav.addClass('off');
			
			var i = 0;
			jQuery('navigation li').each(function() {
			  jQuery(this).attr('id', 'nav-' + ++i);
			});

      // Nav setup @ mouseevents
      $nav.bind('mouseenter', function() {
	      $nCurPos = jQuery(this).attr('id').substr(4);
	      nIsHovered = setTimeout("onMenu($nCurPos)", 100);
      });

      $nav.bind('mouseleave', function() {
	      clearTimeout(nIsHovered);
	      $nCurPos = jQuery(this).attr('id').substr(4);
	      offMenu($nCurPos);
      });

      $nav.bind('click', function(ev) {
	      if ($nCurrentActive !== jQuery(this).attr('id').substr(4)) {
		    offActiveMenu($nCurrentActive);
	    }
	    $nav.removeClass('active on').addClass('off');
	    jQuery(this).addClass('active').removeClass('off');
	    $nCurrentActive = jQuery(this).attr('id').substr(4);
     });

     jQuery('#nav-logo').bind('click', function() {
	     $nav.removeClass('active on').addClass('off');
	     jQuery('#nav-1').addClass('active').removeClass('off');
     });

     function onMenu($nCurPos) {
	     if (jQuery('#nav-'+$nCurPos).hasClass('off') && (!jQuery('#nav-'+$nCurPos).hasClass('active'))) {
		     jQuery('#nav-'+$nCurPos).removeClass('off').addClass('on');
	     }
     }

     function onScrollMenu($nCurPos) {
	     if (jQuery('#nav-'+$nCurPos).hasClass('off')) {
		     jQuery('#nav-'+$nCurPos).removeClass('off').addClass('on');
	     }
     }

     function offActiveMenu($nCurPos) {
	     jQuery('#nav-'+$nCurPos).removeClass('active').addClass('off')
     }

     function offMenu($nCurPos) {
	     if (!jQuery('#nav-'+$nCurPos).hasClass('active')) {
		     jQuery('#nav-'+$nCurPos).removeClass('on').addClass('off');
	     }
     }

      // Nav setup @ window scroll
      jQuery(window).scroll(function() {
	      $inview = jQuery('section:in-viewport header').parent().attr('id');		
				$link = '';	
	      if (jQuery('a[href=#' + $inview + ']') !== null) { 				 
				  if(jQuery('a[href=#' + $inview + ']').parent().attr('id') != undefined) {
						$link = jQuery('a[href=#' + $inview + ']').parent().attr('id').substr(4);
					}		      
	      }

	      if ($link != $nCurrentActive && scrolling == 1) {
		      $nav.removeClass('active');
		      offMenu($nCurrentActive);
		      $nCurrentActive = $link;
		      jQuery('#nav-'+$nCurrentActive).addClass('active');
		      onScrollMenu($nCurrentActive);
	      }
      });

      // Window scroll setup
      jQuery.localScroll.hash({
	      target: '#content',
	      queue: true,
	      duration: 1500
      });

      jQuery('navigation').localScroll({
	      hash: true,
	      duration: 400,
	      easing: 'easeOutExpo',
	      onBefore: function() {scrolling = 0; return scrolling},
	      onAfter: function() {scrolling = 1; return scrolling}
      });			
		}	
}								