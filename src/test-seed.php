#!/usr/bin/php
<?php

    $longopts  = array(
        "username:",
        "password:",
        "totalgb:"
    );
    $options = getopt("", $longopts);

    //var_dump($options);

    // check mandatory options
    if(!isset($options["username"]) || !isset($options["password"]) || !isset($options["totalgb"]))
        die('Please input the required parameters. ex. --username=test@testing.com --password=testig123 --totalgb=10'.PHP_EOL);

    $username = $options["username"];
    $password = $options["password"];
    $total_amount = $options["totalgb"] * 1073741824; // Giga to byte

    $db = new mysqli("mysql", "radius", "radius", "radius");

    // update radcheck
    $query = "SELECT * FROM `radcheck` WHERE username='$username' AND attribute='Cleartext-Password' AND value='$password'";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if ($result->num_rows != 1) {
        exit(1);
    }

    // update userinfo
    $query = "SELECT * FROM `userinfo` WHERE username='$username'";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if ($result->num_rows != 1) {
        exit(1);
    }

    // update user_billing_detail
    $query = "SELECT * FROM `user_billing_detail` WHERE username='$username'";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if ($result->num_rows != 1) {
        exit(1);
    }

    // update user_quota
    $query = "SELECT * FROM `user_quota` WHERE username='$username'";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if ($result->num_rows != 1) {
        exit(1);
    }

    $query = "SELECT * FROM `radacct` WHERE username='$username'";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    if ($result->num_rows != 1) {
        exit(1);
    }

    $query = "SELECT SUM(`totaldata`) as totalsum FROM `user_data` WHERE username='$username'";
    echo $query.PHP_EOL;
    $result = $db->query($query);
    $row = $result->fetch_assoc();
    echo $row['totalsum']." == ".$total_amount.PHP_EOL;
    if($row['totalsum'] != $total_amount) {
        exit(1);
    }

    echo "success!".PHP_EOL;
    exit(0);

?>
