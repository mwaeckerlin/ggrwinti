<?php
namespace OCA\GgrWinti\Db;

use OC\DB\Connection;
use OCP\AppFramework\Db\Mapper;
use PDO;

class GeschaeftMapper extends Mapper {
  
  public function __construct(Connection $db) {
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
  
  public function findSitzung($id, $userId) {
    $sql = 'SELECT g.id as id, g.title as title, g.ggrnr as ggrnr, g.type as type, g.status as status, g.date as date, g.responsible as responsible, g.suggestion as suggestion, g.decision as decision, g.comment as comment, g.status as status FROM *PREFIX*ggrwinti_geschaefte as g left join *PREFIX*ggrwinti_ggrsitzung_traktanden as t on g.id=t.geschaeft where t.ggrsitzung = ? order by t.nr asc';
    return $this->findEntities($sql, [$id]);
  }

  public function sitzungsDatum($id) {
    $sql = 'select date from *PREFIX*ggrwinti_ggrsitzungen where id=?';
    $stmt = $this->execute($sql, [$id]);
    return $stmt->fetch(PDO::FETCH_OBJ);
  }
  
}
