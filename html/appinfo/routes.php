<?php
/**
 * Create your routes in here. The name is the lowercase name of the controller
 * without the controller part, the stuff after the hash is the method.
 * e.g. page#index -> OCA\GgrWinti\Controller\PageController->index()
 *
 * The controller class has to be registered in the application.php file since
 * it's instantiated in there
 */
return [
    'routes' => [
      ['name' => 'geschaeft#index', 'url' => '/', 'verb' => 'GET'],
      ['name' => 'geschaeft#index', 'url' => '/geschaefte', 'verb' => 'GET'],
      ['name' => 'geschaeft#update', 'url' => '/geschaefte/{id}', 'verb' => 'PUT'],
      ['name' => 'ggrsitzungen#index', 'url' => '/ggrsitzungen', 'verb' => 'GET'],
      ['name' => 'geschaeft#ggrsitzung', 'url' => '/ggrsitzung/{id}', 'verb' => 'GET'],
      ['name' => 'fraktionssitzungen#index', 'url' => '/fraktionssitzungen', 'verb' => 'GET'],
    ]
];
