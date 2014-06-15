<?php
/**
 * @file views-view-unformatted.tpl.php
 * Default simple view template to display a list of rows.
 *
 * @ingroup views_templates
 */
?>
<?php if (!empty($title)): ?>
  <h3><?php print $title; ?></h3>
<?php endif; ?>
<?php $i = 0; foreach ($rows as $id => $row): ?>
  <figure class="two-column <?php print (($i++%2 == 0)?'':'last'); ?>">
    <?php print $row; ?>
  </figure>
<?php endforeach; ?>