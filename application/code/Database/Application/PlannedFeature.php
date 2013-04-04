<?php

class PlannedFeature extends DataObject {

	public static $db = array(
		'Name'=>'Varchar(50)',
		'Descrip'=>'Text',
		'EstCost'=>'Float',
		'EstDays'=>'Int',
		'DueDate'=>'Date',
		'Quoted'=>'Boolean',
		'Approved'=>'Boolean',
		'Included'=>'Boolean'
	);
	
	public static $has_one = array(
		'Project'=>'Project',
		'Milestone'=>'Milestone',
		'Feature'=>'Feature'
	);
	
	public static $has_many = array(
	);
	
	public static $columnModel = array(
		/* Header, DataIndex, Width, Renderer, CanSearch, IncSearch, Hidden */
		array("ID","ID","20","","true","false","true"),
		array("Name","Name","","","true","true","false"),
		array("Quoted","Quoted","","booleanRender","false","false","false"),
		array("Est Cost","EstCost","","","false","false","false"),
		array("Est Days","EstDays","","","false","false","false"),
		array("Approved","Approved","","booleanRender","false","false","false"),
		array("Included","Included","","booleanRender","false","false","false")
	);
}

?>