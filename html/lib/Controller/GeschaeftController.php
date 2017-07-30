<?php

namespace OCA\GgrWinti\Controller;

use Exception;
use OCA\GgrWinti\Db\GeschaeftMapper;
use OCP\AppFramework\Controller;
//use OCP\AppFramework\Http;
//use OCP\AppFramework\Http\DataResponse;
//use OCP\AppFramework\Http\TemplateResponse;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\IRequest;

class GeschaeftController extends Controller {

	/** @var GeschaeftMapper */
	private $geschaeftMapper;

	/** @var string */
	private $userId;

	/**
	 * GeschaeftController constructor.
	 *
	 * @param string $AppName
	 * @param IRequest $request
	 * @param GeschaeftMapper $geschaeftMapper
	 * @param string $userId
	 */
	public function __construct(
		$AppName, IRequest $request, GeschaeftMapper $geschaeftMapper, $userId
	) {
		parent::__construct($AppName, $request);
		$this->geschaeftMapper = $geschaeftMapper;
		$this->userId = $userId;
	}


	/**
	 * @NoAdminRequired
	 * @NoCSRFRequired
	 *
	 * @return DataResponse
	 */
	public function index() {
		return new TemplateResponse('ggrwinti', 'index', array('data' => $this->geschaeftMapper->findAll($this->userId)));
	}

}
