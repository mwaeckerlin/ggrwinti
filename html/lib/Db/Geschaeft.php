<?php
namespace OCA\GgrWinti\Db;

use JsonSerializable;

use OCP\AppFramework\Db\Entity;

class Geschaeft extends Entity implements JsonSerializable {
  
  protected $title;
  protected $ggrnr;
  protected $type;
  protected $status;
  protected $date;
  protected $responsible;
  protected $suggestion;
  protected $decision;
  protected $comment;

  public function id() {
    return $this->id;
  }
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
  public function date() {
    return $this->date;
  }
  
  public function responsible() {
    return $this->responsible;
  }
  
  public function suggestion() {
    return $this->suggestion;
  }
  
  public function decision() {
    return $this->decision;
  }
  
  public function comment() {
    return $this->comment;
  }

  public function jsonSerialize() {
    return [
      'id' => $this->id,
      'title' => $this->title,
      'ggrnr' => $this->ggrnr,
      'type' => $this->type,
      'status' => $this->status,
      'date' => $this->date,
      'responsible' => $this->responsible,
      'suggestion' => $this->suggestion,
      'decision' => $this->decision,
      'comment' => $this->comment
    ];
  }
}
?>
