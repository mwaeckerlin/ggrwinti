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
    foreach ($_['data']['items'] as $data) {
      $docs = $_['data']['docs'][$data->ggrnr()];
      $status=preg_replace('/[^a-z]+/', '_', strtolower($data->status()));
      echo '<div class="geschaeft '.$status.'" title="'.$data->date().': '.$data->type().'">';
      echo '<a href="http://gemeinderat.winterthur.ch/de/politbusiness/?action=showinfo&info_id='.$data->id().'" target="_blank"><div data-field="ggrnr">' . $data->ggrnr() . "</div></a>";
      switch (count($docs)) {
        case 0:
          echo '<div data-field="title"><del>' . $data->type().': '.$data->title() . "</del></div>";
          break;
        case 1:
          echo '<div data-field="title"><a href="/remote.php/webdav'.str_replace($_['user'].'/files/', '', $docs[0]->getPath()).'">' . $data->type().': '.$data->title() . "</a></div>";
          break;
        default:
          echo '<div data-field="title"><a href="/remote.php/webdav'.str_replace($_['user'].'/files/', '', $docs[0]->getPath()).'">' . $data->type().': '.$data->title() . "</a>";
          $i=0;
          foreach ($docs as $doc) {
            echo '<a href="/remote.php/webdav/'.str_replace($_['user'].'/files/', '', $docs[0]->getPath()).'">['.(++$i).']</a> ';
          }
          echo "</div>";
          break;
      }
      echo '<div><input placeholder="Zuständig" class="edit" data-field="responsible" data-id="'.$data->id().'" type="text" name="responsible" list="users" maxlength="255" value="' . $data->responsible() . '" /></div>';
      echo '<div><input placeholder="Antrag" class="edit" data-field="suggestion" data-id="'.$data->id().'" type="text" name="suggestion" list="decisions" maxlength="255" value="' . $data->suggestion() . '" /></div>';
      echo '<div><input placeholder="Entscheid" class="edit" data-field="decision" data-id="'.$data->id().'" type="text" name="decision" list="decisions" maxlength="255" value="' . $data->decision() . '" /></div>';
      echo '<div><textarea placeholder="Kommentar" class="edit" data-field="comment" data-id="'.$data->id().'" maxlength="255" name="comment">' . $data->comment() . "</textarea></div>";
      echo "</div>";
    }
  }
  ?>
</form>
