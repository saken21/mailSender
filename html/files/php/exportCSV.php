<?php

	if ($_POST) exportCSV($_POST);
	
	function exportCSV($data) {
		
		$string = $data['data'];
		$file   = fopen('csv/'.$data['filename'],'w');
		
		fwrite($file,$string);
		fclose($file);
		
		echo('success');
		
	}

?>