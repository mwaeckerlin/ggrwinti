<?php

namespace OCA\GgrWinti\Controller;

use Exception;
use OCA\GgrWinti\Db\GgrsitzungenMapper;
use OCP\AppFramework\Controller;
use OCP\AppFramework\Http;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\IRequest;
use OCP\ILogger;

class GgrsitzungenController extends Controller {

  /** @var Logger */
  private $logger;
  
  /** @var GgrsitzungenMapper */
  private $mapper;

  /** @var string */
  private $userId;

  /**
   * GgrsitzungenController constructor.
   *
   * @param string $AppName
   * @param IRequest $request
   * @param GgrsitzungenMapper $mapper
   * @param string $userId
   */
  public function __construct(ILogger $logger, $AppName, IRequest $request,
                              GgrsitzungenMapper $mapper, $userId) {
    parent::__construct($AppName, $request);
    $this->logger = $logger;
    $this->mapper = $mapper;
    $this->userId = $userId;
  }


  /**
   * @NoAdminRequired
   * @NoCSRFRequired
   *
   * @return DataResponse
   */
  public function index() {
    $this->logger->debug('index');
    return new TemplateResponse('ggrwinti', 'ggrsitzungen',
                                array('data' => $this->mapper->findMore($this->userId)));
  }

}
