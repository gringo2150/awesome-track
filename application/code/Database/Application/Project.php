<?php

class Project extends DataObject {

	public static $db = array(
		'Name'=>'Varchar(60)',
		'Descrip'=>'HTMLText',
		'Progress'=>'Int'
	);
	
	public static $has_one = array(
	);
	
	public static $has_many = array(
		'Milestones'=>'Milestone',
		'Bugs'=>'Bug',
		'PlannedFeatures'=>'PlannedFeature'
	);
	
	public static $columnModel = array(
		/* Header, DataIndex, Width, Renderer, CanSearch, IncSearch, Hidden */
		array("ID","ID","20","","true","false","true"),
		array("Project Name","Name","","","true","true","false"),
		array("Progress","Progress","","","false","false","false")
	);

}

?>
