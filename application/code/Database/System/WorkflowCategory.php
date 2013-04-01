<?php

class WorkflowCategory extends DataObject {
	
	public static $db = array(  
	  "name" => "String",
	  "priority"=>'Int',
	  "action"=>"String",
	  "xPos"=>"Text",
	  "yPos"=>"Text",
	  "showOnHome"=>"Text",
	  "module"=>"Text",
	  "showOnMenu"=>"Text"
	);
	
	public static $has_one = array(
	  "image" => "Image"
	);
	
	public static $has_many = array(
	  "workflowItems" => "WorkflowItem",
	  "contextMenuItems"=>"ContextMenuItem"
	);
	
}

?>
