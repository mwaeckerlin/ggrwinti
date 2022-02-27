<?php
script('ggrwinti', 'script');
style('ggrwinti', 'style');
?>

<div id="app">
  <h2>GGR Sitzungstermine</h2>
  <div id="app-navigation">
    <?php print_unescaped($this->inc('navigation/index')); ?>
    <?php print_unescaped($this->inc('settings/index')); ?>
  </div>

  <div id="app-content">
    <div id="app-content-wrapper">
      <?php print_unescaped($this->inc('content/ggrsitzungen')); ?>
    </div>
  </div>
</div>
