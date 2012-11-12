<?php

	class ChatEntries {
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
	    
		
		function entriesForChat($chat_id) {
			$entries_arr = array();
			
			$query = 'SELECT * FROM `tblChatEntries` WHERE `chat_id` = '. $chat_id .' ORDER BY `added`;';
			$entry_result = mysql_query($query);
						
			while ($entry_row = mysql_fetch_array($entry_result, MYSQL_BOTH)) {
				$query = 'SELECT `creator_id`, `participant_id` FROM `tblChats` WHERE `id` = '. $chat_id .';';
				$chat_obj = mysql_fetch_object(mysql_query($query));
				
				if ($entry_row['author_id'] == $chat_obj->creator_id) {
				    $author_id = $chat_obj->creator_id;
					$sendTo_id = $chat_obj->participant_id;
					
				} else {
					$author_id = $chat_obj->participant_id;
					$sendTo_id = $chat_obj->creator_id;
				}
								
				
				$query = 'SELECT `username`, `fb_id` FROM `tblUsers` WHERE `id` = '. $author_id .';';
				$creator_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `username`, `fb_id` FROM `tblUsers` WHERE `id` = '. $sendTo_id .';';
				$sendTo_obj = mysql_fetch_object(mysql_query($query));
				
				$query = 'SELECT `sort`, `url` FROM `tblChatImages` WHERE `entry_id` = '. $entry_row['id'] .' ORDER BY `sort`;';
				$img_result = mysql_query($query);
				
				$img_arr = array();
				while ($img_row = mysql_fetch_array($img_result, MYSQL_BOTH)) {
					array_push($img_arr, array(
						"sort" => $img_row['sort'], 
						"url" => $img_row['url']
					));
				}
					
				array_push($entries_arr, array(
					"id" => $entry_row['id'], 
					"author_id" => $author_id, 
					"author_name" => $creator_obj->username, 
					"author_fb" => $creator_obj->fb_id, 
					"participant_id" => $sendTo_id, 
					"participant_name" => $sendTo_obj->username, 
					"participant_fb" => $sendTo_obj->fb_id, 
					"images" => $img_arr, 
					"added" => $entry_row['added']
				));
			}			
			
			$this->sendResponse(200, json_encode($entries_arr));
			return (true);	
		}
		
		function submitChatEntry($user_id, $chat_id, $imgURLs) {			
			//echo ("1->\n");//;
			
			$entry_arr = array();			
			$imgURL_arr = explode('|', $imgURLs);

			$query = 'SELECT * FROM `tblChats` WHERE `id` = '. $chat_id .';';
			$chat_obj = mysql_fetch_object(mysql_query($query));

			$query = 'SELECT `title` FROM `tblSubjects` WHERE `id` = '. $chat_obj->subject_id .';';
			$subject_name = mysql_fetch_object(mysql_query($query))->title;

			$query = 'SELECT `username`, `fb_id` FROM `tblUsers` WHERE `id` = '. $user_id .';';
			$creator_obj = mysql_fetch_object(mysql_query($query));
			$creator_name = $creator_obj->username;
			$creator_fb = $creator_obj->fb_id;

			if ($user_id == $chat_obj->creator_id)
				$sendTo_id = $chat_obj->participant_id;
			
			else
				$sendTo_id = $chat_obj->creator_id;
			

			$query = 'SELECT `id`, `username`, `fb_id`, `device_token`, `notifications` FROM `tblUsers` WHERE `id` = "'. $sendTo_id .'";';		  
			$participant_obj = mysql_fetch_object(mysql_query($query));
			$participant_id = $participant_obj->id;
			$participant_name = $participant_obj->username;
			$participant_fb = $participant_obj->fb_id;
			$device_token = $participant_obj->device_token;
			$isPush = ($participant_obj->notifications == "Y");
			
			if ($isPush) {
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, 'https://go.urbanairship.com/api/push/');
				curl_setopt($ch, CURLOPT_USERPWD, "luPaeCF1Ry-H2Slh0Pef1w:dSycB-EmRHKYLAz971k2PQ"); // dev
				//curl_setopt($ch, CURLOPT_USERPWD, "FfJLfQz7R4CoAx9sLG8fCw:20E-2r5pQu2ldjCkMPwVzQ"); // live
				curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				curl_setopt($ch, CURLOPT_POST, 1);
				curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["'. $device_token .'"], "type":"2", "aps": {"alert": "'. $creator_name .' has submitted to your #'. $subject_name .' chat!", "sound": "push_01.caf"}}');
			 	$res = curl_exec($ch);
				$err_no = curl_errno($ch);
				$err_msg = curl_error($ch);
				$header = curl_getinfo($ch);
				curl_close($ch);
			}
			
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
			
			$entry_arr = array(
				"id" => $entry_id, 
				"from_id" => $user_id, 
				"from_name" => $creator_name, 
				"from_fb" => $creator_fb, 
				"participant_id" => $participant_id, 
				"participant_name" => $participant_name, 
				"participant_fb" => $participant_fb, 
				"images" => $img_arr, 
				"added" => $added
			);
			
			$this->sendResponse(200, json_encode($entry_arr));
			return (true);	
		}
		
		
		
	    
		function test() {
			$this->sendResponse(200, json_encode(array(
				"result" => true
			)));
			return (true);	
		}
	}
	
	$chatEntries = new ChatEntries;
	//$chatEntries->test();
	
	
	if (isset($_POST['action'])) {
		switch ($_POST['action']) {
			
			case "0":
				break;
				
			case "1":
				if (isset($_POST['userID']) && isset($_POST['chatID']) && isset($_POST['imgURLs']))
					$chatEntries->submitChatEntry($_POST['userID'], $_POST['chatID'], $_POST['imgURLs']);
				break;
				
			case "2":
				if (isset($_POST['chatID']))
					$chatEntries->entriesForChat($_POST['chatID']);
				break;
				
			case "2":
				if (isset($_POST['chatID']) && isset($_POST['entryID']))
					$chatEntries->entryForChat($_POST['chatID'], $_POST['entryID']);
				break;
			
    	}
	}
?>