<?php
use \OCP\Util;
$util = new Util();

//use OCP\IURLGenerator;
$app = new \OCA\GgrWinti\AppInfo\Application;
$urlGenerator = \OC::$server->getURLGenerator();
//echo '<p>URL="'.$urlGenerator->linkToRoute('ggrwinti').'"</p>';
?>

<pre>
-------------------------------------
<?php echo '<p>URL="'.$urlGenerator->linkToRoute().'"</p>'; ?>
-------------------------------------
</pre>

<ul>
  <li><a href="/index.php<?php echo $util->linkTo('ggrwinti'); ?>geschaefte">Offene Geschäfte</a></li>
  <li><a href="/index.php<?php echo $util->linkTo('ggrwinti'); ?>ggrsitzungen">GGR Sitzungen</a></li>
</ul>
