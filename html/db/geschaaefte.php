<?php
namespace OCA\GgrWinti\Db;

use JsonSerializable;
use OCP\AppFramework\Db\Entity;

class Geschaefte extends Entity implements JsonSerializable {

  public function jsonSerialize() {
    return $this;
  }
}
?>
