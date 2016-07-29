<?php
/**
 * ownCloud - ggrwinti
 *
 * This file is licensed under the Affero General Public License version 3 or
 * later. See the COPYING file.
 *
 * @author Marc Wäckerlin <marc.waeckerlin@piratenpartei.ch>
 * @copyright Marc Wäckerlin 2016
 */

namespace OCA\GgrWinti\Controller;

use OCP\IRequest;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Controller;

use OCA\GgrWinti\Db\Geschaefte;
use OCA\GgrWinti\Db\GeschaefteMapper;

class PageController extends Controller {


  private $userId;
  private $mapper;

  public function __construct($AppName, IRequest $request, GeschaefteMapper $mapper, $UserId){
    parent::__construct($AppName, $request);
    $this->userId = $UserId;
    $this->mapper = $mapper;
  }

  /**
   * CAUTION: the @Stuff turns off security checks; for this page no admin is
   *          required and no CSRF check. If you don't know what CSRF is, read
   *          it up in the docs or you might create a security hole. This is
   *          basically the only required method to add this exemption, don't
   *          add it to any other method if you don't exactly know what it does
   *
   * @NoAdminRequired
   * @NoCSRFRequired
   */
  public function index() {
    $params = [
      'user' => $this->userId,
      'data' => $this->mapper->findAll(),
      'test' => 'Marc Wäckerlin'
    ];
    return new TemplateResponse('ggrwinti', 'main', $params);  // templates/main.php
  }

  /**
   * Simply method that posts back the payload of the request
   * @NoAdminRequired
   */
  public function doEcho($echo) {
    return new DataResponse(['echo' => $echo]);
  }


}
?>
