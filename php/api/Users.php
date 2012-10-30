<?php

	class Users {
		private $db_conn;
	
	  	function __construct() {
		
			$this->db_conn = mysql_connect('localhost', 'picchat_usr', 'dope911t') or die("Could not connect to database.");
			mysql_select_db('picchat') or die("Could not select database.");
		}
	
		function __destruct() {	
			if ($this->db_conn) {
				mysql_close($this->db_conn);
				$this->db_conn = null;
			}
		}
		
		
		/**
		 * Helper method to get a string description for an HTTP status code
		 * http://www.gen-x-design.com/archives/create-a-rest-api-with-php/ 
		 * @returns status
		 */
		function getStatusCodeMessage($status) {
			
			$codes = Array(
				100 => 'Continue',
				101 => 'Switching Protocols',
				200 => 'OK',
				201 => 'Created',
				202 => 'Accepted',
				203 => 'Non-Authoritative Information',
				204 => 'No Content',
				205 => 'Reset Content',
				206 => 'Partial Content',
				300 => 'Multiple Choices',
				301 => 'Moved Permanently',
				302 => 'Found',
				303 => 'See Other',
				304 => 'Not Modified',
				305 => 'Use Proxy',
				306 => '(Unused)',
				307 => 'Temporary Redirect',
				400 => 'Bad Request',
				401 => 'Unauthorized',
				402 => 'Payment Required',
				403 => 'Forbidden',
				404 => 'Not Found',
				405 => 'Method Not Allowed',
				406 => 'Not Acceptable',
				407 => 'Proxy Authentication Required',
				408 => 'Request Timeout',
				409 => 'Conflict',
				410 => 'Gone',
				411 => 'Length Required',
				412 => 'Precondition Failed',
				413 => 'Request Entity Too Large',
				414 => 'Request-URI Too Long',
				415 => 'Unsupported Media Type',
				416 => 'Requested Range Not Satisfiable',
				417 => 'Expectation Failed',
				500 => 'Internal Server Error',
				501 => 'Not Implemented',
				502 => 'Bad Gateway',
				503 => 'Service Unavailable',
				504 => 'Gateway Timeout',
				505 => 'HTTP Version Not Supported');

			return (isset($codes[$status])) ? $codes[$status] : '';
		}
		
		
		/**
		 * Helper method to send a HTTP response code/message
		 * @returns body
		 */
		function sendResponse($status=200, $body='', $content_type='text/html') {
			
			$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
			header($status_header);
			header("Content-type: ". $content_type);
			echo $body;
		}
	    
		
		function submitNewUser($device_token) {
			$query = 'SELECT * FROM `tblUsers` WHERE `device_token` = "'. $device_token .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_object($result);
				
				$query = 'UPDATE `tblUsers` SET `last_login` = CURRENT_TIMESTAMP WHERE `id` = '. $row->id .';';
				$result = mysql_query($query);
				
			} else {				
				$query = 'INSERT INTO `tblUsers` (';
				$query .= '`id`, `username`, `device_token`, `fb_id`, `notifications`, `last_login`, `added`) ';
				$query .= 'VALUES (NULL, "", "'. $device_token .'", "", "Y", CURRENT_TIMESTAMP, NOW());';
				$result = mysql_query($query);
				$user_id = mysql_insert_id();
				
				$query = 'UPDATE `tblUsers` SET `username` = "PicChat'. $user_id .'" WHERE `id` = '. $user_id .';';
				$result = mysql_query($query);
								
				$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
				$row = mysql_fetch_object(mysql_query($query));				
			}
			
	   		$user_arr = array(
				"id" => $row->id, 
				"name" => $row->username, 
				"token" => $row->device_token, 
				"notifications" => $row->notifications
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);	
		}
		
		
		function updateName($user_id, $username, $fb_id) {
			$query = 'UPDATE `tblUsers` SET `username` = "'. $username .'", `fb_id` = '. $fb_id .' WHERE `id` ='. $user_id .';';
			$result = mysql_query($query);
			
			// $query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
			// if (mysql_num_rows(mysql_query($query)) > 0) {
			// 	$invite_id = mysql_fetch_object(mysql_query($query))->id;
			// 	
			// 	$query = 'SELECT `tblChallenges`.`id` FROM `tblChallenges` INNER JOIN `tblChallengeParticipants` ON `tblChallenges`.`id` = `tblChallengeParticipants`.`challenge_id` WHERE `tblChallenges`.`status_id` = 7 AND `tblChallengeParticipants`.`user_id` = '. $invite_id .';';
			// 	$invite_result = mysql_query($query);
			// 	
			// 	while ($challenge_row = mysql_fetch_array($invite_result, MYSQL_BOTH)) {
			// 		$query = 'UPDATE `tblChallengeParticipants` SET `user_id` = '. $user_id .' WHERE `challenge_id` = '. $challenge_row['id'] .';';
			// 		$result = mysql_query($query);
			// 		
			// 		$query = 'UPDATE `tblChallenges` SET `status_id` = 2 WHERE `id` = '. $challenge_row['id'] .';';
			// 		$result = mysql_query($query);
			// 	}
			// }
			
			
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = "'. $user_id .'";';
			$row = mysql_fetch_object(mysql_query($query));
			
			$user_arr = array(
				"id" => $row->id, 
				"name" => $row->username, 
				"token" => $row->device_token, 
				"notifications" => $row->notifications
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function getUser($user_id) {
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$row = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_id .';';
			$score = mysql_num_rows(mysql_query($query));
			
			$user_arr = array(
				"id" => $row->id, 
				"name" => $row->username, 
				"token" => $row->device_token, 
				"paid" => $row->paid, 
				"points" => $row->points + $score, 
				"notifications" => $row->notifications
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
		
		function updateNotifications($user_id, $isNotifications) {
			$user_arr = array();
			
			$query = 'UPDATE `tblUsers` SET `notifications` = "'. $isNotifications .'" WHERE `id` = '. $user_id .';';
			$result = mysql_query($query);
			
			$query = 'SELECT * FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$row = mysql_fetch_object(mysql_query($query));
			
			$query = 'SELECT `id` FROM `tblChallengeVotes` WHERE `challenger_id` = '. $user_id .';';
			$score = mysql_num_rows(mysql_query($query));
			
			$user_arr = array(
				"id" => $row->id, 
				"name" => $row->username, 
				"token" => $row->device_token, 
				"paid" => $row->paid, 
				"points" => $row->points + $score, 
				"notifications" => $row->notifications
			);
			
			$this->sendResponse(200, json_encode($user_arr));
			return (true);
		}
	    
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$users = new Users;
	////$users->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['token']))
					$users->submitNewUser($_POST['token']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['username']) && isset($_POST['fbID']))
					$users->updateName($_POST['userID'], $_POST['username'], $_POST['fbID']);
				break;
							
			case "3":
				if (isset($_POST['userID']) && isset($_POST['isNotifications']))
					$users->updateNotifications($_POST['userID'], $_POST['isNotifications']);
				break;
				
			case "4":
				if (isset($_POST['userID']))
					$users->getUser($_POST['userID']);
				break;
    	}
	}
?>