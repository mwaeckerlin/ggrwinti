<?php
use \OCP\URLGenerator;
$url = \OC::$server->getURLGenerator();
?>

<ul>
  <li><a href="<?php echo $url->linkToRoute('ggrwinti.geschaeft.index'); ?>">Offene Geschäfte</a></li>
  <li><a href="<?php echo $url->linkToRoute('ggrwinti.ggrsitzungen.index'); ?>">GGR Sitzungen</a></li>
</ul>
