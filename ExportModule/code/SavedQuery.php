<?php

class SavedQuery extends DataObject {
	
	public static $db = array(  
		"name"=>"Text",
		"columns"=>"Text",
		"tables"=>"Text",
		"joins"=>"Text",
		"sorts"=>"Text",
		"show"=>"Text",
		"conditions"=>"Text"
	);
	
	public static $has_one = array(

	);
	
	public static $has_many = array(

	);
	
	public function runQuery() {
		$data = $_POST;
		if($member = Member::currentUser()){
			$select = json_decode($this->columns);
			$sqlQuery = new SQLQuery();
			$selAs = array();
			foreach($select as $column) {
				$asColumn = str_replace('.', '_', $column);
				$selAs[] = "{$column} AS '{$asColumn}'";
			}
			$sqlQuery->select = $selAs;
			$from = array();
			foreach(json_decode($this->tables) as $key=>$value) {
				$from[] = $key;
			}
			foreach(json_decode($this->joins) as $join) {
				$from[] = "{$join->direction} JOIN {$join->tableTo} ON {$join->tableFrom}.{$join->fieldFrom}={$join->tableTo}.{$join->fieldTo}";
			}
			$sqlQuery->from = $from;
			$conditions = json_decode($this->conditions);
			$sqlQuery->where = $conditions;
			$orderBy = json_decode($this->sorts);
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
				$hidden = (json_decode($this->show)->$column == 'true') ? false : true;
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
	
}

?>
