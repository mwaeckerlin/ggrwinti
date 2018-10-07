<?php
script('ggrwinti', 'script');
style('ggrwinti', 'style');
?>

<div id="app">
  <div id="app-navigation">
    <h2>Geschäftsliste: <?php  echo $_['title']; ?></h2>
    <?php print_unescaped($this->inc('navigation/index')); ?>
    <?php print_unescaped($this->inc('settings/index')); ?>

    <p><a class="table-export" data-table="#geschaefte" download="geschaefte.csv">exportieren</a></p>
  </div>

  <div id="app-content">
    <div id="app-content-wrapper">
      <?php print_unescaped($this->inc('content/index')); ?>
    </div>
  </div>
</div>
