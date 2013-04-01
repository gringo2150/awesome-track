<?php

class ReportItem extends DataObject {
	
	public static $db = array(  
		"ReportName"=>"Text",
		"ReportGroup"=>"Text",
		"ReportType"=>"Text",
		"EmailTo"=>"Text",
		"EmailFrom"=>"Text",
		"EmailSubject"=>"Text",
		"EmailBody"=>"HTMLText",
		"EmailToField"=>"Text",
		"EmailSubjectField"=>"Text"
	);
	
	public static $has_one = array(
		"ReportModule"=>"ReportModule",
		"Query"=>"SavedQuery",
		"Template"=>"Template"
		//Action, new class not written yet works with system events etc.
	);
	
	public static $has_many = array(

	);
	
	
}

?>
