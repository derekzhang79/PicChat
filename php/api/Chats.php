<?php

	class Chats {
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
	    
		
		function chatsForUser($user_id) {
			$chats_arr = array();
			
			$query = 'SELECT * FROM `tblChats` WHERE `status_id` < 4 AND (`creator_id` = '. $user_id .' OR `participant_id` = '. $user_id .') ORDER BY `added` DESC;';
			$chat_result = mysql_query($query);
						
			while ($chat_row = mysql_fetch_array($chat_result, MYSQL_BOTH)) {
				$query = 'SELECT `username`, `fb_id` FROM `tblUsers` WHERE `id` = '. $chat_row['creator_id'] .';';
				$creator_obj = mysql_fetch_object(mysql_query($query));
				
				if ($chat_row['status_id'] == "2") {
					$query = 'SELECT `username`, `fb_id` FROM `tblInvitedUsers` WHERE `id` = '. $chat_row['participant_id'] .';';
					$participant_obj = mysql_fetch_object(mysql_query($query));
					
				} else {
					$query = 'SELECT `username`, `fb_id` FROM `tblUsers` WHERE `id` = '. $chat_row['participant_id'] .';';
					$participant_obj = mysql_fetch_object(mysql_query($query));
				}
				
				$query = 'SELECT `title` FROM `tblSubjects` WHERE `id` = '. $chat_row['subject_id'] .';';
				$subject_obj = mysql_fetch_object(mysql_query($query));
				
				array_push($chats_arr, array(
					"id" => $chat_row['id'], 
					"creator_id" => $chat_row['creator_id'], 
					"creator_name" => $creator_obj->username, 
					"creator_fb" => $creator_obj->fb_id, 
					"participant_id" => $chat_row['participant_id'], 
					"participant_name" => $participant_obj->username, 
					"participant_fb" => $participant_obj->fb_id, 
					"subject_id" => $chat_row['subject_id'], 
					"subject_name" => $subject_obj->title, 
					"status_id" => $chat_row['status_id'], 					
					"added" => $chat_row['added']
				));
			}			
			
			$this->sendResponse(200, json_encode($chats_arr));
			return (true);	
		}
		
		function submitNewChat($user_id, $fb_id, $fb_name, $subject_name, $imgURLs) {
			$chat_arr = array();			
			$imgURL_arr = explode('|', $imgURLs);
			
			if ($subject_name == "")
				$subject_name = "N/A";
			
			$query = 'SELECT `id` FROM `tblSubjects` WHERE `title` = "'. $subject_name .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$subject_id = $row[0];
			
			} else {
				$query = 'INSERT INTO `tblSubjects` (';
				$query .= '`id`, `title`, `creator_id`, `added`) ';
				$query .= 'VALUES (NULL, "'. $subject_name .'", "'. $user_id .'", NOW());';
				$subject_result = mysql_query($query);
				$subject_id = mysql_insert_id();
			}
			
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_name = mysql_fetch_object(mysql_query($query))->username;
			
			$query = 'SELECT `id`, `username`, `device_token`, `notifications` FROM `tblUsers` WHERE `fb_id` = "'. $fb_id .'";';
			if (mysql_num_rows(mysql_query($query)) > 0) {			
				$participant_obj = mysql_fetch_object(mysql_query($query));
				$participant_id = $participant_obj->id;
				$participant_name = $participant_obj->username;
				$device_token = $participantr_obj->device_token;
				$isPush = ($participant_obj->notifications == "Y");
				$status_id = 3;
				
			} else {
				$query = 'SELECT `id` FROM `tblInvitedUsers` WHERE `fb_id` = "'. $fb_id .'";';
				if (mysql_num_rows(mysql_query($query)) > 0)
					$participant_id = mysql_fetch_object(mysql_query($query))->id;
				
				else {
					$query = 'INSERT INTO `tblInvitedUsers` (';
					$query .= '`id`, `fb_id`, `username`, `added`) ';
					$query .= 'VALUES (NULL, "'. $fb_id .'", "'. $fb_name .'", NOW());';
					$participant_result = mysql_query($query);
					$participant_id = mysql_insert_id();
				}
				
				$participant_name = $fb_name;
				$isPush = false;
				$status_id = 2;
			}
			
			if ($isPush) {
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
				curl_setopt($ch, CURLOPT_USERPWD, "luPaeCF1Ry-H2Slh0Pef1w:dSycB-EmRHKYLAz971k2PQ"); // dev
				//curl_setopt($ch, CURLOPT_USERPWD, ":"); // live
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_POST, 1);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_name .' has started a #'. $subject_name .' chat with you!", "sound": "push_01.caf"}}');
			 	$res = curl_exec($ch);
				$err_no = curl_errno($ch);
				$err_msg = curl_error($ch);
				$header = curl_getinfo($ch);
				curl_close($ch);
			}
			
			$query = 'INSERT INTO `tblChats` (';
			$query .= '`id`, `creator_id`, `participant_id`, `subject_id`, `status_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $user_id .'", "'. $participant_id .'", "'. $subject_id .'", "'. $status_id .'", NOW());';
			$chat_result = mysql_query($query);
			$chat_id = mysql_insert_id();
			
			$query = 'INSERT INTO `tblChatEntries` (';
			$query .= '`id`, `chat_id`, `author_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $chat_id .'", "'. $user_id .'", NOW());';
			$entry_result = mysql_query($query);
			$entry_id = mysql_insert_id();
			
			$img_cnt = 0;
			$img_arr = array();
			foreach ($imgURL_arr as $key) {
				$query = 'INSERT INTO `tblChatImages` (';
				$query .= '`id`, `entry_id`, `sort`, `url`, `added`) ';
				$query .= 'VALUES (NULL, "'. $entry_id .'", "'. $img_cnt .'", "'. $key .'", NOW());';
				$img_result = mysql_query($query);
				$img_id = mysql_insert_id();
				
				array_push($img_arr, array(
					"sort" => $img_cnt,
					"url" => $key
				));
				
				$img_cnt++;
			}
			
			$query = 'SELECT `added` FROM `tblChats` WHERE `id` = '. $chat_id .';';
			$added = mysql_fetch_object(mysql_query($query))->added;
			
			$chat_arr = array(
				"id" => $chat_id, 
				"creator_id" => $user_id, 
				"creator_name" => $creator_name, 
				"participant_id" => $participant_id, 
				"participant_name" => $participant_name, 
				"subject_id" => $subject_id, 
				"subject_name" => $subject_name, 
				"status_id" => $status_id, 					
				"added" => $added
			);
			
			$this->sendResponse(200, json_encode($chat_arr));
			return (true);	
		}
				
		function submitRandomChat($user_id, $subject_name, $imgURLs) {
			$chat_arr = array();			
			$imgURL_arr = explode('|', $imgURLs);
			
			if ($subject_name == "")
				$subject_name = "N/A";
			
			$query = 'SELECT `id` FROM `tblSubjects` WHERE `title` = "'. $subject_name .'";';
			$result = mysql_query($query);
			
			if (mysql_num_rows($result) > 0) {
				$row = mysql_fetch_row($result);
				$subject_id = $row[0];
			
			} else {
				$query = 'INSERT INTO `tblSubjects` (';
				$query .= '`id`, `title`, `creator_id`, `added`) ';
				$query .= 'VALUES (NULL, "'. $subject_name .'", "'. $user_id .'", NOW());';
				$subject_result = mysql_query($query);
				$subject_id = mysql_insert_id();
			}
			
			$query = 'SELECT `username` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_name = mysql_fetch_object(mysql_query($query))->username;
			
			$rndUser_id = $user_id;
			while ($rndUser_id == $user_id) {
				$range_result = mysql_query("SELECT MAX(`id`) AS max_id, MIN(`id`) AS min_id, `username` FROM `tblUsers`");
				$range_row = mysql_fetch_object($range_result); 
				$rndUser_id = mt_rand(2, $range_row->max_id);
				
				if (mysql_num_rows(mysql_query('SELECT `id` FROM `tblUsers` WHERE `id` = '. $rndUser_id .';')) == 0)
					$rndUser_id = $user_id;
					
				if (substr($range_row->username, 0, 7) == "PicChat")
					$rndUser_id = $user_id;				   
			}
			
			$query = 'SELECT `id`, `username`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = "'. $rndUser_id .'";';			
			$participant_obj = mysql_fetch_object(mysql_query($query));
			$participant_id = $participant_obj->id;
			$participant_name = $participant_obj->username;
			$device_token = $participantr_obj->device_token;
			$isPush = ($participant_obj->notifications == "Y");
			$status_id = 3;
				
			if ($isPush) {
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
				curl_setopt($ch, CURLOPT_USERPWD, "luPaeCF1Ry-H2Slh0Pef1w:dSycB-EmRHKYLAz971k2PQ"); // dev
				//curl_setopt($ch, CURLOPT_USERPWD, ":"); // live
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_POST, 1);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_name .' has started a #'. $subject_name .' chat with you!", "sound": "push_01.caf"}}');
			 	$res = curl_exec($ch);
				$err_no = curl_errno($ch);
				$err_msg = curl_error($ch);
				$header = curl_getinfo($ch);
				curl_close($ch);
			}
			
			$query = 'INSERT INTO `tblChats` (';
			$query .= '`id`, `creator_id`, `participant_id`, `subject_id`, `status_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $user_id .'", "'. $participant_id .'", "'. $subject_id .'", "'. $status_id .'", NOW());';
			$chat_result = mysql_query($query);
			$chat_id = mysql_insert_id();
			
			$query = 'INSERT INTO `tblChatEntries` (';
			$query .= '`id`, `chat_id`, `author_id`, `added`) ';
			$query .= 'VALUES (NULL, "'. $chat_id .'", "'. $user_id .'", NOW());';
			$entry_result = mysql_query($query);
			$entry_id = mysql_insert_id();
			
			$img_cnt = 0;
			$img_arr = array();
			foreach ($imgURL_arr as $key) {
				$query = 'INSERT INTO `tblChatImages` (';
				$query .= '`id`, `entry_id`, `sort`, `url`, `added`) ';
				$query .= 'VALUES (NULL, "'. $entry_id .'", "'. $img_cnt .'", "'. $key .'", NOW());';
				$img_result = mysql_query($query);
				$img_id = mysql_insert_id();
				
				array_push($img_arr, array(
					"sort" => $img_cnt,
					"url" => $key
				));
				
				$img_cnt++;
			}
			
			$query = 'SELECT `added` FROM `tblChats` WHERE `id` = '. $chat_id .';';
			$added = mysql_fetch_object(mysql_query($query))->added;
			
			$chat_arr = array(
				"id" => $chat_id, 
				"creator_id" => $user_id, 
				"creator_name" => $creator_name, 
				"participant_id" => $participant_id, 
				"participant_name" => $participant_name, 
				"subject_id" => $subject_id, 
				"subject_name" => $subject_name, 
				"status_id" => $status_id, 					
				"added" => $added
			);
			
			$this->sendResponse(200, json_encode($chat_arr));
			return (true);
		}
		
		
		
	    
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$chats = new Chats;
	////$chats->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['userID']))
					$chats->chatsForUser($_POST['userID']);
				break;
				
			case "2":
				if (isset($_POST['userID']) && isset($_POST['fbID']) && isset($_POST['fbName']) && isset($_POST['subject']) && isset($_POST['imgURLs']))
					$chats->submitNewChat($_POST['userID'], $_POST['fbID'], $_POST['fbName'], $_POST['subject'], $_POST['imgURLs']);
				break;
				
			case "3":
				if (isset($_POST['userID']) && isset($_POST['subject']) && isset($_POST['imgURLs']))
					$chats->submitRandomChat($_POST['userID'], $_POST['subject'], $_POST['imgURLs']);
				break;
    	}
	}
?>