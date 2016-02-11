#!/usr/bin/php
<?php

    date_default_timezone_set('UTC');

    // initialization
    $quota = 1073741824000;
    $quota_date = '2015-09-17 00:00:00';
    $anniversary_day = 8;
    $action = "shape";
    $status = "normal";
    $account_sessiontime = 150;
    $account_inputoctects = 5571;
    $accout_outputoctects = 45599;
    $today = date("Y-m-d H:i:s");

    $longopts  = array(
        "username:",
        "password:",
        "startdate:",
        "enddate::",
        "total:",
    );
    $options = getopt("", $longopts);
    if(!isset($options["username"]) || !isset($options["password"]) || !isset($options["startdate"]) || !isset($options["total"]))
        die('Please input the required parameters. ex. --username=test@testing.com --password=testing123 --startdate="2016-01-01" --enddate="2016-02-01" --total=10'."\r\n");

    var_dump($options);

    $username = $options["username"];
    $password = $options["password"];
    $start_date = date("Y-m-d H:i:s", strtotime($options["startdate"]));
    $end_date = $options["enddate"] != "" ? date("Y-m-d H:i:s", strtotime($options["enddate"])) : $today;
    $total_amount = $options["total"] * 1073741824; // Giga to byte

    $account_starttime = $start_date;
    $account_endtime = $end_date;

    echo $today."\r\n";
    echo $account_starttime."\r\n";
    echo $account_endtime."\r\n";

    $db = new mysqli("mysql", "radius", "radius", "radius");

    // update radcheck
    $query = "INSERT into `radcheck` (`username`, `attribute`, `op`, `value`) values('$username', 'Cleartext-Password', ':=', '$password')";
    echo $query."\r\n";
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // update userinfo
    $query = "INSERT into `userinfo` (`username`) values('$username')";
    echo $query."\r\n";
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // update user_billing_detail
    $query = "INSERT into `user_billing_detail` (`username`, `anniversary_day`, `action`, `status`) values('$username', '$anniversary_day', '$action', '$status')";
    echo $query."\r\n";
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // update user_quota
    $query = "INSERT into `user_quota` (`username`, `quota_date`, `quota`) values('$username', '$quota_date', '$quota')";
    echo $query."\r\n";
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    $result = $db->query("SET @disable_triggers = 1");
    if (!$result) {
        die($db->error);
    }

    // update radacct session dummy row
    $query = "INSERT INTO `radacct` (`acctsessionid`, `acctuniqueid`, `UserName`, `GroupName`, `realm`, `NASIPAddress`, `NASPortId`, `nasporttype`, `AcctStartTime`, `AcctStopTime`, `AcctSessionTime`, `acctauthentic`, `connectinfo_start`, `connectinfo_stop`, `AcctInputOctets`, `AcctOutputOctets`, `CalledStationId`, `CallingStationId`, `acctterminatecause`, `servicetype`, `framedprotocol`, `FramedIPAddress`, `acctstartdelay`, `acctstopdelay`, `xascendsessionsvrkey`)
        values('0004752B', '86716ad2a8b3d327', '$username', '', '', '114.141.96.4', '', 'ISDN', '$account_starttime', '$account_endtime', '$account_sessiontime', 'RADIUS', '155520000', '155520000', '$account_inputoctects', '$accout_outputoctects', '', 'foobar', 'Port-Error', 'Framed-User', 'PPP', '127.0.0.15', 0, 0, '')";
    echo $query."\r\n";
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // add linear data to user_data table
    $update= "INSERT into `user_data` (`username`, `datain`, `dataout`, `totaldata`, `data_hour`, `date`) values(?, ?, ?, ?, ?, ?)";
    $stmt=$db->prepare($update);
    if (!$stmt) {
        die($db->error);
    }
    $stmt->bind_param("siiiis", $username, $datain, $dataout, $totaldata, $data_hour, $date);
    $stmt->execute();

    $start = strtotime($start_date);
    $end = strtotime($end_date);
    $pointer = strtotime($start_date);

    $data_slice = floor($total_amount / (abs($end - $start) / 3600));
    $datain += floor($data_slice * 0.4);
    $dataout += floor($data_slice * 0.6);
    $totaldata = $datain + $dataout;

    echo 'total: '.$total_amount."\r\n";
    echo 'slice: '.$data_slice."\r\n";

    while ($pointer <= $end) {

        $pointer = $pointer + 60*60;
        $data_hour = date('H', $pointer);
        $date = date('Y-m-d', $pointer);
        echo $date.'-'.$data_hour."\r\n";
        $stmt->execute();

    }

    $result = $db->query("SET @disable_triggers = NULL");
    if (!$result) {
        die($db->error);
    }

?>
