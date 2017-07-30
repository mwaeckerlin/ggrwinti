<h1>Offene Geschäfte</h1>

<table id="geschaefte">
  <thead>
    <tr>
      <th>GGR-Nr.</th>
      <th>Titel</th>
      <th>Typ</th>
      <th>Datum</th>
    </tr>
  </thead>
  <tbody>
    <?php
    if (key_exists('data', $_)) {
      foreach ($_['data'] as $data) {
	echo "<tr>";
	echo "<td>" . $data->ggrnr() . "</td>";
	echo "<td>" . $data->title() . "</td>";
	echo "<td>" . $data->type() . "</td>";
	echo "<td>" . $data->datum() . "</td>";
	echo "</tr>";
      }
    }
    ?>
  </tbody>
</table>
