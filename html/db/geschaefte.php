<?php
namespace OCA\GgrWinti\Db;

use JsonSerializable;

use OCP\AppFramework\Db\Entity;

class Geschaefte extends Entity implements JsonSerializable {
  
  protected $title;
  protected $ggrnr;
  protected $type;
  protected $status;
  protected $datum;

  public function title() {
    return $this->title;
  }
  public function ggrnr() {
    return $this->ggrnr;
  }
  public function type() {
    return $this->type;
  }
  public function status() {
    return $this->status;
  }
  public function datum() {
    return $this->datum;
  }
  
  public function jsonSerialize() {
    return [
      'id' => $this->id,
      'title' => $this->title,
      'ggrnr' => $this->ggrnr,
      'type' => $this->type,
      'status' => $this->status,
      'datum' => $this->datum
    ];
  }
}
?>
