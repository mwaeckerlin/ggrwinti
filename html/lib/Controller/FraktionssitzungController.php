<?php

namespace OCA\GgrWinti\Controller;

use Exception;
use OCA\GgrWinti\Db\FraktionssitzungMapper;
use OCP\AppFramework\Controller;
//use OCP\AppFramework\Http;
//use OCP\AppFramework\Http\DataResponse;
//use OCP\AppFramework\Http\TemplateResponse;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\IRequest;

class FraktionssitzungController extends Controller {

	/** @var FraktionssitzungMapper */
	private $geschaeftMapper;

	/** @var string */
	private $userId;

	/**
	 * FraktionssitzungController constructor.
	 *
	 * @param string $AppName
	 * @param IRequest $request
	 * @param FraktionssitzungMapper $geschaeftMapper
	 * @param string $userId
	 */
	public function __construct(
		$AppName, IRequest $request, /* FraktionssitzungMapper $geschaeftMapper,*/ $userId
	) {
		parent::__construct($AppName, $request);
		//$this->geschaeftMapper = $geschaeftMapper;
		$this->userId = $userId;
	}


	/**
	 * @NoAdminRequired
	 * @NoCSRFRequired
	 *
	 * @return DataResponse
	 */
	public function index() {
		return new TemplateResponse('ggrwinti', 'fraktionssitzung'/*, array('data' => $this->geschaeftMapper->findAll($this->userId))*/);
	}

}
