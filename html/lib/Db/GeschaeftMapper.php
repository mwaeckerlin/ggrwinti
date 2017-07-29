<?php
namespace OCA\GgrWinti\Db;

use OCP\IDbConnection;
use OCP\AppFramework\Db\Mapper;

class GeschaeftMapper extends Mapper {
  
  public function __construct(IDb $db) {
    parent::__construct($db, 'ggrwinti_geschaefte', '\OCA\GgrWinti\Db\Geschaeft');
  }
  
  public function find($id, $userId) {
    $sql = 'SELECT * FROM *PREFIX*ggrwinti_geschaefte WHERE id = ?';
    return $this->findEntity($sql, [$id]);
  }

  public function findAll($userId) {
    $sql = 'SELECT * FROM *PREFIX*ggrwinti_geschaefte WHERE status!=\'Erledigt\'';
    return $this->findEntities($sql);
  }
  
}
?>
