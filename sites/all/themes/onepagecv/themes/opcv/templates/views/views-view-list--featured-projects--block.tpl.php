<?php
/**
 * @file views-view-list.tpl.php
 * Default simple view template to display a list of rows.
 *
 * - $title : The title of this group of rows.  May be empty.
 * - $options['type'] will either be ul or ol.
 * @ingroup views_templates
 */
?>
<?php $i = 0; print $wrapper_prefix; ?>
  <?php if (!empty($title)) : ?>
    <h3><?php print $title; ?></h3>
  <?php endif; ?>
  
  <div id="loader" class="loader"></div>
  <div id="ps_container" class="ps_container"> <span class="ribbon"></span>
  
  <div class="ps_image_wrapper"> 
    <img src="http://onepagecv/sites/default/files/styles/large/public/1_5.jpg" alt="" /> 
    <projecttitle>Project #1</projecttitle>
  </div>
	
  <div class="ps_next"></div>
  <div class="ps_prev"></div>
  
  <?php print $list_type_prefix; ?>
    <?php foreach ($rows as $id => $row): ?>
      <li class="<?php print $classes_array[$id]; ?>"><?php print $row; ?></li>
      <?php if (count($rows) - 1 == $i++) { ?>
        <li class="ps_preview"><div class="ps_preview_wrapper"></div><span></span></li>
      <?php } ?>    
    <?php endforeach; ?>
  <?php print $list_type_suffix; ?>
	
	</div>
<?php print $wrapper_suffix; ?>