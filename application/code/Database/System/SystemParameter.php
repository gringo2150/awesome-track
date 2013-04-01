<?php

class SystemParameter extends DataObject {
	
	public static $db = array(
	  "name" => "String", 
	  "value" => "String"
	);
	
	public static $has_one = array(
	);
	
	public static $has_many = array(
	);
	
	public static $columnModel = array(
		/* Header, DataIndex, Width, Renderer, CanSearch, IncSearch, Hidden */
		array("ID","ID","20","","true","false","true"),
		array("Property","name","","","true","true","false"),
		array("Value","value","","","true","true","false")
	);
	
}

?>
