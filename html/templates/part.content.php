<h1>Geschäfte</h1>

<table id="geschaefte">
  <thead>
    <tr><th>GGR-Nr.</th><th>Titel</th><th>Typ</th><th>Status</th><th>Datum</th><th>Verantwortlich</th><th>Antrag</th><th>Entscheid Fraktion</th></tr>
  </thead>
  <tbody>
    <?php
    foreach ($_['data'] as $data) {
      echo "<tr>";
      echo "<td>".$data->ggrnr()."</td>";
      echo "<td>".$data->title()."</td>";
      echo "<td>".$data->type()."</td>";
      echo "<td>".$data->status()."</td>";
      echo "<td>".$data->datum()."</td>";
      echo "</tr>";
    }
    ?>
  </tbody>
</table>
