<?php
namespace OCA\GgrWinti\Db;

use OCP\AppFramework\Db\Entity;

class Geschaefte extends Entity {
  
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
}
?>
