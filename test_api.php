<?php
$url = 'https://sirh.alwaysdata.net/api_carnet_liaison/api/parents/1/children';
$response = file_get_contents($url);
echo $response;
?>
