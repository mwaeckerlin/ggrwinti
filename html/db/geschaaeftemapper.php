<?php
namespace OCA\GgrWinti\Db;

use OCP\IDb;
use OCP\AppFramework\Db\Mapper;

class GeschaefteMapper extends Mapper {
  
  public function __construct(IDb $db) {
    parent::__construct($db, 'ggrwinti_geschaefte', '\OCA\GgrWinti\Db\Geschaefte');
  }
  
  public function findAll() {
    $sql = 'SELECT * FROM *PREFIX*ggrwinti_geschaefte';
    return $this->findEntities($sql);
  }
  
}
?>
