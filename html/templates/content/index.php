<datalist id="decisions">
  <option value="miteinreichen">miteinreichen</option>
  <option value="unterstützen">unterstützen</option>
  <option value="überweisen">überweisen</option>
  <option value="nicht überweisen">nicht überweisen</option>
  <option value="ablehnen">ablehnen</option>
  <option value="rückweisen">rückweisen</option>
  <option value="ablehnende Kenntnisnahme">ablehnende Kenntnisnahme</option>
  <option value="zustimmende Kenntnisnahme">zustimmende Kenntnisnahme</option>
  <option value="Kenntnisnahme">Kenntnisnahme</option>
  <option value="erheblich erklären">erheblich erklären</option>
</datalist>
<datalist id="users">
  <option value="katrin"></option>
  <option value="annetta"></option>
  <option value="silvia"></option>
  <option value="martin"></option>
  <option value="markus"></option>
  <option value="urs"></option>
  <option value="rahel"></option>
  <option value="marc"></option>
</datalist>

<h2>Geschäftsliste: <?php  echo $_['title']; ?></h2>

<form action="" id="geschaefte">
  <div class="filter">
    <div><input data-field="ggrnr" placeholder="filter" type="text" /></div>
    <div><input data-field="title" placeholder="filter" type="text" /></div>
    <div><input data-field="responsible" placeholder="filter" type="text" /></div>
    <div><input data-field="suggestion" placeholder="filter" type="text" /></div>
    <div><input data-field="decision" placeholder="filter" type="text" /></div>
    <div><input data-field="comment" placeholder="filter" type="text" /></div>
  </div>
  <?php
  if (key_exists('data', $_)) {
    foreach ($_['data'] as $data) {
      $status=preg_replace('/[^a-z]+/', '_', strtolower($data->status()));
      echo '<div class="geschaeft '.$status.'" title="'.$data->date().': '.$data->type().'">';
      echo '<div data-field="ggrnr">' . $data->ggrnr() . "</div>";
      echo '<div data-field="title">' . $data->type().': '.$data->title() . "</div>";
      echo '<div><input placeholder="Zuständig" class="edit" data-field="responsible" data-id="'.$data->id().'" type="text" name="responsible" list="users" maxlength="255" value="' . $data->responsible() . '" /></div>';
      echo '<div><input placeholder="Antrag" class="edit" data-field="suggestion" data-id="'.$data->id().'" type="text" name="suggestion" list="decisions" maxlength="255" value="' . $data->suggestion() . '" /></div>';
      echo '<div><input placeholder="Entscheid" class="edit" data-field="decision" data-id="'.$data->id().'" type="text" name="decision" list="decisions" maxlength="255" value="' . $data->decision() . '" /></div>';
      echo '<div><textarea placeholder="Kommentar" class="edit" data-field="comment" data-id="'.$data->id().'" maxlength="255" name="comment">' . $data->comment() . "</textarea></div>";
      echo "</div>";
    }
  }
  ?>
</form>
