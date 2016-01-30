#!/usr/bin/php
<?php
$date_now = date("Y-m-d", time() - 60 * 60 * 4);
$query = "
SELECT
	username,
	SUM(acctinputoctets) as datain,
	SUM(acctoutputoctets) as dataout,
	(SUM(acctinputoctets)+sum(acctoutputoctets)) as totaldata,
	HOUR(`timestamp`) as data_hour,
    DATE(`timestamp`) as date
 FROM `user_stats`
 GROUP BY username, HOUR(`timestamp`), date";
$db = new mysqli("mysql", "radius", "radius", "radius");
$res = $db->query($query);
$username="";
$datain=0;
$dataout=0;
$totaldata=0;
$data_hour=0;
$date="2000-01-01";
$update= "INSERT into `user_data` (`username`, `datain`, `dataout`, `totaldata`, `data_hour`, `date`) values(?, ?, ?, ?, ?, ?)
ON DUPLICATE KEY UPDATE `datain`=?, `dataout`=?, `totaldata`=?";
$stmt=$db->prepare($update);
if (!$stmt) {
	die($db->error);
}
$stmt->bind_param("siiiisiii", $username, $datain, $dataout, $totaldata, $data_hour, $date, $datain, $dataout, $totaldata);
while ($row = $res->fetch_assoc()) {
	#echo "$row[acctuniqueid] $row[username] expired $row[sessionlastupdate]\n";
	$username = $row['username'];
	$datain=$row['datain'];
	$dataout=$row['dataout'];
	$totaldata=$row['totaldata'];
	$data_hour=$row['data_hour'];
	$date=$row['date'];
	$stmt->execute();
}
$query = "
DELETE from `user_stats` where 
        `timestamp` < subdate(current_date, 1);
";
$res = $db->query($query);