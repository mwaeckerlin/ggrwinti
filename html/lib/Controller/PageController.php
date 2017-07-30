<?php
namespace OCA\GgrWinti\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\IRequest;

class PageController extends Controller {

	/** @var string */
	private $userId;

	/**
	 * PageController constructor.
	 *
	 * @param string $AppName
	 * @param IRequest $request
	 * @param string $userId
	 */
	public function __construct($AppName, IRequest $request, $userId) {
		parent::__construct($AppName, $request);
		$this->userId = $userId;
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
		return new TemplateResponse('ggrwinti', 'index');  // templates/index.php
	}

}

