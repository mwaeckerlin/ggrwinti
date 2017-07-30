<?php

namespace OCA\GgrWinti\AppInfo;


use OCA\GgrWinti\Controller\GeschaeftController;
use OCA\GgrWinti\Controller\PageController;
use OCA\GgrWinti\Db\GeschaeftMapper;
use OCP\AppFramework\App;
use OCP\AppFramework\IAppContainer;

class Application extends App {

  /** @var string */
  private $appName;
  
  
  /**
   * @param array $params
   */
  public function __construct(array $params = array()) {
    parent::__construct('ggrwinti', $params);
    
    $container = $this->getContainer();
    $this->appName = $container->query('AppName');
    
    self::registerControllers($container);
    self::registerMappers($container);
    self::registerCores($container);
    
    // Translates
    //		$container->registerService(
    //			'L10N', function(IAppContainer $c) {
    //			return $c->query('ServerContainer')
    //					 ->getL10N($c->query('AppName'));
    //		}
    //		);
  }
  
  /**
   * Register Controllers
   *
   * @param $container
   */
  private static function registerControllers(IAppContainer &$container) {
    
    $container->registerService(
      'PageController', function(IAppContainer $c) {
	return new PageController(
	  $c->query('AppName'), $c->query('Request'), $c->query('UserId')
	);
      }
    );
    $container->registerService(
      'GeschaeftController', function(IAppContainer $c) {
	return new GeschaeftController(
	  $c->query('AppName'), $c->query('Request'), $c->query('GeschaeftMapper'),
	  $c->query('UserId')
	);
      }
    );
  }
  
  /**
   * Register Mappers
   *
   * @param $container
   */
  private static function registerMappers(IAppContainer &$container) {
    
    $container->registerService(
      'GeschaeftMapper', function(IAppContainer $c) {
	return new GeschaeftMapper(
	  $c->query('ServerContainer')
	    ->getDatabaseConnection()
	);
      }
    );
  }
  

  /**
   * Register Cores
   *
   * @param $container
   */
  private static function registerCores(IAppContainer &$container) {
    
    $container->registerService(
      'UserId', function(IAppContainer $c) {
	$user = $c->query('ServerContainer')
		  ->getUserSession()
		  ->getUser();
        
	/** @noinspection PhpUndefinedMethodInspection */
	return is_null($user) ? '' : $user->getUID();
      }
    );
  }
  
  
  /**
   * Register Navigation Tab
   */
  public function registerNavigation() {
    
    $this->getContainer()
	 ->getServer()
	 ->getNavigationManager()
	 ->add(
	   function() {
	     $urlGen = \OC::$server->getURLGenerator();
             
	     return [
	       'id'    => $this->appName,
	       'order' => 10,
	       'href'  => $urlGen->linkToRoute('ggrwinti.geschaeft.index'),
	       'icon'  => $urlGen->imagePath($this->appName, 'app.svg'),
	       'name'  => 'GGR-Winti'
	     ];
	   }
	 );
  }
  //
  //	public function registerSettingsAdmin() {
  //		\OCP\App::registerAdmin(
  //			$this->getContainer()
  //				 ->query('AppName'), 'lib/admin'
  //		);
  //	}
}

