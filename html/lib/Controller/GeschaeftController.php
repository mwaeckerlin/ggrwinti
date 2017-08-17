<?php

namespace OCA\GgrWinti\Controller;

use Exception;
use OCA\GgrWinti\Db\GeschaeftMapper;
use OCP\AppFramework\Controller;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\IRequest;
use OCP\ILogger;
use OCP\Files\IRootFolder;

class GeschaeftController extends Controller {

  /** @var Logger */
  private $logger;
  
  /** @var GeschaeftMapper */
  private $mapper;

  /** @var string */
  private $userId;

  private $root;

  /**
   * GeschaeftController constructor.
   *
   * @param string $AppName
   * @param IRequest $request
   * @param GeschaeftMapper $mapper
   * @param string $userId
   */
  public function __construct(ILogger $logger, $AppName, IRequest $request,
                              GeschaeftMapper $mapper, IRootFolder $root, $userId) {
    parent::__construct($AppName, $request);
    $this->logger = $logger;
    $this->mapper = $mapper;
    $this->userId = $userId;
    $this->root = $root;
  }


  /**
   * @NoAdminRequired
   * @NoCSRFRequired
   *
   * @return DataResponse
   */
  public function index() {
    $this->logger->debug('index');
    return new TemplateResponse('ggrwinti', 'index',
                                array('data' => $this->mapper->findAll($this->userId, $this->root),
                                      'root' => $this->root,
                                      'title' => 'Offene Geschäfte'));
  }

  /**
   * @NoAdminRequired
   * @NoCSRFRequired
   *
   * @return DataResponse
   */
  public function ggrsitzung($id) {
    $this->logger->debug('index');
    try {
      $date = $this->mapper->sitzungsDatum($id);
      return new TemplateResponse('ggrwinti', 'index',
                                  array('data' => $this->mapper->findSitzung($id, $this->userId, $this->root),
                                        'root' => $this->root,
                                        'title' => 'Sitzungstraktanden vom '.date("d.m.Y", strtotime($date->date))));
    } catch (Exception $e) {
      return new DataResponse([], Http::STATUS_NOT_FOUND);
    }
  }

  /**
   * @NoAdminRequired
   *
   * @param int $id
   * @param string $field
   * @param string $value
   */
  public function update($id, $field, $value) {
    try {
      if (!in_array($field, array('responsible', 'suggestion', 'decision', 'comment')))
        return new DataResponse([], Http::STATUS_NOT_FOUND); // prevent hacking
      $fn = 'set'.ucfirst($field); // create function name, e.g. 'getResponsible'
      $geschaeft = $this->mapper->find($id, $this->userId);
      $geschaeft->$fn($value);
      $this->mapper->update($geschaeft);
      return new DataResponse($geschaeft);
    } catch(Exception $e) {
      return new DataResponse([], Http::STATUS_NOT_FOUND);
    }
  }

}
