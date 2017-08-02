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

<h1>Offene Geschäfte</h1>

<table id="geschaefte">
  <thead>
    <tr>
      <th></th>
      <th>GGR-Nr.</th>
      <th>Titel</th>
      <th>Zuständig</th>
      <th>Antrag</th>
      <th>Entscheid</th>
      <th>Kommentar</th>
    </tr>
  </thead>
  <tbody>
    <?php
    if (key_exists('data', $_)) {
      foreach ($_['data'] as $data) {
	echo '<form action=""><tr title="'.$data->date().': '.$data->type().'">';
	echo "<td>";
        switch ($data->type()) {
          case "Verordnung / Rechtserlass": echo "s"; break;
          case "Übrige Geschäfte": echo "x"; break;
          case "Vertrag / Vereinbarung": echo "v"; break;
          case "Volksinitiative": echo "V"; break;
          case "Wahl": echo "w"; break;
          case "Motion": echo "m"; break;
          case "Dringliches Postulat": echo "P"; break;
          case "Dringliche Interpellation": echo "I"; break;
          case "Dringliche Motion": echo "M"; break;
          case "Postulat": echo "p"; break;
          case "Interpellation": echo "i"; break;
          case "Kreditantrag": echo "K"; break;
          case "Schriftliche Anfrage": echo "a"; break;
          default: echo $data->type();
        };
        echo "</td>";
        echo "<td>" . $data->ggrnr() . "</td>";
	echo "<td>" . $data->title() . "</td>";
	echo '<td><input class="responsible" id="responsible'.$data->id().'" type="text" name="responsible" list="users" value="' . $data->responsible() . '" /></td>';
	echo '<td><input type="text" name="suggestion" list="decisions" value="' . $data->suggestion() . '" /></td>';
	echo '<td><input type="text" name="decision" list="decisions" value="' . $data->decision() . '" /></td>';
	echo '<td><textarea name="comment">' . $data->comment() . "</textarea></td>";
	echo "</tr></form>";
      }
    }
    ?>
  </tbody>
</table>
