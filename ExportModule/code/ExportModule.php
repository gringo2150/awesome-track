<?php

class ExportModule extends WorkflowCategory {
	
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
		$module = $this->renderWith(array('ExportModule'));
		return $module;
	}
	
	//Returns the navigation code required to structure the handlers for the left
	//navigation buttons.
	public function getNavigation() {
		$title = $this->name ? $this->name : "ExportModule";
		return "
			Ext.getCmp('ExportModule').show();
			Ext.getCmp('ExportModule_North').setTitle('{$title}');
		";
	}
	
	public function moduleAddScreen() {
		$addForm = $this->renderWith(array('ExportModule_Add'));
		return $addForm;
	}
	
	public function moduleEditScreen() {
	}
	
}

class ExportModule_Controller extends Controller {

	static $URLSegment = 'exporter';

	public function listObjectDB() {
		//Update this to keep a list of objects we have already been over, dont want to repeat ourselves...
		$objectName = $this->urlParams['ID'];
		if($object = Object::create($objectName)) {
			$db = $object->db();
			$has_one = $object->has_one();
			$headers = array();
			$headers[] = array('fieldName'=>'ID', 'tableName'=>$objectName, 'primaryKey'=>true, 'key'=>true, 'joinObject'=>$objectName);
			//$headers[] = array('fieldName'=>'Created', 'tableName'=>$objectName, 'primaryKey'=>false, 'key'=>false, 'joinObject'=>$objectName);
			foreach($db as $key=>$value) {
				$headers[] = array('fieldName'=>$key, 'tableName'=>$objectName, 'primaryKey'=>false, 'key'=>false, 'joinObject'=>$objectName);
			}
			foreach($has_one as $hKey=>$hValue) {
				$headers[] = array('fieldName'=>$hKey.'ID', 'tableName'=>$objectName, 'primaryKey'=>false, 'key'=>true, 'joinObject'=>$hValue);
			}
			$bck = json_encode($headers);
			return "{\"success\": true, \"data\":{$bck}, \"msg\":\"Headers have been successfully loaded.\"}";
		} else {
			return "{\"success\": false, \"data\":[], \"msg\":\"There was a problem loading the required\nheader information for object {$objectName}\"}";
		}
	}
	
	public function runQuery() {
		$data = $_POST;
		if($member = Member::currentUser()){
			$select = json_decode($data['columns']);
			$sqlQuery = new SQLQuery();
			$selAs = array();
			foreach($select as $column) {
				$asColumn = str_replace('.', '_', $column);
				$selAs[] = "{$column} AS '{$asColumn}'";
			}
			$sqlQuery->select = $selAs;
			$from = array();
			foreach(json_decode($data['tables']) as $key=>$value) {
				$from[] = $key;
			}
			foreach(json_decode($data['joins']) as $join) {
				$from[] = "{$join->direction} JOIN {$join->tableTo} ON {$join->tableFrom}.{$join->fieldFrom}={$join->tableTo}.{$join->fieldTo}";
			}
			$sqlQuery->from = $from;
			$conditions = json_decode($data['query']);
			$sqlQuery->where = $conditions;
			$orderBy = json_decode($data['sorts']);
			$sqlQuery->orderby = implode(', ', $orderBy);
			$qResult = $sqlQuery->execute();
			$lines = array();
			foreach ($qResult as $row) {
				$tmpRow = array();
				foreach($row as $key=>$value) {
					$tmpRow[$key] = $value;
				}
				$lines[] = $tmpRow;
			}
			$rows = json_encode($lines);
			$sqlSelect = implode(', ',$select);
			$sqlFrom = implode(', ',$from);
			$sqlConditions = implode(', ', $conditions);
			$sqlOrderBy = implode(', ', $orderBy);
			$sql = "SELECT {$sqlSelect} FROM {$sqlFrom} WHERE({$sqlConditions}) ORDER BY {$sqlOrderBy}";
			
			$fields = array();
			foreach($select as  $field) {
				$asColumn = str_replace('.', '_', $field);
				$fields[] = array('name'=>$asColumn, 'type'=>'string');
			}
			$fields = Convert::array2json($fields);
			$metaData = "
				\"root\": \"rows\",
				\"totalProperty\": \"results\",
				\"successProperty\": \"success\",
				\"fields\": {$fields}
			";
			$columnModel = array();
			foreach($select as  $column) {
				$asColumn = str_replace('.', '_', $column);
				$headerColumn = str_replace('.', ' ', $column);
				$hidden = (json_decode($data['show'])->$column == 'true') ? false : true;
				$columnModel[] = array('header'=>$headerColumn, 'dataIndex'=>$asColumn, 'hidden'=>$hidden);
			}
			$columnModel = Convert::array2json($columnModel);
			$results = count($lines);
			$rows = Convert::array2json($lines);
			$result = "{
				\"results\":  \"{$results}\",
				\"rows\": {$rows},
				\"metaData\":{
					{$metaData}
				},
				\"success\": true,
				\"columnModel\": {$columnModel},
				\"sql\":\"{$sql}\"
			}";
			return $result;
		}
		else {
			return null;
		}	
	}
	
	public function saveQuery() {
		$data = $_POST;
		if($member = Member::currentUser()){
			if($query = new SavedQuery()) {
				$query->name = $data['name'];
				$query->columns = $data['columns'];
				$query->tables = $data['tables'];
				$query->joins = $data['joins'];
				$query->sorts = $data['sorts'];
				$query->show = $data['show'];
				$query->conditions = $data['query'];
				$query->write();
				return "{\"success\": true, \"msg\":\"The query has been save in the query store.\", \"data\":[]}";
			}
		} else {
		}
	}

}

?>
