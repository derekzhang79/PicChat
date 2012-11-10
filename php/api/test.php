<?php

$db_conn = mysql_connect('localhost', 'picchat_usr', 'dope911t') or die("Could not connect to database.");
mysql_select_db('picchat') or die("Could not select database.");

$imgURLs = "https://picchat-entries.s3.amazonaws.com/d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed_1352416516_0.jpg|https://picchat-entries.s3.amazonaws.com/d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed_1352416516_1.jpg|https://picchat-entries.s3.amazonaws.com/d197f503d8a14322fe10eab4005fde4d0517ffb44581060811cf8a688eb47aed_1352416516_2.jpg";
$imgURL_arr = explode('|', $imgURLs);

$img_cnt = 0;
foreach ($imgURL_arr as $key) {
	echo ("[". $img_cnt ."] ". $key);
}

$query = 'SELECT `device_token`, `notifications` FROM `tblUsers` WHERE `id` = 2;';			
$creator_obj = mysql_fetch_object(mysql_query($query));
$device_token = $creator_obj->device_token;
$isPush = ($creator_obj->notifications == "Y");
$creator_name = "TOOFUS";
$subject_name = "DERP";

echo ("isPush[".$isPush."] (".$device_token.")\n");

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
curl_setopt($ch, CURLOPT_USERPWD, "luPaeCF1Ry-H2Slh0Pef1w:dSycB-EmRHKYLAz971k2PQ"); // dev
//curl_setopt($ch, CURLOPT_USERPWD, ":"); // live
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_name .' has submitted to your #'. $subject_name .' chat!", "sound": "push_01.caf"}}');
	$res = curl_exec($ch);
$err_no = curl_errno($ch);
$err_msg = curl_error($ch);
$header = curl_getinfo($ch);
curl_close($ch);

if ($db_conn) {
	mysql_close($db_conn);
	$db_conn = null;
}

?>