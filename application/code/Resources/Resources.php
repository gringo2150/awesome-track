<?php

class Resources_Controller extends Controller {
	
	public static function importWorkflows($path) {
		$output = '';
		$handle = opendir($path);
		$ignore = array( 'cgi-bin', '.', '..' ); 
		while (false !== ($file = readdir($handle))){
			if( !in_array( $file, $ignore ) ){
				if( is_dir( "$path/$file" ) ){
					$output .= Resources_Controller::importWorkflows("$path/$file");
				} else {
	  				$extension = strtolower(substr(strrchr($file, '.'), 1));
	  				if($extension == 'js'){
						$output .= file_get_contents("$path/$file");
	  				}
	  			}
	  		}
		}
		return $output;
	}
	
	function index($url) {
		require 'thirdparty/jsmin/jsmin.php';
		$scriptData = Resources_Controller::importWorkflows('../application/javascript/workflows/');
		ContentNegotiator::disable();
		$this->getResponse()->addHeader('Content-Type', 'text/javascript; charset="utf-8"');
		return JSMin::minify($scriptData);
		//return $scriptData;
	}
	
	
	
}

?>
