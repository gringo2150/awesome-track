<?php

class Bug extends DataObject {
	
	public static $db = array(
		'Name'=>'Varchar(50)',
		'Descrip'=>'Text',
		'ReportedDate'=>'Date',
		'Resolved'=>'Boolean',
		'ResolvedDate'=>'Date',
		'Tested'=>'Boolean',
		'TestedDate'=>'Date',
		'Development'=>'Boolean',
		'Beta'=>'Boolean',
		'Demo'=>'Boolean',
		'Live'=>'Boolean'
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
		array("Resolved","Resolved","","booleanRender","false","false","false"),
		array("Tested","Tested","","booleanRender","false","false","false"),
		array("Dev","Development","","booleanRender","false","false","false"),
		array("Beta","Beta","","booleanRender","false","false","false"),
		array("Demo","Demo","","booleanRender","false","false","false"),
		array("Live","Live","","booleanRender","false","false","false")
	);
	
}

?>