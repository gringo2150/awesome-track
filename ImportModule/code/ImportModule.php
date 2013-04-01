<?php

class ImportModule extends WorkflowCategory {
	
	public static $db = array(  
		
	);
	
	public static $has_one = array(

	);
	
	public static $has_many = array(

	);
	
	public function onBeforeWrite() {
		
		parent::onBeforeWrite();
	}
	
	//Returns the tempate required for the center panel, for this module to work.
	public function getTemplate() {
		$module = $this->renderWith(array('ImportModule'));
		return $module;
	}
	
	//Returns the navigation code required to structure the handlers for the left
	//navigation buttons.
	public function getNavigation() {
		$title = $this->name ? $this->name : "ImportModule";
		return "
			ImportModule.show();
			Ext.getCmp('ImportModule_Center').setTitle('{$title}');
		";
	}
	
	public function moduleAddScreen() {
		$addForm = $this->renderWith(array('ImportModule_Add'));
		return $addForm;
	}
	
	public function moduleEditScreen() {
	}
	
}

class ImportModule_Controller extends Controller {

	static $URLSegment = 'importer';
	
	public function preview() {
		$fh = fopen($_FILES["file"]["tmp_name"], "r");
   		$tmpLines = array();
   		$i = 0;
   		while ($line = fgetcsv($fh)) {
			$tmpLine = array();
			if($i != 0) {
				for($j=0; $j < count($line); $j++) {
					$tmpLine[$tmpLines[0][$j]] = $line[$j];
				}
			} else {
				for($j=0; $j < count($line); $j++) {
					$tmpLine[$j] = $line[$j];
				}
			}
			$i++;
			$tmpLines[] = $tmpLine;
		}
		
		$fields = array();
		foreach($tmpLines[0] as  $field) {
			$fields[] = array('name'=>$field, 'type'=>'string');
		}
		$fields = Convert::array2json($fields);
		$metaData = "
				\"root\": \"rows\",
				\"totalProperty\": \"results\",
				\"successProperty\": \"success\",
				\"fields\": {$fields}
			";
		$columnModel = array();
		foreach($tmpLines[0] as  $column) {
			$columnModel[] = array('header'=>$column, 'dataIndex'=>$column, 'objectMapping'=>'');
		}
		$columnModel = Convert::array2json($columnModel);
		unset($tmpLines[0]);
		$lines = array();
		for($i=1; $i <= count($tmpLines); $i++) {
			$lines[] = $tmpLines[$i];
		}
		$results = count($lines);
		$rows = Convert::array2json($lines);
		$result = "{
			\"results\":  \"{$results}\",
			\"rows\": {$rows},
			\"metaData\":{
				{$metaData}
			},
			\"columnModel\": {$columnModel}
		}";
		return $result;
	}

	public function importCSV() {
		set_time_limit(0);
		$objectName  = isset($_POST['object']) ? $_POST['object'] : null;
		$headers  = isset($_POST['headers']) ? json_decode($_POST['headers']) : array();
		$rows = isset($_POST['rows']) ? json_decode($_POST['rows'], true) : array();
		if($objectName != null) {
			foreach($rows as $row) {
				$this->processJsonData($objectName, $row, true);
			}
			$results = count($rows);
			$bck = json_encode($rows);
			return "{\"success\": 1, \"data\":{$bck}, \"msg\":\"Successfully loaded {$results} records into the system for object {$objectName}\"}";
		}
	}
	
	function processJsonData($obj=null, $jsonData=null, $top=false) {
		// pre-processing checks...
		if ($jsonData == null) return '{"success":0, "msg":"Unable to create data object, json_data missing or not recognised"}';
		if ($obj == null) return '{"success":0, "msg":"Unable to create data object, classname not specified"}';
		if (!class_exists($obj)) return '{"success":0, "msg":"Unable to create data object, invalid classname specified"}';
		$Object = null;
		if (isset($jsonData['ID']) && is_numeric($jsonData['ID'])) {
			// ID passed so update existing object..
			$Object = DataObject::get_by_id($obj, (int)$jsonData['ID']);
		} else {
			// No ID passed so create new object...
			$Object = Object::create($obj);
		}
		$db = $Object->db();
		$has_one = $Object->has_one();
		$has_many = $Object->has_many();
		// loop through each item, check if its a db, has_one or has_many property and process accordingly...
		foreach ($jsonData as $Key => $Value) {
			if (substr($Key, -2) == "ID" && is_numeric($Value)) {
				// id field of a has_one so set blindly
				$Object->$Key = (int)$Value;
			} else if (isset($db[$Key])) {
				// db value so write value straight to the property...
				$Object->$Key = $Value;
			} else if (isset($has_one[$Key])) {
				// has_one value which means value is an object, process via reccursion..
				$field = $Key . "ID";
				// check if the sub-object already exists and if so set it's ID so that the existing sub-object
				// is updated rather than a new one being created.
				if ($Object->$field > 0) $Value['ID'] = $Object->$Key()->ID;
				$SubObject = $this->processJsonData($has_one[$Key], $Value);
				// check the returned value is not a string, as this indicates an error.
				if (!is_string($SubObject)) $Object->$field = $SubObject->ID;
			} else if (isset($has_many[$Key])) {
				// has_many value which means value is an array of objects, process via reccursion..
				// check if this main Object has an ID yet, if not, write it to the db to get an ID...
				if (!$Object->ID) $Object->write();
				// check the sub objects are of a valid class, and that they have a has_one relationship
				// with this parent object...
				$tempSO = Object::create($has_many[$Key]);
				if ($tempSO) {
					$so_has_one = array_flip($tempSO->has_one());
					if (isset($so_has_one[$Object->ClassName])) {
						// loop through each sub object, create / update via reccursion, find it's relation to this current parent object
						// and update it's ID accordingly.
						foreach ($Value as $subObj) {						
							$SubObject = $this->processJsonData($has_many[$Key], $subObj);
							// check the returned value is not a string, as this indicates an error.
							if (!is_string($SubObject)) {
								$soField = $so_has_one[$Object->ClassName] . "ID";
								$SubObject->$soField = $Object->ID;
								$SubObject->write();
							}
						}
					}
				}
			}
		}
		// If this is the top level object, check for any files being submitted for the has_one's and update accordingly.
		if ($top == true) {
			foreach($_FILES as $Fkey=>$Fvalue) {
				$IDkey = $Fkey.'ID';
				if(isset($has_one[$Fkey])) {
					if($has_one[$Fkey] == 'Image' || $has_one[$Fkey] == 'File') {
						if($Object->$IDkey < 1) {
							$Fobject = Object::create($has_one[$Fkey]);
						} else {
							$Fobject = DataObject::get_by_id($has_one[$Fkey], (int)$Object->$IDkey);
							if($_FILES[$Fkey]['tmp_name'] != '') {
								$Fobject->delete();
								$Fobject = Object::create($has_one[$Fkey]);
							}
						}
						$file_path = "../assets/Uploads/";
						$fileName = basename(md5(time())."_".str_replace(" ", "_", $_FILES[$Fkey]['name']));
						$file_path = $file_path . $fileName; 
						if(move_uploaded_file($_FILES[$Fkey]['tmp_name'], $file_path)) {
							$Fobject->Name = $fileName;
							$Fobject->Title = $fileName;
							$Fobject->Filename = $file_path;
							$Fobject->ParentID = 1;
							$Fobject->OwnerID = 0;
						}
						$Fobject->write();
						$Object->$IDkey = $Fobject->ID;
						unset($_FILES[$Fkey]);
					}
				}
			}
		}
		$Object->write();
		// return currently processed object so we can use it's ID to apply to has_one's when using reccursion.
		// if this is the top level object, return a success message instead...
		if ($top) {
			$message = (isset($jsonData['ID']) && is_numeric($jsonData['ID'])) ? "Data updated successfully" : "Data saved successfully";
			$RtnID = $Object->ID;
			$f = new JSONDataFormatter();
			$json = $f->convertDataObject($Object);
			return '{"success":1, "message":"'.$message.'", "data":{"ID":"'.$RtnID.'", "rows":['.$json.']}}';
		} else {
			return $Object;
		}
	}
	
	public function CSVHeaders() {
		//Update this to keep a list of objects we have already been over, dont want to repeat ourselves...
		$objectName = $this->urlParams['ID'];
		if($object = Object::create($objectName)) {
			$db = $object->db();
			$has_one = $object->has_one();
			$headers = array();
			$headers[] = 'ID';
			$headers[] = 'Created';
			foreach($db as $key=>$value) {
				$headers[] = $key;
			}
			foreach($has_one as $hKey=>$hValue) {
				if($hObj = Object::create($hValue)) {
					$headers[] = $hKey.'ID';
					if($hDb = $hObj->db()) {
						foreach($hDb as $sKey=>$sValue) {
							$headers[] = "{$hKey}.{$sKey}";
						}
					}
				}
			}
			$bck = json_encode($headers);
			return "{\"success\": true, \"data\":{$bck}, \"msg\":\"Headers have been successfully loaded.\"}";
		} else {
			return "{\"success\": false, \"data\":[], \"msg\":\"There was a problem loading the required\nheader information for object {$objectName}\"}";
		}
	}
	
	public function CSVHeadersExcel() {
		$objectName = $this->urlParams['ID'];
		if($object = Object::create($objectName)) {
			$db = $object->db();
			$has_one = $object->has_one();
			
			$headers = array();
			foreach($db as $key=>$value) {
				$headers[] = $key;
			}
			foreach($has_one as $hKey=>$hValue) {
				if($hObj = Object::create($hValue)) {
					if($hDb = $hObj->db()) {
						foreach($hDb as $sKey=>$sValue) {
							$headers[] = "{$hKey}.{$sKey}";
						}
					}
				}
			}
			$bck = json_encode($headers);
			return "{\"success\": true, \"data\":{$bck}}";
		} else {
			return "{\"success\": false, \"data\":[]}";
		}
	}


}

?>
