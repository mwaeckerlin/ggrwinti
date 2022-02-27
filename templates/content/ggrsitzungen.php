<form action="" id="ggrsitzungen">
  <?php
  if (key_exists('data', $_)) {
    foreach ($_['data'] as $data) {
      if ($data->count>0) {
        echo '<div class="sitzung" title="'.$data->date.'">';
        echo '<div><a href="ggrsitzung/'.$data->id.'">' . $data->date . "</a></div>";
        echo "</div>";
      }
    }
  }
  ?>
</form>
