<?php

class Feature extends DataObject {

	public static $db = array(
		'Name'=>'Varchar(50)',
		'Descrip'=>'Text',
		'StartDate'=>'Date',
		'DueDate'=>'Date',
		'Cost'=>'Float',
		'Completed'=>'Boolean',
		'CompleteDate'=>'Date',
		'Tested'=>'Boolean',
		'TestedDate'=>'Date',
		'Development'=>'Boolean',
		'Beta'=>'Boolean',
		'Demo'=>'Boolean',
		'Live'=>'Boolean',
		'MilestoneName'=>'Varchar(50)' //Sudo Property
	);
	
	public static $has_one = array(
		'Milestone'=>'Milestone',
		'Project'=>'Project',
		'PlannedFeature'=>'PlannedFeature'
	);
	
	public static $has_many = array(
		'Bugs'=>'Bug'
	);
	
	public static $columnModel = array(
		/* Header, DataIndex, Width, Renderer, CanSearch, IncSearch, Hidden */
		array("ID","ID","20","","true","false","true"),
		array("Milestone Name","MilestoneName","","","false","false","true"),
		array("Name","Name","","","true","true","false"),
		array("Due Date","DueDate","","","false","false","false"),
		array("Complete","Completed","","booleanRender","false","false","false"),
		array("Tested","Tested","","booleanRender","false","false","false"),
		array("Dev","Development","","booleanRender","false","false","false"),
		array("Beta","Beta","","booleanRender","false","false","false"),
		array("Demo","Demo","","booleanRender","false","false","false"),
		array("Live","Live","","booleanRender","false","false","false")
	);
	
	public function getMilestoneName() {
		if($this->MilestoneID > 0) {
			return $this->Milestone()->Name;
		}
		return 'Unknown';
	}

}

?>