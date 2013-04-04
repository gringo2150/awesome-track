<?php

class Milestone extends DataObject {

	public static $db = array(
		'Name'=>'Varchar(50)',
		'Descrip'=>'Text',
		'Progress'=>'Int', //Sudo Property, work out on the fly
		'DueDate'=>'Date',
		'Complete'=>'Boolean',
		'CompleteDate'=>'Date',
		'ProjectName'=>'Varchar(50)' //Sudo Property
	);
	
	public static $has_one = array(
		'Project'=>'Project',
		'ParentMilestone'=>'Milestone'
	);
	
	public static $has_many = array(
		'Milestones'=>'Milestone',
		'Features'=>'Feature',
		'Bugs'=>'Bug',
		'Tasks'=>'Task',
		'CheckLists'=>'CheckList'
	);
	
	public static $columnModel = array(
		/* Header, DataIndex, Width, Renderer, CanSearch, IncSearch, Hidden */
		array("ID","ID","20","","true","false","true"),
		array("Project Name","ProjectName","","","true","true","true"),
		array("Name","Name","","","true","true","false"),
		array("Due Date","DueDate","","","false","false","false"),
		array("Complete","Complete","","","false","false","false")
	);
	
	public function getProjectName() {
		if($this->ProjectID > 0) {
			return $this->Project()->Name;
		}
		return 'Unknown';
	}

}

?>