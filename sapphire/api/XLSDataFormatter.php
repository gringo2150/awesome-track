<?php
/**
 * @package sapphire
 * @subpackage formatters
 */
 
class XLSDataFormatter extends DataFormatter {
	
	public function supportedExtensions() {
		return array(
			'htm',
			'html'
		);
	}

	public function supportedMimeTypes() {
		return array(
			'application/html', 
			'text/html'
		);
	}
	
	/**
	 * Returns a single HTML table row representation of the given object
	 */
	public function convertDataObject(DataObjectInterface $obj, $fields = null, $row = 0, $relations = null) {
		if(isset($obj->class)) {
			$className = $obj->class;
			$id = $obj->ID;
			$output = "";
			//Setting small icons if an Image
			if($className == 'Image') {
				if($smallImg = $obj->setSize(16,16)) {
					$obj->Filename = $smallImg->URL;
				}
			}
			$html = "<tr id= \"{$className}_{$id}\">\n";
			$num = 0;
			if ($fields) {
				foreach($fields as $field) {
					if (strpos($field, ".") === false) {
						$html .= "<td>{$obj->$field}</td>\n";
						//if (is_numeric($obj->$field)) {
							//$output .= $this->xlsWriteNumber($row,$num,$obj->$field);
						//} else {
							$output .= $this->xlsWriteLabel($row,$num,$obj->$field);
						//}
						$num++;
					} else {
						$html .= "<td>{$this->findRelationValue($obj, $field)}</td>\n";
						$output .= $this->xlsWriteLabel($row,$num,$this->findRelationValue($obj, $field));
						$num++;
					}
				}
			} else {
				foreach($this->getFieldsForObj($obj) as $fieldName => $fieldType) {
					$html .= "<td>{$obj->$fieldName}</td>\n";
					$output .= $this->xlsWriteLabel($row,$num,$obj->$fieldName);
					$num++;
				}
			}
			$html .= "</tr>\n";
			//return $html;
			return $output;
		} else {
			return null;
		}
	}

	/**
	 * Returns a full HTML table representation of the given dataObject Set and saves it as an xls file.
	 */
	public function convertDataObjectSet(DataObjectSet $set, $fields = null, $metaData = '') {
		if ($set) {
			$table = "<table>\n";
			//$table .= $this->getTableHeaders($set->First(), $fields);
			$output = $this->xlsBOF();
			$output .= $this->getTableHeaders($set->First(), $fields);
			$rownum = 2;
			foreach ($set as $do) {
				//$table .= $this->convertDataObject($do, $fields);
				$output .= $this->convertDataObject($do, $fields, $rownum);
				$rownum++;
			}
			$table .= "</table>";
			$output .= $this->xlsEOF();
			//return $table;
			return $output;
		} else {
			return null;
		}
	}
	
	public function getTableHeaders($obj, $fields = null) {
		if(isset($obj->class)) {
			$className = $obj->class;
			$id = $obj->ID;			
			$html = "<tr id= \"{$className}_{$id}\">\n";
			$output = "";
			$num = 0;
			if ($fields) {
				foreach($fields as $field) {
					$html .= "<td><strong>{$field}</strong></td>\n";
					$output .= $this->xlsWriteLabel(0,$num,$field);
					$num++;
				}
			} else {
				foreach($this->getFieldsForObj($obj) as $fieldName => $fieldType) {
					$html .= "<td><strong>{$fieldName}</strong></td>\n";
					$output .= $this->xlsWriteLabel(0,$num,$fieldName);
					$num++;
				}
			}
			$html .= "</tr>\n";
			//return $html;
			return $output;
		} else {
			return null;
		}
	}
	
	public function findRelationValue($obj, $field) {
		$parts = explode(".", $field);
		$ho = $obj->has_one();
		$class = '';
		$idField = $parts[0] . 'ID';
		foreach($ho as $hKey=>$hValue) {
			if($hKey == $parts[0]) {
				$class = $hValue;
				break;
			}
		}
		if ($subObj = DataObject::get_by_id($class, $obj->$idField)) {
			return $subObj->$parts[1];
		} else {
			return "";
		}
	}
	
	function xlsBOF() {
		return pack("ssssss", 0x809, 0x8, 0x0, 0x10, 0x0, 0x0);  
	}

	function xlsEOF() {
		return pack("ss", 0x0A, 0x00);
	}

	function xlsWriteNumber($Row, $Col, $Value) {
		return pack("sssss", 0x203, 14, $Row, $Col, 0x0) . pack("d", $Value);
	}

	function xlsWriteLabel($Row, $Col, $Value ) {
		$L = strlen($Value);
		return pack("ssssss", 0x204, 8 + $L, $Row, $Col, 0x0, $L) . $Value;
	} 
	
}
