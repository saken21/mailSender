<?php

	$dir    = 'csv';
	$handle = opendir($dir);
	
	if ($handle) {
		
		while($filename = readdir($handle)) {
			
			if (!preg_match('/^\./',$filename)) {
				unlink($dir.'/'.$filename);
			}
			
		}
		
	}

?>