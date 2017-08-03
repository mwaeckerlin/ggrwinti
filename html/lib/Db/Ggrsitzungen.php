<?php
namespace OCA\GgrWinti\Db;

use JsonSerializable;

use OCP\AppFramework\Db\Entity;

class Ggrsitzungen extends Entity implements JsonSerializable {
  
  protected $date;

  public function id() {
    return $this->id;
  }
  public function date() {
    return $this->date;
  }
  public function count() {
    return $this->count;
  }

  public function jsonSerialize() {
    return [
      'id' => $this->id,
      'date' => $this->date,
      'count' => $this->count,
    ];
  }
}
?>
