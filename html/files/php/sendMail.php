<?php
	
	mb_language('Japanese');
	mb_internal_encoding('UTF-8');
	
	$staffMail = $_POST['staffMail'];
	$to        = $_POST['to'];
	$subject   = $_POST['subject'];
	$body      = $_POST['body'];
	
	$reply   = $staffMail;
	$headers = 'From: '.mb_encode_mimeheader('株式会社グラフィック '.$_POST['staffFullname']).'<'.$staffMail.'>'."\r\n".'Reply-To: '.$reply;

	$isSuccess = mb_send_mail($to,$subject,$body,$headers);
	echo($isSuccess);

?>