<?php

class WorkflowItem extends DataObject {
	
	public static $db = array(
	  "name"=>"String", 
	  "link"=>"String",
	  "priority"=>'Int',
	  "action"=>"String",
	  "tooltip"=>"String",
	  "xPos"=>"Text",
	  "yPos"=>"Text",
	  "showOnHome"=>"Text",
	  "module"=>"Text"
	);
	
	public static $has_one = array(
	  "category"=>"WorkflowCategory",
	  "image"=>"Image"
	);
	
	public static $has_many = array(
	  "links"=>"WorkflowLink",
	  "contextMenuItems"=>"ContextMenuItem"
	);
	
}

?>
