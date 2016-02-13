#!/usr/bin/php
<?php

    date_default_timezone_set('UTC');

    // initialization
    $quota = 0;
    $quota_date = "";
    $action = "shape";
    $status = "normal";
    $account_sessiontime = 1000;
    $account_inputoctects = 5000;
    $accout_outputoctects = 10000;
    $today = date("Y-m-d H:i:s");

    $longopts  = array(
        "username:",
        "password:",
        "startdate:",
        "enddate::",
        "totalgb:",
        "nasip:",
        "quotagb::",
        "quotadate::",
        "annivsday::"
    );
    $options = getopt("", $longopts);

    // check mandatory options
    if(!isset($options["username"]) || !isset($options["password"]) || !isset($options["startdate"]) || !isset($options["totalgb"]) || !isset($options["nasip"]))
        die('Please input the required parameters. ex. --username=test@testing.com --password=testing123 --startdate="2016-01-01" --enddate="2016-02-01" --totalgb=10 --nasip="3.3.3.3" --quotagb=10 --quotadate="2016-01-01" --annivsday=1'.PHP_EOL);

    //var_dump($options);

    $username = $options["username"];
    $password = $options["password"];
    $start_date = date("Y-m-d H:i:s", strtotime($options["startdate"]));
    $total_amount = $options["totalgb"] * 1073741824; // Giga to byte
    $nasip = $options["nasip"];

    if(isset($options["enddate"]))
        $end_date = date("Y-m-d H:i:s", strtotime($options["enddate"]));
    else
        $end_date = $today;

    if(isset($options["quotagb"]))
        $quota = $options["quotagb"] * 1073741824; // Giga to byte

    if(isset($options["quotadate"]))
        $quota_date = date("Y-m-d H:i:s", strtotime($options["quotadate"]));

    if(isset($options["annivsday"]))
        $anniversary_day = $options["annivsday"];
    else
        $anniversary_day = date("d", strtotime($options["startdate"]));

    $account_starttime = $start_date;
    $account_endtime = $end_date;

    //echo $today.PHP_EOL;
    //echo $account_starttime.PHP_EOL;
    //echo $account_endtime.PHP_EOL;

    $db = new mysqli("mysql", "radius", "radius", "radius");

    // update radcheck
    $query = "INSERT into `radcheck` (`username`, `attribute`, `op`, `value`) values('$username', 'Cleartext-Password', ':=', '$password')";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // update userinfo
    $query = "INSERT into `userinfo` (`username`) values('$username')";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // update user_billing_detail
    $query = "INSERT into `user_billing_detail` (`username`, `anniversary_day`, `action`, `status`) values('$username', '$anniversary_day', '$action', '$status')";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if (!$result) {
        die($db->error);
    }

    // update user_quota
    if($quota != 0 && $quota_date != "") {
        $query = "INSERT into `user_quota` (`username`, `quota_date`, `quota`) values('$username', '$quota_date', '$quota')";
        echo $query.PHP_EOL;
        $result = $db->query($query);
        if (!$result) {
            die($db->error);
        }
    }

    // diable triggers
    $result = $db->query("SET @disable_triggers = 1");
    if (!$result) {
        die($db->error);
    }

    // update radacct session dummy row
    $acctsessionid = bin2hex(openssl_random_pseudo_bytes(4));
    $acctuniqueid = bin2hex(openssl_random_pseudo_bytes(8));
    //echo "accsessionid: ".$acctsessionid.PHP_EOL;
    //echo "acctuniqueid: ".$acctuniqueid.PHP_EOL;

    $query = "INSERT INTO `radacct` (`acctsessionid`, `acctuniqueid`, `UserName`, `GroupName`, `realm`, `NASIPAddress`, `NASPortId`, `nasporttype`, `AcctStartTime`, `AcctStopTime`, `AcctSessionTime`, `acctauthentic`, `connectinfo_start`, `connectinfo_stop`, `AcctInputOctets`, `AcctOutputOctets`, `CalledStationId`, `CallingStationId`, `acctterminatecause`, `servicetype`, `framedprotocol`, `FramedIPAddress`, `acctstartdelay`, `acctstopdelay`, `xascendsessionsvrkey`)
        values('$acctsessionid', '$acctuniqueid', '$username', '', '', '$nasip', '', 'ISDN', '$account_starttime', '$account_endtime', '$account_sessiontime', 'RADIUS', '155520000', '155520000', '$account_inputoctects', '$accout_outputoctects', '', 'foobar', 'Port-Error', 'Framed-User', 'PPP', '127.0.0.15', 0, 0, '')";
    echo $query.PHP_EOL;
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
    $datain = floor($data_slice * 0.4);
    $dataout = $data_slice - $datain;
    $totaldata = $data_slice;

    //echo 'total: '.$total_amount.PHP_EOL;
    //echo 'slice: '.$data_slice.PHP_EOL;

    $restdata = $total_amount;
    while ($restdata > $data_slice) {

        $pointer = $pointer + 60*60;
        $data_hour = date('H', $pointer);
        $date = date('Y-m-d', $pointer);
        echo $date.' '.$data_hour.PHP_EOL;
        $stmt->execute();
        if (!$stmt) {
            die($db->error);
        }

        $restdata -= $data_slice;

    }

    // process the rest
    $datain = $restdata;
    $dataout = 0;
    $totaldata = $restdata;
    $pointer = $pointer + 60*60;
    $data_hour = date('H', $pointer);
    $date = date('Y-m-d', $pointer);
    echo $date.' '.$data_hour.' '.$totaldata.' '.$datain.PHP_EOL;
    $stmt->execute();
    if (!$stmt) {
        die($db->error);
    }

    // enable triggers
    $result = $db->query("SET @disable_triggers = NULL");
    if (!$result) {
        die($db->error);
    }

?>
