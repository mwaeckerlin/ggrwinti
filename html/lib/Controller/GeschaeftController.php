<?php
namespace OCA\GgrWinti\Controller;

use Exception;

use OCP\IRequest;
use OCP\AppFramework\Controller;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Controller;

use OCA\GgrWinti\Db\Geschaeft;
use OCA\GgrWinti\Db\GeschaeftMapper;

class GeschaeftController extends Controller {

  private $mapper;
  private $userId;
  
  public function __construct(string $AppName, IRequest $request, GeschaeftMapper $mapper, $UserId){
    parent::__construct($AppName, $request);
    $this->mapper = $mapper;
    $this->userId = $UserId;
  }

  /**
   * @NoAdminRequired
   */
  public function index() {
    // empty for now
  }
  
  /**
   * @NoAdminRequired
   *
   * @param int $id
   */
  public function show($id) {
    return new DataResponse($this->mapper->findAll($this->userId));
  }

  /**
   * @NoAdminRequired
   *
   * @param string $title
   * @param string $content
   */
  public function create($title, $content) {
    try {
      return new DataResponse($this->mapper->find($id, $this->userId));
    } catch(Exception $e) {
      return new DataResponse([], Http::STATUS_NOT_FOUND);
    }
  }

  /**
   * @NoAdminRequired
   *
   * @param int $id
   * @param string $title
   * @param string $content
   */
  public function update($id, $title, $content) {
    try {
      $geschaeft = $this->mapper->find($id, $this->userId);
    } catch(Exception $e) {
      return new DataResponse([], Http::STATUS_NOT_FOUND);
    }
    //$geschaeft->setTitle($title);
    //$geschaeft->setContent($content);
    return new DataResponse($this->mapper->update($geschaeft));
  }
  
  /**
   * @NoAdminRequired
   *
   * @param int $id
   */
  public function destroy($id) {
    try {
      $geschaeft = $this->mapper->find($id, $this->userId);
    } catch(Exception $e) {
      return new DataResponse([], Http::STATUS_NOT_FOUND);
    }
    $this->mapper->delete($geschaeft);
    return new DataResponse($geschaeft);
  }
  
}
?>
