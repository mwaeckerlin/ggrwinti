<?php
namespace OCA\GgrWinti\Db;

use OC\DB\Connection;
use OCP\AppFramework\Db\Mapper;
use PDO;

class GgrsitzungenMapper extends Mapper {
  
  public function __construct(Connection $db) {
    parent::__construct($db, 'ggrwinti_ggrsitzungen', '\OCA\GgrWinti\Db\Ggrsitzungen');
  }
  
  public function find($id, $userId) {
    $sql = 'SELECT * FROM *PREFIX*ggrwinti_ggrsitzungen WHERE id = ?';
    return $this->findEntity($sql, [$id]);
  }

  public function findAll($userId) {
    $sql = 'SELECT * FROM *PREFIX*ggrwinti_ggrsitzungen ORDER BY date DESC';
    return $this->findEntities($sql);
  }

  public function findMore($userId) {
    $sql = 'SELECT COUNT(t.id) as count, s.id as id, s.date as date FROM *PREFIX*ggrwinti_ggrsitzungen AS s LEFT JOIN *PREFIX*ggrwinti_ggrsitzung_traktanden AS t ON s.id=t.ggrsitzung GROUP BY s.id ORDER BY date DESC';
    $stmt = $this->execute($sql);
    return $stmt->fetchAll(PDO::FETCH_OBJ);
  }
  
}
