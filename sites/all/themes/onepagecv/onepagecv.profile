<?php

/**
 * @file
 * The OnePageCV profile main installation file.
 */

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function onepagecv_form_install_configure_form_alter(&$form, $form_state) {
  $form['site_information']['site_name']['#default_value'] = st('One Page CV');
  $form['site_information']['site_slogan'] = array(
    '#type' => 'textfield',
    '#title' => st('Your Name'),
    '#default_value' => st('First Last'),
    '#description' => st('This field will be used as a website slogan. You\'ll be able to change it later.')
  );
  $form['#submit'][] = 'onepagecv_form_install_configure_form_submit';
}

/**
 * Implements form submit which configure Site Slogan
 */ 
function onepagecv_form_install_configure_form_submit(&$form, $form_state) {
  variable_set('site_slogan', $form_state['values']['site_slogan']);  
}

/**
 * Implements hook_install_tasks_alter().
 *
 * Here we change the function that is called for the last step of installation.
 * See below.
 *
 * @param array $tasks
 * @param array $install_state
 */
function onepagecv_install_tasks_alter(&$tasks, $install_state) {
  $tasks['install_finished']['function'] = 'install_onepagecv';
}

/**
 * Callback for the last install step.
 *
 * Above we did change the callback. Here we do first the same stuff the
 * default. As the system is now fully installed we can do anything we want.
 * Just like a "one time" module. See the comments in the source below.
 *
 * @param $install_state
 *  Current install state.
 *
 * @return
 *  String that is output to the page. Can be HTML.
 */
function install_onepagecv(&$install_state) {
  $base = install_finished($install_state);

  // This should be configurable thru settings wizard at line 1360
  onepagecv_form_install_content();  
  onepagecv_form_install_terms();
  onepagecv_form_install_views();
  onepagecv_form_install_blocks();
  onepagecv_form_install_image_styles();
  
  cache_clear_all();

  return $base;
}

function onepagecv_form_install_content() {
  // Create projects
  for ($i = 1; $i < 11; $i++) {  
    $project = onepagecv_create_node(
      'Project #' . $i, 
      'Project #' . $i . ' Full Description',
      'Project #' . $i . ' Short Description',
      'project',
      'project-' . $i
    );
    
    if ($i < 6) {
      $project->field_featured = array(
        LANGUAGE_NONE => array(
          0 => array(
            'value' => 1,
          )
        )
      );      
    }
  
    // Add a file   
    $filepath = drupal_realpath('profiles/onepagecv/themes/opcv/images/temp/' . $i . '.jpg');
    $file = (object) array(
      'uid' => 1,
      'uri' => $filepath,
      'filemime' => file_get_mimetype($filepath),
      'status' => 1,
    );

    // We save the file to the root of the files directory.
    $file = file_copy($file, 'public://');

    $project->field_image[LANGUAGE_NONE][0] = (array)$file;

    // Add a some terms   
    $project->field_tags[LANGUAGE_NONE][] = array(
      'vid' => 1,
      'tid' => 'autocreate',
      'name' => 'one page',
      'vocabulary_machine_name' => 'tags'
    );
    $project->field_tags[LANGUAGE_NONE][] = array(
      'vid' => 1,
      'tid' => 'autocreate',
      'name' => 'project ' . $i,
      'vocabulary_machine_name' => 'tags'
    );    
    
    node_save($project);
  }  

  $about = onepagecv_create_node(
    'About Me', 
    'This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual.',
    'This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content. This is just a place holder for people who need type to visualize what the actual.',
    'page',
    'about'
  );
  
  // Add a file   
  $filepath = drupal_realpath('profiles/onepagecv/themes/opcv/images/portrait.jpg');
  $file = (object) array(
    'uid' => 1,
    'uri' => $filepath,
    'filemime' => file_get_mimetype($filepath),
    'status' => 1,
  );

  // We save the file to the root of the files directory.
  $file = file_copy($file, 'public://');

  $about->field_image[LANGUAGE_NONE][0] = (array)$file;  
  
  node_save($about);
  
  $item = array(
    'link_title' => st('About'),
    'link_path'  => 'node/' . $about->nid,
    'menu_name'  => 'main-menu',
    'weight'     => 2,
  );
  menu_link_save($item);    
  
  // Create testimonials
  for ($i = 0; $i < 2; $i++) {
    $testimonial = onepagecv_create_node(
      'Testimonial #' . $i, 
      'This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.',
      'This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.',      
      'testimonial',
      'testimonial-' . $i
    );
       
    $testimonial->field_link = array(
      LANGUAGE_NONE => array(
        0 => array(
          'url' => 'http://drupal.org/user/432492',
          'title' => st('Testimonial'),
        )
      ),
    );              

    // Add a file   
    $filepath = drupal_realpath('profiles/onepagecv/themes/opcv/images/temp/userpic.jpg');
    $file = (object) array(
      'uid' => 1,
      'uri' => $filepath,
      'filemime' => file_get_mimetype($filepath),
      'status' => 1,
    );

    // We save the file to the root of the files directory.
    $file = file_copy($file, 'public://');

    $testimonial->field_image[LANGUAGE_NONE][0] = (array)$file;
    
    node_save($testimonial);        
  }
}

function onepagecv_form_install_terms() {
  // Create services terms  
  $terms = array(
    0 => (object) array('name' => st('Web Design'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
    1 => (object) array('name' => st('Graphic Design'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
    2 => (object) array('name' => st('Identity / Branding'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
  );
  
  onepagecv_create_terms($terms, 3);
  
  // Create categories terms
  $terms = array(
    0 => (object) array('name' => st('Design'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
    1 => (object) array('name' => st('HTML5 / CSS3'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
    2 => (object) array('name' => st('Drupal / CMS'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
    3 => (object) array('name' => st('jQuery'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
    4 => (object) array('name' => st('Seo'), 'description' => st('This is just a place holder for people who need type to visualize what the actual copy might look like if it were real content.')),
  );
  
  onepagecv_create_terms($terms, 2);      
}

function onepagecv_form_install_blocks() {
  /**
   * Create a custom block.
   * @see http://api.drupal.org/api/drupal/modules--block--block.admin.inc/function/block_add_block_form_submit
   */  
  $delta = db_insert('block_custom')
    ->fields(array(
      'body' => '<header class="divider intro-text"><h2>I Make Beautiful Websites </h2><div class="contact-me"><a class="contact button" href="#contact">Contact Me</a></div></header>',
      'info' => st('Intro Text'),
      'format' => 'full_html',
    ))
    ->execute();
  onepagecv_create_block('<none>', 'block', 'opcv', 10, $delta, 'featured_projects');
     
  $delta = db_insert('block_custom')
    ->fields(array(
      'body' => '<div class="social_wrapper">
    <h3>Where to find me?</h3>
      <ul class="social">
        <li class="dribble"><a href="#">Dribble</a></li>
        <li class="twitter"><a href="#">Twitter</a></li>
        <li class="lastfm"><a href="#">Last FM</a></li>
        <li class="facebook"><a href="#">Facebook</a></li>
        <li class="location"><a href="#">Location</a></li>
        <li class="forrst"><a href="#">Forrst</a></li>
      </ul>
    </div>',
      'info' => st('Social Links'),
      // Input format.
      'format' => 'full_html',
    ))
    ->execute();
  onepagecv_create_block('<none>', 'block', 'opcv', -9, $delta, 'contact');  
  
  onepagecv_create_block('<none>', 'views', 'opcv', 0, 'featured_projects-block', 'featured_projects');  
  onepagecv_create_block('<none>', 'views', 'opcv', 11, 'recent_projects-block', 'featured_projects');
  onepagecv_create_block('<none>', 'views', 'opcv', 12, 'my_services-block', 'featured_projects');
  onepagecv_create_block('Testimonials', 'views', 'opcv', 13, 'testimonials-block', 'featured_projects');
  onepagecv_create_block('My Work', 'views', 'opcv', 13, 'my_work-block', 'work');
  onepagecv_create_block('About Me', 'nodeblock', 'opcv', 14, '11', 'about');
  onepagecv_create_block('My Skills', 'views', 'opcv', -11, 'my_skills-my_skills', 'about');  
}

function onepagecv_form_install_image_styles() {
  // Change 'large' styles sizes
  onepagecv_create_imagestyle('large', 636, 325, TRUE);
  
  // Change 'large' styles sizes
  onepagecv_create_imagestyle('thumbnail', 75, 75, TRUE);
  
  // Create 'recent_project' style
  onepagecv_create_imagestyle('recent_project', 292, 126, FALSE);  
  
  // Create 'userpic' style
  onepagecv_create_imagestyle('userpic', 67, 67, FALSE);  
  
  // Create 'my_work' style
  onepagecv_create_imagestyle('my_work', 192, 152, FALSE);  
}

function onepagecv_form_install_views() {
  // Featured projects view
  $view = new view;
  $view->name = 'featured_projects';
  $view->description = '';
  $view->tag = 'default';
  $view->base_table = 'node';
  $view->human_name = 'featured_projects';
  $view->core = 7;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */

  /* Display: Master */
  $handler = $view->new_display('default', 'Master', 'default');
  $handler->display->display_options['access']['type'] = 'perm';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['query']['options']['query_comment'] = FALSE;
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'full';
  $handler->display->display_options['pager']['options']['items_per_page'] = '5';
  $handler->display->display_options['style_plugin'] = 'list';
  $handler->display->display_options['style_options']['class'] = 'ps_nav';
  $handler->display->display_options['style_options']['wrapper_class'] = '';
  $handler->display->display_options['row_plugin'] = 'fields';
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image']['id'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['label'] = '';
  $handler->display->display_options['fields']['field_image']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_image']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image']['element_default_classes'] = 1;
  $handler->display->display_options['fields']['field_image']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image']['type'] = 'image_url';
  $handler->display->display_options['fields']['field_image']['settings'] = array( 
    'image_style' => '',
    'image_link' => 'file',
  );
  $handler->display->display_options['fields']['field_image']['field_api_classes'] = 0;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image_1']['id'] = 'field_image_1';
  $handler->display->display_options['fields']['field_image_1']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image_1']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image_1']['label'] = '';
  $handler->display->display_options['fields']['field_image_1']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_image_1']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['strip_tags'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image_1']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image_1']['element_default_classes'] = 1;
  $handler->display->display_options['fields']['field_image_1']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image_1']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image_1']['type'] = 'image_url';
  $handler->display->display_options['fields']['field_image_1']['settings'] = array(
    'image_style' => 'thumbnail',
    'image_link' => 'file',
  );
  $handler->display->display_options['fields']['field_image_1']['field_api_classes'] = 0;
  /* Field: Content: Title */
  $handler->display->display_options['fields']['title']['id'] = 'title';
  $handler->display->display_options['fields']['title']['table'] = 'node';
  $handler->display->display_options['fields']['title']['field'] = 'title';
  $handler->display->display_options['fields']['title']['label'] = '';
  $handler->display->display_options['fields']['title']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['title']['alter']['make_link'] = 1;
  $handler->display->display_options['fields']['title']['alter']['path'] = '[field_image]';
  $handler->display->display_options['fields']['title']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['title']['alter']['external'] = 0;
  $handler->display->display_options['fields']['title']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['title']['alter']['rel'] = '[field_image_1]';
  $handler->display->display_options['fields']['title']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['title']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['title']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['title']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['title']['alter']['html'] = 0;
  $handler->display->display_options['fields']['title']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['title']['element_default_classes'] = 1;
  $handler->display->display_options['fields']['title']['hide_empty'] = 0;
  $handler->display->display_options['fields']['title']['empty_zero'] = 0;
  $handler->display->display_options['fields']['title']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['title']['link_to_node'] = 0;
  /* Sort criterion: Content: Post date */
  $handler->display->display_options['sorts']['created']['id'] = 'created';
  $handler->display->display_options['sorts']['created']['table'] = 'node';
  $handler->display->display_options['sorts']['created']['field'] = 'created';
  $handler->display->display_options['sorts']['created']['order'] = 'DESC';
  /* Filter criterion: Content: Published */
  $handler->display->display_options['filters']['status']['id'] = 'status';
  $handler->display->display_options['filters']['status']['table'] = 'node';
  $handler->display->display_options['filters']['status']['field'] = 'status';
  $handler->display->display_options['filters']['status']['value'] = 1;
  $handler->display->display_options['filters']['status']['group'] = 0;
  $handler->display->display_options['filters']['status']['expose']['operator'] = FALSE;
  /* Filter criterion: Content: Type */
  $handler->display->display_options['filters']['type']['id'] = 'type';
  $handler->display->display_options['filters']['type']['table'] = 'node';
  $handler->display->display_options['filters']['type']['field'] = 'type';
  $handler->display->display_options['filters']['type']['value'] = array(
    'project' => 'project',
  );  
  /* Filter criterion: Content: Featured (field_featured) */
  $handler->display->display_options['filters']['field_featured_value']['id'] = 'field_featured_value';
  $handler->display->display_options['filters']['field_featured_value']['table'] = 'field_data_field_featured';
  $handler->display->display_options['filters']['field_featured_value']['field'] = 'field_featured_value';
  $handler->display->display_options['filters']['field_featured_value']['value'] = array(
    1 => '1',
  );

  /* Display: Featured Projects */
  $handler = $view->new_display('block', 'Featured Projects', 'block');
  $handler->display->display_options['defaults']['fields'] = FALSE;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image']['id'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['label'] = '';
  $handler->display->display_options['fields']['field_image']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_image']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image']['element_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image']['element_wrapper_type'] = 'div';
  $handler->display->display_options['fields']['field_image']['element_wrapper_class'] = 'preview';
  $handler->display->display_options['fields']['field_image']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image']['type'] = 'image_url';
  $handler->display->display_options['fields']['field_image']['settings'] = array(
    'image_style' => 'large',
    'image_link' => 'file',
  );
  $handler->display->display_options['fields']['field_image']['field_api_classes'] = 0;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image_1']['id'] = 'field_image_1';
  $handler->display->display_options['fields']['field_image_1']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image_1']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image_1']['label'] = '';
  $handler->display->display_options['fields']['field_image_1']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_image_1']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['strip_tags'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image_1']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image_1']['element_default_classes'] = 1;
  $handler->display->display_options['fields']['field_image_1']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image_1']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image_1']['type'] = 'image_url';
  $handler->display->display_options['fields']['field_image_1']['settings'] = array(
    'image_style' => 'thumbnail',
    'image_link' => 'file',
  );
  $handler->display->display_options['fields']['field_image_1']['field_api_classes'] = 0;
  /* Field: Content: Title */
  $handler->display->display_options['fields']['title']['id'] = 'title';
  $handler->display->display_options['fields']['title']['table'] = 'node';
  $handler->display->display_options['fields']['title']['field'] = 'title';
  $handler->display->display_options['fields']['title']['label'] = '';
  $handler->display->display_options['fields']['title']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['title']['alter']['make_link'] = 1;
  $handler->display->display_options['fields']['title']['alter']['path'] = '[field_image]';
  $handler->display->display_options['fields']['title']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['title']['alter']['external'] = 0;
  $handler->display->display_options['fields']['title']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['title']['alter']['rel'] = '[field_image_1]';
  $handler->display->display_options['fields']['title']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['title']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['title']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['title']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['title']['alter']['html'] = 0;
  $handler->display->display_options['fields']['title']['element_type'] = '0';
  $handler->display->display_options['fields']['title']['element_label_type'] = '0';
  $handler->display->display_options['fields']['title']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['title']['element_wrapper_type'] = 'div';
  $handler->display->display_options['fields']['title']['element_wrapper_class'] = 'title';
  $handler->display->display_options['fields']['title']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['title']['hide_empty'] = 0;
  $handler->display->display_options['fields']['title']['empty_zero'] = 0;
  $handler->display->display_options['fields']['title']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['title']['link_to_node'] = 0;
  $handler->display->display_options['block_description'] = 'Featured Projects';

  views_save_view($view);  
  
  $view = new view;
  $view->name = 'recent_projects';
  $view->description = '';
  $view->tag = 'default';
  $view->base_table = 'node';
  $view->human_name = 'recent_projects';
  $view->core = 7;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
  /* Display: Master */
  $handler = $view->new_display('default', 'Master', 'default');
  $handler->display->display_options['title'] = 'My Recent Work';
  $handler->display->display_options['css_class'] = 'recent-work columns';
  $handler->display->display_options['access']['type'] = 'perm';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['query']['options']['query_comment'] = FALSE;
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'some';
  $handler->display->display_options['pager']['options']['items_per_page'] = '4';
  $handler->display->display_options['pager']['options']['offset'] = '0';
  $handler->display->display_options['style_plugin'] = 'default';
  $handler->display->display_options['style_options']['row_class'] = 'two-column';
  $handler->display->display_options['row_plugin'] = 'fields';
  $handler->display->display_options['row_options']['hide_empty'] = 0;
  $handler->display->display_options['row_options']['default_field_elements'] = 0;
  /* Field: Content: Path */
  $handler->display->display_options['fields']['path']['id'] = 'path';
  $handler->display->display_options['fields']['path']['table'] = 'node';
  $handler->display->display_options['fields']['path']['field'] = 'path';
  $handler->display->display_options['fields']['path']['label'] = '';
  $handler->display->display_options['fields']['path']['exclude'] = TRUE;
  $handler->display->display_options['fields']['path']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['path']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['path']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['path']['alter']['external'] = 0;
  $handler->display->display_options['fields']['path']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['path']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['path']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['path']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['path']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['path']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['path']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['path']['alter']['html'] = 0;
  $handler->display->display_options['fields']['path']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['path']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['path']['hide_empty'] = 0;
  $handler->display->display_options['fields']['path']['empty_zero'] = 0;
  $handler->display->display_options['fields']['path']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['path']['absolute'] = 1;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image']['id'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['label'] = '';
  $handler->display->display_options['fields']['field_image']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['text'] = '<a href="/" rel="recent_work" class="zoom">[field_image]</a>';
  $handler->display->display_options['fields']['field_image']['alter']['make_link'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['path'] = '[path]';
  $handler->display->display_options['fields']['field_image']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['alt'] = '[field_image-alt]';
  $handler->display->display_options['fields']['field_image']['alter']['rel'] = 'recent_work';
  $handler->display->display_options['fields']['field_image']['alter']['link_class'] = 'zoom';
  $handler->display->display_options['fields']['field_image']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image']['element_wrapper_type'] = 'div';
  $handler->display->display_options['fields']['field_image']['element_wrapper_class'] = 'image';
  $handler->display->display_options['fields']['field_image']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image']['settings'] = array(
    'image_style' => 'recent_project',
    'image_link' => '',
  );
  $handler->display->display_options['fields']['field_image']['field_api_classes'] = 0;
  /* Sort criterion: Content: Post date */
  $handler->display->display_options['sorts']['created']['id'] = 'created';
  $handler->display->display_options['sorts']['created']['table'] = 'node';
  $handler->display->display_options['sorts']['created']['field'] = 'created';
  $handler->display->display_options['sorts']['created']['order'] = 'DESC';
  /* Filter criterion: Content: Published */
  $handler->display->display_options['filters']['status']['id'] = 'status';
  $handler->display->display_options['filters']['status']['table'] = 'node';
  $handler->display->display_options['filters']['status']['field'] = 'status';
  $handler->display->display_options['filters']['status']['value'] = 1;
  $handler->display->display_options['filters']['status']['group'] = 0;
  $handler->display->display_options['filters']['status']['expose']['operator'] = FALSE;
  /* Filter criterion: Content: Type */
  $handler->display->display_options['filters']['type']['id'] = 'type';
  $handler->display->display_options['filters']['type']['table'] = 'node';
  $handler->display->display_options['filters']['type']['field'] = 'type';
  $handler->display->display_options['filters']['type']['value'] = array(
    'project' => 'project',
  );
  /* Filter criterion: Content: Featured (field_featured) */
  $handler->display->display_options['filters']['field_featured_value']['id'] = 'field_featured_value';
  $handler->display->display_options['filters']['field_featured_value']['table'] = 'field_data_field_featured';
  $handler->display->display_options['filters']['field_featured_value']['field'] = 'field_featured_value';
  $handler->display->display_options['filters']['field_featured_value']['operator'] = 'empty';
  $handler->display->display_options['filters']['field_featured_value']['value'] = array(
    1 => '1',
  );
  
  /* Display: My Recent Work */
  $handler = $view->new_display('block', 'My Recent Work', 'block');
  $handler->display->display_options['block_description'] = 'My Recent Work';
  
  views_save_view($view);  
  
  $view = new view;
  $view->name = 'my_services';
  $view->description = '';
  $view->tag = 'default';
  $view->base_table = 'taxonomy_term_data';
  $view->human_name = 'my_services';
  $view->core = 7;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
  /* Display: Master */
  $handler = $view->new_display('default', 'Master', 'default');
  $handler->display->display_options['title'] = 'My Services';
  $handler->display->display_options['css_class'] = 'my-services columns';
  $handler->display->display_options['access']['type'] = 'perm';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['query']['options']['query_comment'] = FALSE;
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'full';
  $handler->display->display_options['pager']['options']['items_per_page'] = '3';
  $handler->display->display_options['style_plugin'] = 'default';
  $handler->display->display_options['row_plugin'] = 'fields';
  /* Field: Taxonomy term: Name */
  $handler->display->display_options['fields']['name']['id'] = 'name';
  $handler->display->display_options['fields']['name']['table'] = 'taxonomy_term_data';
  $handler->display->display_options['fields']['name']['field'] = 'name';
  $handler->display->display_options['fields']['name']['label'] = '';
  $handler->display->display_options['fields']['name']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['name']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['name']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['name']['alter']['external'] = 0;
  $handler->display->display_options['fields']['name']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['name']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['name']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['name']['alter']['word_boundary'] = 0;
  $handler->display->display_options['fields']['name']['alter']['ellipsis'] = 0;
  $handler->display->display_options['fields']['name']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['name']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['name']['alter']['html'] = 0;
  $handler->display->display_options['fields']['name']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['name']['element_wrapper_type'] = 'h4';
  $handler->display->display_options['fields']['name']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['name']['hide_empty'] = 0;
  $handler->display->display_options['fields']['name']['empty_zero'] = 0;
  $handler->display->display_options['fields']['name']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['name']['link_to_taxonomy'] = 0;
  /* Field: Taxonomy term: Term description */
  $handler->display->display_options['fields']['description']['id'] = 'description';
  $handler->display->display_options['fields']['description']['table'] = 'taxonomy_term_data';
  $handler->display->display_options['fields']['description']['field'] = 'description';
  $handler->display->display_options['fields']['description']['label'] = '';
  $handler->display->display_options['fields']['description']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['description']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['description']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['description']['alter']['external'] = 0;
  $handler->display->display_options['fields']['description']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['description']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['description']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['description']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['description']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['description']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['description']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['description']['alter']['html'] = 0;
  $handler->display->display_options['fields']['description']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['description']['element_wrapper_type'] = 'p';
  $handler->display->display_options['fields']['description']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['description']['hide_empty'] = 0;
  $handler->display->display_options['fields']['description']['empty_zero'] = 0;
  $handler->display->display_options['fields']['description']['hide_alter_empty'] = 0;
  /* Sort criterion: Taxonomy term: Weight */
  $handler->display->display_options['sorts']['weight']['id'] = 'weight';
  $handler->display->display_options['sorts']['weight']['table'] = 'taxonomy_term_data';
  $handler->display->display_options['sorts']['weight']['field'] = 'weight';
  /* Filter criterion: Taxonomy vocabulary: Machine name */
  $handler->display->display_options['filters']['machine_name']['id'] = 'machine_name';
  $handler->display->display_options['filters']['machine_name']['table'] = 'taxonomy_vocabulary';
  $handler->display->display_options['filters']['machine_name']['field'] = 'machine_name';
  $handler->display->display_options['filters']['machine_name']['value'] = array(
    'services' => 'services',
  );
  
  /* Display: My Services */
  $handler = $view->new_display('block', 'My Services', 'block');
  $handler->display->display_options['block_description'] = 'My Services';
  
  views_save_view($view);
  
  $view = new view;
  $view->name = 'testimonials';
  $view->description = '';
  $view->tag = 'default';
  $view->base_table = 'node';
  $view->human_name = 'testimonials';
  $view->core = 7;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
  /* Display: Master */
  $handler = $view->new_display('default', 'Master', 'default');
  $handler->display->display_options['title'] = 'Testimonials';
  $handler->display->display_options['css_class'] = 'one-column columns testimony';
  $handler->display->display_options['access']['type'] = 'perm';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['query']['options']['query_comment'] = FALSE;
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'some';
  $handler->display->display_options['pager']['options']['items_per_page'] = '2';
  $handler->display->display_options['pager']['options']['offset'] = '0';
  $handler->display->display_options['style_plugin'] = 'default';
  $handler->display->display_options['row_plugin'] = 'fields';
  $handler->display->display_options['row_options']['hide_empty'] = 0;
  $handler->display->display_options['row_options']['default_field_elements'] = 0;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image']['id'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['label'] = '';
  $handler->display->display_options['fields']['field_image']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image']['element_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image']['settings'] = array(
    'image_style' => 'userpic',
    'image_link' => '',
  );
  $handler->display->display_options['fields']['field_image']['field_api_classes'] = 0;
  /* Field: Content: Link */
  $handler->display->display_options['fields']['field_link']['id'] = 'field_link';
  $handler->display->display_options['fields']['field_link']['table'] = 'field_data_field_link';
  $handler->display->display_options['fields']['field_link']['field'] = 'field_link';
  $handler->display->display_options['fields']['field_link']['label'] = '';
  $handler->display->display_options['fields']['field_link']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_link']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['field_link']['alter']['text'] = '<cite>— [field_link]</cite>';
  $handler->display->display_options['fields']['field_link']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_link']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_link']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_link']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_link']['element_type'] = '0';
  $handler->display->display_options['fields']['field_link']['element_label_type'] = '0';
  $handler->display->display_options['fields']['field_link']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_link']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['field_link']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_link']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_link']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_link']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_link']['click_sort_column'] = 'url';
  $handler->display->display_options['fields']['field_link']['field_api_classes'] = 0;
  /* Field: Content: Body */
  $handler->display->display_options['fields']['body']['id'] = 'body';
  $handler->display->display_options['fields']['body']['table'] = 'field_data_body';
  $handler->display->display_options['fields']['body']['field'] = 'body';
  $handler->display->display_options['fields']['body']['label'] = '';
  $handler->display->display_options['fields']['body']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['body']['alter']['text'] = '[body][field_link]';
  $handler->display->display_options['fields']['body']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['body']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['body']['alter']['external'] = 0;
  $handler->display->display_options['fields']['body']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['body']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['body']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['body']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['body']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['body']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['body']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['body']['alter']['html'] = 0;
  $handler->display->display_options['fields']['body']['element_type'] = '0';
  $handler->display->display_options['fields']['body']['element_label_type'] = '0';
  $handler->display->display_options['fields']['body']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['body']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['body']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['body']['hide_empty'] = 0;
  $handler->display->display_options['fields']['body']['empty_zero'] = 0;
  $handler->display->display_options['fields']['body']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['body']['field_api_classes'] = 0;
  /* Sort criterion: Content: Post date */
  $handler->display->display_options['sorts']['created']['id'] = 'created';
  $handler->display->display_options['sorts']['created']['table'] = 'node';
  $handler->display->display_options['sorts']['created']['field'] = 'created';
  $handler->display->display_options['sorts']['created']['order'] = 'DESC';
  /* Filter criterion: Content: Published */
  $handler->display->display_options['filters']['status']['id'] = 'status';
  $handler->display->display_options['filters']['status']['table'] = 'node';
  $handler->display->display_options['filters']['status']['field'] = 'status';
  $handler->display->display_options['filters']['status']['value'] = 1;
  $handler->display->display_options['filters']['status']['group'] = 0;
  $handler->display->display_options['filters']['status']['expose']['operator'] = FALSE;
  /* Filter criterion: Content: Type */
  $handler->display->display_options['filters']['type']['id'] = 'type';
  $handler->display->display_options['filters']['type']['table'] = 'node';
  $handler->display->display_options['filters']['type']['field'] = 'type';
  $handler->display->display_options['filters']['type']['value'] = array(
    'testimonial' => 'testimonial',
  );
  
  /* Display: Testimonials */
  $handler = $view->new_display('block', 'Testimonials', 'block');
  $handler->display->display_options['block_description'] = 'Testimonials';
  
  views_save_view($view);
  
  $view = new view;
  $view->name = 'my_work';
  $view->description = '';
  $view->tag = 'default';
  $view->base_table = 'node';
  $view->human_name = 'my_work';
  $view->core = 7;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
  /* Display: Master */
  $handler = $view->new_display('default', 'Master', 'default');
  $handler->display->display_options['title'] = 'My Work';
  $handler->display->display_options['use_ajax'] = TRUE;
  $handler->display->display_options['access']['type'] = 'perm';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['query']['options']['query_comment'] = FALSE;
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'full';
  $handler->display->display_options['pager']['options']['items_per_page'] = '9';
  $handler->display->display_options['style_plugin'] = 'list';
  $handler->display->display_options['style_options']['class'] = 'projects list';
  $handler->display->display_options['style_options']['wrapper_class'] = '';
  $handler->display->display_options['row_plugin'] = 'fields';
  $handler->display->display_options['row_options']['hide_empty'] = 0;
  $handler->display->display_options['row_options']['default_field_elements'] = 0;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image_1']['id'] = 'field_image_1';
  $handler->display->display_options['fields']['field_image_1']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image_1']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image_1']['label'] = '';
  $handler->display->display_options['fields']['field_image_1']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_image_1']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image_1']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image_1']['element_default_classes'] = 1;
  $handler->display->display_options['fields']['field_image_1']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image_1']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image_1']['type'] = 'image_url';
  $handler->display->display_options['fields']['field_image_1']['settings'] = array(
    'image_style' => '',
    'image_link' => '',
  );
  $handler->display->display_options['fields']['field_image_1']['field_api_classes'] = 0;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image']['id'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['label'] = '';
  $handler->display->display_options['fields']['field_image']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['make_link'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['path'] = '[field_image_1]';
  $handler->display->display_options['fields']['field_image']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['rel'] = 'work';
  $handler->display->display_options['fields']['field_image']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image']['element_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image']['settings'] = array(
    'image_style' => 'my_work',
    'image_link' => '',
  );
  $handler->display->display_options['fields']['field_image']['field_api_classes'] = 0;
  /* Field: Content: Path */
  $handler->display->display_options['fields']['path']['id'] = 'path';
  $handler->display->display_options['fields']['path']['table'] = 'node';
  $handler->display->display_options['fields']['path']['field'] = 'path';
  $handler->display->display_options['fields']['path']['label'] = '';
  $handler->display->display_options['fields']['path']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['path']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['path']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['path']['alter']['external'] = 0;
  $handler->display->display_options['fields']['path']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['path']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['path']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['path']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['path']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['path']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['path']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['path']['alter']['html'] = 0;
  $handler->display->display_options['fields']['path']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['path']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['path']['hide_empty'] = 0;
  $handler->display->display_options['fields']['path']['empty_zero'] = 0;
  $handler->display->display_options['fields']['path']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['path']['absolute'] = 1;
  /* Field: Content: Title */
  $handler->display->display_options['fields']['title']['id'] = 'title';
  $handler->display->display_options['fields']['title']['table'] = 'node';
  $handler->display->display_options['fields']['title']['field'] = 'title';
  $handler->display->display_options['fields']['title']['label'] = '';
  $handler->display->display_options['fields']['title']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['title']['alter']['text'] = '<a href="[Path]">[Title] <span>&nbsp;→</span></a>';
  $handler->display->display_options['fields']['title']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['title']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['title']['alter']['external'] = 0;
  $handler->display->display_options['fields']['title']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['title']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['title']['alter']['word_boundary'] = 0;
  $handler->display->display_options['fields']['title']['alter']['ellipsis'] = 0;
  $handler->display->display_options['fields']['title']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['title']['alter']['html'] = 0;
  $handler->display->display_options['fields']['title']['element_type'] = '0';
  $handler->display->display_options['fields']['title']['element_label_type'] = '0';
  $handler->display->display_options['fields']['title']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['title']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['title']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['title']['hide_empty'] = 0;
  $handler->display->display_options['fields']['title']['empty_zero'] = 0;
  $handler->display->display_options['fields']['title']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['title']['link_to_node'] = 0;
  /* Sort criterion: Content: Post date */
  $handler->display->display_options['sorts']['created']['id'] = 'created';
  $handler->display->display_options['sorts']['created']['table'] = 'node';
  $handler->display->display_options['sorts']['created']['field'] = 'created';
  $handler->display->display_options['sorts']['created']['order'] = 'DESC';
  /* Filter criterion: Content: Published */
  $handler->display->display_options['filters']['status']['id'] = 'status';
  $handler->display->display_options['filters']['status']['table'] = 'node';
  $handler->display->display_options['filters']['status']['field'] = 'status';
  $handler->display->display_options['filters']['status']['value'] = 1;
  $handler->display->display_options['filters']['status']['group'] = 0;
  $handler->display->display_options['filters']['status']['expose']['operator'] = FALSE;
  /* Filter criterion: Content: Type */
  $handler->display->display_options['filters']['type']['id'] = 'type';
  $handler->display->display_options['filters']['type']['table'] = 'node';
  $handler->display->display_options['filters']['type']['field'] = 'type';
  $handler->display->display_options['filters']['type']['value'] = array(
    'project' => 'project',
  );
  
  /* Display: My Work */
  $handler = $view->new_display('block', 'My Work', 'block');
  $handler->display->display_options['defaults']['fields'] = FALSE;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image_1']['id'] = 'field_image_1';
  $handler->display->display_options['fields']['field_image_1']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image_1']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image_1']['label'] = '';
  $handler->display->display_options['fields']['field_image_1']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_image_1']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image_1']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image_1']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image_1']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image_1']['element_default_classes'] = 1;
  $handler->display->display_options['fields']['field_image_1']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image_1']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image_1']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image_1']['type'] = 'image_url';
  $handler->display->display_options['fields']['field_image_1']['settings'] = array(
    'image_style' => '',
    'image_link' => '',
  );
  $handler->display->display_options['fields']['field_image_1']['field_api_classes'] = 0;
  /* Field: Content: Image */
  $handler->display->display_options['fields']['field_image']['id'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['table'] = 'field_data_field_image';
  $handler->display->display_options['fields']['field_image']['field'] = 'field_image';
  $handler->display->display_options['fields']['field_image']['label'] = '';
  $handler->display->display_options['fields']['field_image']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['make_link'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['path'] = '[field_image_1]';
  $handler->display->display_options['fields']['field_image']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['rel'] = 'work';
  $handler->display->display_options['fields']['field_image']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_image']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_image']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_image']['element_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_image']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['field_image']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_image']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_image']['click_sort_column'] = 'fid';
  $handler->display->display_options['fields']['field_image']['settings'] = array(
    'image_style' => 'my_work',
    'image_link' => '',
  );
  $handler->display->display_options['fields']['field_image']['field_api_classes'] = 0;
  /* Field: Content: Path */
  $handler->display->display_options['fields']['path']['id'] = 'path';
  $handler->display->display_options['fields']['path']['table'] = 'node';
  $handler->display->display_options['fields']['path']['field'] = 'path';
  $handler->display->display_options['fields']['path']['label'] = '';
  $handler->display->display_options['fields']['path']['exclude'] = TRUE;
  $handler->display->display_options['fields']['path']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['path']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['path']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['path']['alter']['external'] = 0;
  $handler->display->display_options['fields']['path']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['path']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['path']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['path']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['path']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['path']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['path']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['path']['alter']['html'] = 0;
  $handler->display->display_options['fields']['path']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['path']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['path']['hide_empty'] = 0;
  $handler->display->display_options['fields']['path']['empty_zero'] = 0;
  $handler->display->display_options['fields']['path']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['path']['absolute'] = 1;
  /* Field: Content: Title */
  $handler->display->display_options['fields']['title']['id'] = 'title';
  $handler->display->display_options['fields']['title']['table'] = 'node';
  $handler->display->display_options['fields']['title']['field'] = 'title';
  $handler->display->display_options['fields']['title']['label'] = '';
  $handler->display->display_options['fields']['title']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['title']['alter']['text'] = '<a href="[path]">[title] <span>&nbsp;→</span></a>';
  $handler->display->display_options['fields']['title']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['title']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['title']['alter']['external'] = 0;
  $handler->display->display_options['fields']['title']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['title']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['title']['alter']['word_boundary'] = 0;
  $handler->display->display_options['fields']['title']['alter']['ellipsis'] = 0;
  $handler->display->display_options['fields']['title']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['title']['alter']['html'] = 0;
  $handler->display->display_options['fields']['title']['element_type'] = '0';
  $handler->display->display_options['fields']['title']['element_label_type'] = '0';
  $handler->display->display_options['fields']['title']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['title']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['title']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['title']['hide_empty'] = 0;
  $handler->display->display_options['fields']['title']['empty_zero'] = 0;
  $handler->display->display_options['fields']['title']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['title']['link_to_node'] = 0;
  $handler->display->display_options['block_description'] = 'My Work';
  
  /* Display: My Work */
  $handler = $view->new_display('page', 'My Work', 'my_work_page');
  $handler->display->display_options['path'] = 'work';
  $handler->display->display_options['menu']['type'] = 'normal';
  $handler->display->display_options['menu']['title'] = 'Work';
  $handler->display->display_options['menu']['weight'] = '1';
  $handler->display->display_options['menu']['name'] = 'main-menu';
  
  views_save_view($view);
  
  $view = new view;
  $view->name = 'my_skills';
  $view->description = '';
  $view->tag = 'default';
  $view->base_table = 'taxonomy_term_data';
  $view->human_name = 'my_skills';
  $view->core = 7;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
  /* Display: Master */
  $handler = $view->new_display('default', 'Master', 'default');
  $handler->display->display_options['title'] = 'My Skills';
  $handler->display->display_options['access']['type'] = 'perm';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['query']['options']['query_comment'] = FALSE;
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'none';
  $handler->display->display_options['pager']['options']['offset'] = '0';
  $handler->display->display_options['style_plugin'] = 'list';
  $handler->display->display_options['style_options']['class'] = 'skills';
  $handler->display->display_options['style_options']['wrapper_class'] = '';
  $handler->display->display_options['row_plugin'] = 'fields';
  $handler->display->display_options['row_options']['hide_empty'] = 0;
  $handler->display->display_options['row_options']['default_field_elements'] = 0;
  /* Field: Taxonomy term: Percent */
  $handler->display->display_options['fields']['field_percent']['id'] = 'field_percent';
  $handler->display->display_options['fields']['field_percent']['table'] = 'field_data_field_percent';
  $handler->display->display_options['fields']['field_percent']['field'] = 'field_percent';
  $handler->display->display_options['fields']['field_percent']['label'] = '';
  $handler->display->display_options['fields']['field_percent']['exclude'] = TRUE;
  $handler->display->display_options['fields']['field_percent']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['field_percent']['alter']['text'] = '<span class="bar_[field_percent]"><span class="percent">[field_percent]%</span></span>';
  $handler->display->display_options['fields']['field_percent']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['external'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_percent']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_percent']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_percent']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_percent']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['field_percent']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['field_percent']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['field_percent']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_percent']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_percent']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['field_percent']['settings'] = array(
    'thousand_separator' => ' ',
    'prefix_suffix' => 0,
  );
  $handler->display->display_options['fields']['field_percent']['group_rows'] = 1;
  $handler->display->display_options['fields']['field_percent']['delta_offset'] = '0';
  $handler->display->display_options['fields']['field_percent']['delta_reversed'] = 0;
  $handler->display->display_options['fields']['field_percent']['field_api_classes'] = 0;
  /* Field: Taxonomy term: Name */
  $handler->display->display_options['fields']['name']['id'] = 'name';
  $handler->display->display_options['fields']['name']['table'] = 'taxonomy_term_data';
  $handler->display->display_options['fields']['name']['field'] = 'name';
  $handler->display->display_options['fields']['name']['label'] = '';
  $handler->display->display_options['fields']['name']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['name']['alter']['text'] = '[name] [field_percent]';
  $handler->display->display_options['fields']['name']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['name']['alter']['absolute'] = 0;
  $handler->display->display_options['fields']['name']['alter']['external'] = 0;
  $handler->display->display_options['fields']['name']['alter']['replace_spaces'] = 0;
  $handler->display->display_options['fields']['name']['alter']['trim_whitespace'] = 0;
  $handler->display->display_options['fields']['name']['alter']['nl2br'] = 0;
  $handler->display->display_options['fields']['name']['alter']['word_boundary'] = 0;
  $handler->display->display_options['fields']['name']['alter']['ellipsis'] = 0;
  $handler->display->display_options['fields']['name']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['name']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['name']['alter']['html'] = 0;
  $handler->display->display_options['fields']['name']['element_label_colon'] = FALSE;
  $handler->display->display_options['fields']['name']['element_wrapper_type'] = '0';
  $handler->display->display_options['fields']['name']['element_default_classes'] = 0;
  $handler->display->display_options['fields']['name']['hide_empty'] = 0;
  $handler->display->display_options['fields']['name']['empty_zero'] = 0;
  $handler->display->display_options['fields']['name']['hide_alter_empty'] = 0;
  $handler->display->display_options['fields']['name']['link_to_taxonomy'] = 0;
  /* Filter criterion: Taxonomy vocabulary: Machine name */
  $handler->display->display_options['filters']['machine_name']['id'] = 'machine_name';
  $handler->display->display_options['filters']['machine_name']['table'] = 'taxonomy_vocabulary';
  $handler->display->display_options['filters']['machine_name']['field'] = 'machine_name';
  $handler->display->display_options['filters']['machine_name']['value'] = array(
    'categories' => 'categories',
  );
  
  /* Display: My Skills */
  $handler = $view->new_display('block', 'My Skills', 'my_skills');
  $handler->display->display_options['block_description'] = 'My Skills';
  
  views_save_view($view);
}

function onepagecv_install_tasks() {
  return array(
    'onepagecv_pick_features_form' => array(
      'display_name' => st('Configure One Page CV'),
      'type' => 'form',
    ),
  );
}

function onepagecv_pick_features_form($form, &$form_state, &$install_state) {
  $features = array();
  drupal_set_title(st('Configure One Page CV'));
  $modules = $form_state['modules'] = system_rebuild_module_data();
  
  $form['welcome']['#markup'] = '<h1 class="title">Configure features</h1><p>' . st('Welcome to One Page CV!') . '</p>';
  $form['features'] = array(
    '#tree' => TRUE,
  );
  
  // TODO: wizard form here. Blocks, content, theme, etc should be configurable
  // so that anybody could install own One Page CV website

  $form['actions'] = array('#type' => 'actions');
  $form['actions']['submit'] = array(
    '#type' => 'submit',
    '#value' => st('Save and continue'),
    '#weight' => 15,
  );
  return $form;
}















function onepagecv_create_node($title, $body, $summary, $type, $alias) {
  $node = (object) array(      
    'title' => $title,      
    'body' => array(
      LANGUAGE_NONE => array(
        0 => array(
          'value' => $body,
          'summary' => $summary,
          'format' => 'filtered_html',
        )
      ),
    ),    
    'type' => $type,
    'language' => LANGUAGE_NONE,
    'uid' => 1,
  );  
    
  node_object_prepare($node);
  node_save((object) $node);

  // Create a path alias for the node.
  $path['alias'] = $alias;
  $path['source'] = 'node/' . $node->nid;
  $path['language'] = LANGUAGE_NONE;
  path_save($path);    
  
  return $node;
}

function onepagecv_create_terms($terms, $vid) {
  foreach ($terms as $term) {
    $term->vid = $vid;
    taxonomy_term_save($term);
  }    
}

function onepagecv_create_block($title, $module, $theme, $weight, $delta, $region) {
  // Insert main data to the block table.
  $query = db_insert('block')->fields(array('visibility', 'pages', 'custom', 'title', 'module', 'theme', 'status', 'weight', 'delta', 'cache', 'region'));
  $query->values(array(
    'visibility' => BLOCK_VISIBILITY_NOTLISTED,
    'pages' => '',
    'custom' => BLOCK_CUSTOM_FIXED,
    'title' => $title,
    'module' => $module,
    'theme' => $theme,
    'status' => 1,
    'weight' => $weight,
    'delta' => $delta,
    'cache' => DRUPAL_NO_CACHE,
    'region' => $region,
  ));
  $query->execute();     
}

function onepagecv_create_imagestyle($name, $width, $height, $update = FALSE) {  
  $original_name = 'large';
  if ($update) {
    $original_name = $name;
  }
  $style = image_style_load($original_name);   
  if (!$update) {
    unset($style['isid']);
    $style['name'] = $name;
  }
  $style = image_style_save($style);   
  
  $scaleCrop = image_effect_definition_load('image_scale_and_crop');
  $scaleCrop['data'] = array(
    'width' => $width,
    'height' => $height
  );
  $scaleCrop['isid'] = $style['isid'];  
  image_effect_save($scaleCrop);
}