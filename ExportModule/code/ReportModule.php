<?php

class ReportModule extends WorkflowCategory {
	
	public static $db = array(  
	
	);
	
	public static $has_one = array(

	);
	
	public static $has_many = array(
		"ReportItems"=>"ReportItem"
	);
	
	public function onBeforeWrite() {
		
		parent::onBeforeWrite();
	}
	
	//Returns the tempate required for the center panel, for this module to work.
	public function getTemplate() {
		$module = $this->renderWith(array('ReportModule'));
		return $module;
	}
	
	//Returns the navigation code required to structure the handlers for the left
	//navigation buttons.
	public function getNavigation() {
		$title = $this->name ? $this->name : "ReportModule";
		return "
			Ext.getCmp('ReportModule').show();
			Ext.getCmp('ReportModule_Panel').setTitle('{$title}');
			ReportModule_Store.load();
		";
	}
	
	public function moduleAddScreen() {
		$addForm = $this->renderWith(array('ReportModule_Add'));
		return $addForm;
	}
	
	public function moduleEditScreen() {
	}
	
}

class ReportModule_Controller extends Controller {

	static $URLSegment = 'report';
	
	public function listReports() {
		if($reports = DataObject::get('ReportItem')) {
			$allData = array();
			foreach($reports as $report) {
				$tmpRow = array(
					"ReportName"=>$report->ReportName, 
					"ReportType"=>$report->ReportType,
					"Created"=>$report->Created,
					"ID"=>$report->ID,
					"QueryID"=>$report->QueryID
				);
				$allData[] = $tmpRow;
			}
			$reports = $reports->groupBy("ReportGroup");
			$groups = array();
			foreach($reports as $report=>$data) {
				$group = array();
				$group['groupName'] = $report;
				$group['groupData'] = array();
				$tmpRow = array();
				$rpts = DataObject::get('ReportItem', "ReportGroup='{$report}'");
				foreach($rpts as $rpt) {
					$tmpRow = array(
						"ReportName"=>$rpt->ReportName, 
						"ReportType"=>$rpt->ReportType,
						"Created"=>$rpt->Created,
						"ID"=>$rpt->ID
					);
					$group['groupData'][] = $tmpRow;
				}
				$groups[] = $group;
			}
			$grpData = json_encode($groups);
			$allGrpData = json_encode($allData);
			$count = count($groups);
			$json = "{
				\"data\":{$grpData},
				\"ungrouped\":{$allGrpData},
				\"results\":\"{$count}\",
				\"success\": true
				
			}";
			return $json;
		}
	}
	
	public function runReport() {
		$ID = $this->urlParams['ID'];
		if($report = DataObject::get_by_id('ReportItem', (int)$ID)) {
			if($report->ReportType == "Data") {
				$this->reportToExcel($report->Query()->runQuery());
			}
			if($report->ReportType == "Email") {
				return $this->reportToEmail($report);
			}
			if($report->ReportType == "Template") {
				return $this->reportToTemplate($report);
			}
		}
	}
		
	private function reportToExcel($report) {
		$report = json_decode($report);
		$output = $report->rows;
		$filename = '../assets/ExportedData/' . $this->ArrayToXLS($output, 'Report', $fields = null);
		header('Content-Description: File Transfer');
		header('Content-Type: application/octet-stream');
		header('Content-Disposition: attachment; filename="Report.xls"');
		header('Content-Transfer-Encoding: binary');
		header('Expires: 0');
		header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
		header('Pragma: public');
		header('Content-Length: ' . filesize($filename));
		ob_clean();
		flush();
		readfile($filename);
		exit;
	}
	
	private function reportToEmail($report) {
		$from = $report->EmailFrom;
		$body = $report->EmailBody;
		$runReport = $report->Query()->runQuery();
		$runReport = json_decode($runReport);
		foreach($runReport->rows as $row) {
			$newBody = $body;
			$toField = '';
			$subjectField = '';
			$emailData = array();
			foreach($row as $key=>$value) {
				$emailData[$key] = $value;
				if($report->EmailToField == $key) {
					$toField = $value;
				}
				if($report->EmailSubjectField == $key) {
					$subjectField = $value;
				}
			}
			$to = ($report->EmailTo != null || $report->EmailTo != '') ? $report->EmailTo : $toField;
			$subject = ($report->EmailSubject != null || $report->EmailSubject != '') ? $report->EmailSubject : $subjectField;
			$email = new Email($from, $to, $subject, $newBody);
			$email->populateTemplate($emailData);
			$email->send();
		} 
		return "{\"success\": true, \"msg\":\"Emails report has been run and sent.\"}";
	}
	
	private function reportToTemplate($report) {
		$templatePath = $report->Template()->file()->Filename;
		$runReport = $report->Query()->runQuery();
		$runReport = json_decode($runReport);
		$reports = array();
		foreach($runReport->rows as $row) {
			$p = new phpmswordparser;   
			$p->multi = false;       
			//echo $templatePath;      
			$p->setTemplateFile('../'.$templatePath); 
			$outputPath = '../assets/ExportedData/ReportTemplate'.md5(time()).'.docx';
			foreach($row as $key=>$value) {
				$p->addPlaceholder($key,$value);
			}
			$p->setOutputFile($outputPath);
			$ok = $p->createDocument(); 	
			if (!$ok) {
				print "ERR: ".$p->error;
				break;
			} else {
				$reports[] = $outputPath;
			}
			$p->reset();
		}                          
		$zip = new zipfile();
		$fileName = 'ReportBundle'.md5(time()).'.zip';
		$filePath = '../assets/ExportedData/'.$fileName;
		if(file_exists($filePath)) {
			unlink($filePath);
		}
		$i = 0;
		foreach($reports as $file) {
			$zip->addFile($data = implode('',file($file)), 'ReportFile_'.$i.'.docx');
			$i++;
		}
		$zip->output($filePath);
		header('Content-Description: File Transfer');
		header('Content-Type: application/octet-stream');
		header('Content-Disposition: attachment; filename="ReportBundle.zip"');
		header('Content-Transfer-Encoding: binary');
		header('Expires: 0');
		header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
		header('Pragma: public');
		header('Content-Length: ' . filesize($filePath));
		ob_clean();
		flush();
		readfile($filePath);
		exit;
	}
	
	/**
	 * Converts a DataObjectSet to Excel Spreadsheet format
	 */
	private function ArrayToXLS($data, $filename){
		$filename = "{$filename}_" . md5(time()) . ".xls";
		$f = new XLSDataFormatterGB();
		$filedata = $f->convertArray($data);
		$file = fopen("../assets/ExportedData/$filename", 'w') or die('cannot open');
		fwrite($file, $filedata);
		fclose($file);
		return $filename;
	}
	
}

?>
