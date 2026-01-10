<?php
    $servername = "localhost";
    $db_name = "musicbvk_pawpal_db_maithilly";
    $username = "musicbvk_maithilly";
    $passowrd = "Ninja@230604;
    $conn = new mysqli(
        $servername,
        $username,
        $passowrd,
        $db_name
    );
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
?>