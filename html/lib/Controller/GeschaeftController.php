<?php
namespace OCA\GgrWinti\Controller;

use Exception;

use OCP\IRequest;
use OCP\AppFramework\Controller;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\DataResponse;

use OCA\GgrWinti\Db\Geschaeft;
use OCA\GgrWinti\Db\GeschaeftMapper;

class GeschaeftController extends Controller {

  private $mapper;
  private $userId;
  
  public function __construct($AppName, IRequest $request, GeschaeftMapper $hereismapper, $UserId){
    parent::__construct($AppName, $request);
    $this->mapper = $hereismapper;
    $this->userId = $UserId;
  }

  /**
   * @NoAdminRequired
   */
  public function index() {
    return new DataResponse($this->mapper->findAll($this->userId));
  }
  
  /**
   * @NoAdminRequired
   *
   * @param int $id
   */
  public function show($id) {
    try {
      return new DataResponse($this->mapper->find($id, $this->userId));
    } catch(Exception $e) {
      return new DataResponse([], Http::STATUS_NOT_FOUND);
    }
  }

}
?>
