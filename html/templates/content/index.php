<h1>Geschäfte</h1>

<pre>
<?php print_r($_); ?>
</pre>

<table id="geschaefte">
	<thead>
	<tr>
		<th>GGR-Nr.</th>
		<th>Titel</th>
		<th>Typ</th>
		<th>Status</th>
		<th>Datum</th>
		<th>Verantwortlich</th>
		<th>Antrag</th>
		<th>Entscheid Fraktion</th>
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
			echo "<td>" . $data->status() . "</td>";
			echo "<td>" . $data->datum() . "</td>";
			echo "</tr>";
		}
	}
	?>
	</tbody>
</table>
