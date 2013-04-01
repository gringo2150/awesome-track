<?php

class Application extends Page {
	
	public static $db = array(
	);
	
	public static $has_one = array(
	);
	
	//Records all the available objects in the application.
	public static $registeredObjects = array();
	
	//Each new object is to call this to register it's self in the program.
	public static function registerObject($array) {
		self::$registeredObjects = array_merge(self::$registeredObjects, $array);
	}
	
	//Return all the objects in the application.
	public static function availableObjects() {
		return self::$registeredObjects;
	}
	
	//Records all the available modules in the application.
	public static $registeredModules = array();
	
	//Each new module is to call this to register it's self in the program.
	public static function registerModule($array) {
		self::$registeredModules = array_merge(self::$registeredModules, $array);
	}
	
	//Return all the modules in the application.
	public static function availableModules() {
		$children  = array();
		foreach(get_declared_classes() as $class){
		    if(is_subclass_of((string)$class, 'WorkflowCategory')) {
				$children[] = $class;
			}
		}
		//This was the old method we shouldn't need this any longer
		$modules = self::$registeredModules;
		$children = $modules;
		//print_r($children);
		return $children;
	}
	
	//Used to record the path of each script required by a module.
	public static $moduleScripts = array();
	
	//Each module should add it's scripts to the script list using this function.
	public static function addModuleScripts($array) {
		//Update to check each script and ensure it's not in the list already
		self::$moduleScripts = array_merge(self::$moduleScripts, $array);
	}
	
	//Return all the scripts each module requires.
	public static function getModuleScripts() {
		return self::$moduleScripts;
	}
	
	//Used to store all the available context menu enteries in the application.
	public static $contextActions = array();
	
	//Add new context menu options to an object, this can then be used in the module builder
	//To select which context menu items are available on a module and it's editing screens.
	public static function addContextAction($name, $module, $object, $action) {
		//Update to check each script and ensure it's not in the list already
		$array = array(
			"Name"=>$name,
			"Module"=>$module,
			"Object"=>$object,
			"Action"=>$action
		);
		self::$contextActions = array_merge(self::$contextActions, $array);
	}
	
	//Return all the context actions.
	public static function getContextActions() {
		return self::$contextActions;
	}
	
	public static function scanPathForObjects($path) {
		$out = array();
		if ($handle = opendir($path)) {
			while (false !== ($file = readdir($handle))) {
				if ($file != "." && $file != "..") {
					if(!is_dir($path.$file)) {
						$file = substr($file, 0, -4);
						array_push($out, $file);
					}
				}
			}
			closedir($handle);
		}
		return $out;
	}
	
}

class Application_Controller extends Page_Controller implements PermissionProvider {
		
	/**
	 * Author Graham Bacon
	 * Returns The script tags required to be imported for the modules to work.
	 */
	 public function moduleScripts() {
	 	$out = '';
	 	$scripts = Application::getModuleScripts();
	 	foreach($scripts as $script) {
	 		$out .= '<script type="text/javascript" src="'.$script.'"></script>'."\n";
	 	}
	 	return $out;
	 }
	
	function listForms() {
		$direcory = $_REQUEST['dir'];
		$path = '../application/forms'.$direcory;
		$packPath = '';
		if( count(explode('/', $direcory)) > 1) {
			$temp = explode('/', $direcory);
			$tempPath = array();
			for($i=0; $i<(count($temp)-2); $i++) {
				array_push($tempPath, $temp[$i]);
			}
			$backPath = implode('/', $tempPath);
		}
		if ($handle = opendir($path)) {
			$out = array();
			while (false !== ($file = readdir($handle))) {
				if ($file != "." && $file != "..") {
					if(is_dir($path.$file)) {
						$dir = "true";
						$icon = 'application/images/windows/folder.png';
					} else {
						$dir = "false";
						$icon = 'application/images/windows/form_file.png';
					}
					array_push($out, array("name"=>"$file", "icon"=>"$icon", "dir"=>"$dir", "path"=>"$direcory"));
				}
			}
			if($direcory != '/') {
				array_push($out, array("name"=>"..", "icon"=>"application/images/windows/folder.png", "dir"=>"true", "path"=>"$backPath"));
			}
			closedir($handle);
			$jsonOut = Convert::array2json($out);
			$length = count($out);
			return "{\"results\": {$length}, \"rows\":{$jsonOut}}";
		}
		return "{\"results\":0, \"rows\":[]}";
	}
	
	function saveForm(){
		$data = $_REQUEST;
		$fname = $data['name'];
		$fh = fopen("../application/forms/{$fname}.frm", 'w');
		fwrite($fh, $data['data']);
		fclose($fh);
		return "{\"success\": true}";
	}
		
	function providePermissions(){
        $permissions = array();
        if($modules = DataObject::get('WorkflowCategory')){
		    foreach($modules as $module) {
		    	$permissions[strtoupper(str_replace(" ", "_", $module->name))] = "Can access module {$module->name}";
		    	if($items = DataObject::get('WorkflowItem', "categoryID={$module->ID}")) {
		    		foreach($items as $item) {
						$permissions[strtoupper(str_replace(" ", "_", $item->name))] = "Can access item {$item->name}";
					}
				}
		    }
        }
        return $permissions;
    }
    
    /**
     * Author Graham Bacon
     * This function loops through the registered modules and then imports
     * the module code.
     */
    public function includeModulesTemplates() {
    	$out = '';
    	$modules = Application::availableModules();
    	foreach($modules as $module) {
    		if($object = DataObject::create($module)) {
    			$out .= $object->getTemplate()."\n";
    		}
    	}
    	return $out;
    }
    
    /**
     * Author Graham Bacon
     * This function generates the module specific add and edit screens,
     * for the module config section.
     */
    public function moduleAddEditTemplates() {
    	$out = '';
    	$modules = Application::availableModules();
    	foreach($modules as $module) {
    		if($object = DataObject::create($module)) {
    			$out .= $object->moduleAddScreen()."\n";
    			$out .= $object->moduleEditScreen()."\n";
    		}
    	}
    	return $out;
    }
    
    /**
     * Author Graham Bacon
     * Include Modules into the main application window.
     */
    public function includeModules() {
    	$out = '';
    	$modules = Application::availableModules();
    	foreach($modules as $module) {
    		$out .= $module.",";
    	}
    	return substr($out, 0, strlen($out)-1);
    }
    
    /**
     * Author Graham Bacon
     * Lists Modules for the module editor in a javascript array.
     */
    public function workflowModules() {
    	$out = '';
    	$modules = Application::availableModules();
    	foreach($modules as $module) {
    		$out .= "[\"".$module."\"], ";
    	}
    	return substr($out, 0, -2);
    }
    
    /**
     * Author Graham Bacon
     * Lists Objects for the module editor and importer exporter in a javascript array.
     */
    public function databaseObjects() {
    	$out = '';
    	$objects = Application::availableObjects();
    	foreach($objects as $object) {
    		$out .= "[\"".$object."\"], ";
    	}
    	return substr($out, 0, -2);
    }
    
    /**
     * Author Graham Bacon
     * Admin permission checks.
     */
    public function adminPermissionCheck() {
    	if(Permission::check('ADMIN')) {
    		return true;
    	} else {
    		return false;
    	}
    }
	
	/** Author Graham Bacon
	 * This function populates the top menu bar in the IBL Application
	 * main menu bar, located at the top of the page.
	 */
	public function topMenuNavigation() {
		$out = '';
		if($modules = DataObject::get('WorkflowCategory', '', 'priority ASC')) {
			foreach ($modules as $module) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $module->name)))) {
					$icon = '';
					if($image = DataObject::get_by_id('Image', $module->imageID)) {
						if($smImage = $image->setSize(16,16)) {
							$icon = $smImage->URL;
						}
					}
					$out .= "
					{
						text: '{$module->name}', 
						icon: '{$icon}',
						menu: {$this->moduleItems($module->ID)}
					},";
				}
			}
		}
		return $out;
	}
	
	/**
	 * Author Graham Bacon
	 * Generates the menus for the modules down the left hand side in the application.
	 */
	public function moduleNavigation() {
		$out = '';
		if($modules = DataObject::get('WorkflowCategory', '', 'priority ASC')) {
			foreach ($modules as $module) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $module->name)))) {
					$icon = '';
					if($image = DataObject::get_by_id('Image', $module->imageID)) {	
						if($smImage = $image->setSize(16,16)) {
							$icon = $smImage->URL;
						}
					}
					if($module->module == null) {
						$out .= "
						, new Ext.Button({
							cls: 'x-toolbar',
							width: '100%',
							text: '{$module->name}', 
							icon: '{$icon}',
							handler: function(){
								for (var i=0; i<subNavigationHolder.items.items.length; i++) {
									subNavigationHolder.items.items[i].hide();
								}
								".str_replace(" ", "_",$module->name."Panel").".show();
								for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
									Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
								}
								{$module->action}
								Ext.getCmp('main').doLayout();
							}
						})";
					} else {
						$out .= "
						, new Ext.Button({
							cls: 'x-toolbar',
							width: '100%',
							text: '{$module->name}', 
							icon: '{$icon}',
							handler: function(){
								for (var i=0; i<subNavigationHolder.items.items.length; i++) {
									subNavigationHolder.items.items[i].hide();
								}
								".str_replace(" ", "_",$module->name."Panel").".show();
								for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
									Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
								}
								{$module->getNavigation()}
								Ext.getCmp('main').doLayout();
							}
						})";
					}
				}
			}
		}
		return $out;
	}
	
	public function moduleNaviagtionPanels() {
		$out = '';
		if($modules = DataObject::get('WorkflowCategory', '', 'priority ASC')) {
			foreach ($modules as $module) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $module->name)))) {
					$out .= ",".str_replace(" ", "_",$module->name."Panel");
				}
			}
		}
		return $out;
	}
	
	public function modulePanels() {
		$out = '';
		if($modules = DataObject::get('WorkflowCategory', '', 'priority ASC')) {
			foreach ($modules as $module) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $module->name)))) {
					$out .= "
					var ".str_replace(" ", "_",$module->name."Panel")." = new Ext.Toolbar({
						flex: 2, 
						layout: 'vbox',
						height: '100%',
						id: '".str_replace(" ", "_",$module->name."Panel")."', 
						autoWidth: true,
						width: 'auto', 
						layoutConfig: { 
							align: 'stretch', 
							pack: 'start'
						}, hidden: true, 
						defaults: { 
							margins: '5 5 0 5',
							height: 20, 
							cls: 'leftButton' 
						}, 
						items: {$this->moduleItems($module->ID)}
					});";
				}
			}
		}
		return $out;
	}
	
	private function moduleItems($moduleID) {
		$out = '[';
		if($items = DataObject::get("WorkflowItem", "categoryID='{$moduleID}'", "Priority ASC")) {
			foreach ($items as $item) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $item->name)))) {
					$icon = '';
					if($image = DataObject::get_by_id('Image', $item->imageID)) {
						if($smImage = $image->setSize(16,16)) {
							$icon = $smImage->URL;
						}
					}
					$out .= "{
						text: '{$item->name}',
						icon: '{$icon}',
						tooltip: '{$item->tooltip}',
						handler: function() {
							{$item->action}
						}
					},";
				}
			}
		}
		if ($out != '[') $out = substr($out,0,-1);
		$out .= ']';
		return $out;
	}
	
	public function moduleComboList() {
		$out = '';
		if($modules = DataObject::get('WorkflowCategory', '', 'priority ASC')) {
			foreach ($modules as $module) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $module->name)))) {
					$icon = '';
					if($image = DataObject::get_by_id('Image', $module->imageID)) {
						if($smImage = $image->setSize(16,16)) {
							$icon = $smImage->URL;
						}
					}
					$out .= "['{$module->ID}', '{$module->name}', '{$icon}'],";
				}
			}
		}
		return $out;
	}
	
	/**************** Home Control Workflow ****************/
	
	public function homeControlWorkflow() {
		$out = "var homeControlWorkflow = new Ext.Panel({
					hidden: false,
					border: false,
					layout: 'fit',
					items: [{
						xtype: 'panel',
						title: 'Home',
						frame: true,
						layout: 'absolute',
						defaults: {
							height: 60,
							width: '150'
						},
						items: [";
		if($items = DataObject::get('WorkflowItem', "showOnHome='true'")) {
			foreach ($items as $item) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $item->name)))) {
					$image = DataObject::get_by_id('Image', $item->imageID);
					$icon = '';
					if($smImage = $image->SetSize(32,32)){
						$icon = $smImage->URL;
					}
					$out .= "
					new Ext.Button({
						text: '{$item->name}', 
						icon: '{$icon}',
						tooltip: '{$item->tooltip}',
						scale: 'large',
						x: {$item->xPos},
						y: {$item->yPos},
						iconAlign: 'top',
						handler: function(){
							{$item->action}
						}
					}),";
				}
			}
		}
		if($modules = DataObject::get('WorkflowCategory', "showOnHome='true'")) {
			foreach ($modules as $module) {
				if (Permission::check(strtoupper(str_replace(" ", "_", $module->name)))) {
					$image = DataObject::get_by_id('Image', $module->imageID);
					$icon = '';
					if($smImage = $image->SetSize(32,32)){
						$icon = $smImage->URL;
					}
					$out .= "
					new Ext.SplitButton({
						split: true,
						text: '{$module->name}', 
						icon: '{$icon}',
						tooltip: '{$module->tooltip}',
						scale: 'large',
						x: {$module->xPos},
						y: {$module->yPos},
						iconAlign: 'top',
						handler: function(){
							for (var i=0; i<subNavigationHolder.items.items.length; i++) {
								subNavigationHolder.items.items[i].hide();
							}
							".str_replace(' ', '_',$module->name)."Panel".".show();
							for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
								Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
							}
							{$module->action}
							Ext.getCmp('main').doLayout();
						},
						menu: {width: 150, items: {$this->moduleItems($module->ID)} } 
					}),";
				}
			}
			$out = substr($out, 0, strlen($out)-1);
		}
		$out .= "]
			}]
		});";
		return $out;
	}
		
/********************* Searching and basic API features *********************/
		
	/**
	 * Function that finds finds a dataobject based on a simple OR search
	 *
	 */
	public function search() {
		if(!isset($_REQUEST['searchType']) || $_REQUEST['searchType'] != "AND") $_REQUEST['searchType'] = "OR";
		$searchType = $_REQUEST['searchType'];
		if(!isset($_REQUEST['start']) || !is_numeric($_REQUEST['start']) || (int)$_REQUEST['start'] < 1) $_REQUEST['start'] = 0;
		$SQL_start = (int)$_REQUEST['start'];
		unset($_REQUEST['start']);
		if(!isset($_REQUEST['limit']) || !is_numeric($_REQUEST['limit']) || (int)$_REQUEST['limit'] < 1) $_REQUEST['limit'] = 20;
		$SQL_limit = (int)$_REQUEST['limit'];
		unset($_REQUEST['limit']);
		if(!isset($_REQUEST['startDate'])) $_REQUEST['startDate'] = null;
		$startDate = $_REQUEST['startDate'];
		if(!isset($_REQUEST['endDate'])) $_REQUEST['endDate'] = null;
		$endDate = $_REQUEST['endDate'];
		if(!isset($_REQUEST['columns'])) $_REQUEST['columns'] = null;
		$Columns = $_REQUEST['columns'];
		if(!isset($_REQUEST['query'])) $_REQUEST['query'] = null;
		$metadata = isset($_REQUEST['meta']) ? true : false;
		$columnModel = isset($_REQUEST['columnModel']) ? true : false;
		$treeModel = isset($_REQUEST['treeModel']) ? true : true; //Hack for the old modules, fix when upgraded.
		$QueryData = $_REQUEST['query'];
		$extraParams = isset($_REQUEST['extraParams']) ? explode(',',$_REQUEST['extraParams']) : array();		
		$sudoParams = array();
		$columnModelParams = isset($_REQUEST['columnModelParams']) ? explode(',',$_REQUEST['columnModelParams']) : array();
		$Object = $this->urlParams['ID'];
		if(!isset($_REQUEST['orderBy'])) $_REQUEST['orderBy'] = null;
		if(!isset($_REQUEST['orderByDirection'])) $_REQUEST['orderByDirection'] = 'DESC';
		if(count(explode('.',$_REQUEST['orderBy']))>1){
			$OrderByTmpArr = explode('.',$_REQUEST['orderBy']);
			$OrderByTmp = $OrderByTmpArr[0].'ID';
		} else {
			$OrderByTmp = $_REQUEST['orderBy'];
		}
		$OrderBy = $_REQUEST['orderBy'] ? "{$Object}.{$OrderByTmp} {$_REQUEST['orderByDirection']}" : "{$Object}.ID DESC";
		$Query = '';
		$Join = '';
		if($Columns != null && $QueryData != null) {
			$Columns = explode(',', $Columns);	
			$subObjArray = array();
			foreach ($Columns as $Column) {
				if($Column == 'ID') {
					$ID = (int)$QueryData;
					$Query .= "$Object.ID='{$ID}' {$searchType} ";
				} else {
					if(count(explode('.',$Column))>1){
						$relation = explode('.',$Column);
						$tmpObj = Object::create($Object);
						$has_one = $tmpObj->has_one();
						$subObj = '';
						foreach($has_one as $key=>$value) {
							if($key == $relation[0]) {
								$subObj = $value;
								break;
							}
						}
						if(!in_array($subObj, $subObjArray)) {
							$Join .= "LEFT JOIN $subObj ON $subObj.ID = $Object.{$relation[0]}ID ";
							$subObjArray[] = $subObj;
						}
						$Query .= "$subObj.{$relation[1]} LIKE '%$QueryData%' {$searchType} ";
					} else {
						$parentClass = get_parent_class($Object);
						if($parentClass != 'Object' && $parentClass != 'DataObject') {
							//$Join .= "LEFT JOIN {$parentClass} ON {$parentClass}.ID = {$Object}.ID ";
							$pTmpObj = Object::create($parentClass);
							$arr = $pTmpObj->stat('db');
							if(isset($arr[$Column])) {
								$Query .= "$parentClass.$Column LIKE '%$QueryData%' {$searchType} ";
							}
						}
						$tmpObj = Object::create($Object);
						$arr = $tmpObj->stat('db');
						//print_r($arr);
						if(isset($arr[$Column])) {
							$Query .= "$Object.$Column LIKE '%$QueryData%' {$searchType} ";
						}
					}
				}
			}
			$Query = ($searchType == "AND") ? substr($Query, 0, strlen($Query)-5) : substr($Query, 0, strlen($Query)-4);
			if($startDate != null && $endDate != null) {
				$Query .= " AND (DATE(TreeObject.Created) >= DATE('$startDate') AND DATE(TreeObject.Created) <= DATE('$endDate'))";
			}
		} elseif ($startDate != null && $endDate != null) {
			$Query .= "(DATE(TreeObject.Created) >= DATE('$startDate') AND DATE(TreeObject.Created) <= DATE('$endDate'))";
		}
		if (count($extraParams) > 0) {
			foreach ($extraParams as $param) {
				$split = explode(':',$param);
				if (count($split) == 2) {
					if (strpos($split[0], "[sudo]") === false) {
						if ($Query == null || $Query == "") {
							$Query .= "(`{$split[0]}` = '{$split[1]}')";
						} else {
							$Query .= " AND (`{$split[0]}` = '{$split[1]}')";
						}
					} else {
						$split[0] = substr($split[0], 6);
						$sudoParams[] = $split;
					}
				}
			}
		}
		//echo $Query;
		if($results = DataObject::get($Object, $Query, $OrderBy, $Join, "{$SQL_start},{$SQL_limit}")) {
			if (count($sudoParams) > 0) {
				foreach ($sudoParams as $sudo) {
					foreach($results as $result) {
						if ($result->$sudo[0] != $sudo[1]) $results->remove($result);
					}
				}
			}
			$f = new JSONDataFormatter(); 
			if($metadata == true) {
				$json = $f->convertDataObjectSet($results, null, $this->generateMetaData($Object));
			} else {
				$json = $f->convertDataObjectSet($results, null, '');
			}
			if($treeModel == true){
				$json = $this->update_with_tree_data($results, $json);
			}
			if($columnModel == true) {
				$json = $this->update_with_column_model($Object, $json, $columnModelParams);
			}
			return $json;
		} else {
			return $this->update_with_column_model($Object, '{"results": 0, "rows":[], "query":"'.$Query.'", "join":"'.$Join.'", '.$this->generateMetaData($Object).' "tree":[]  }', $columnModelParams);
		}
	}
	
	/**
	 * Function that mimics the search function,
	 * but exports the results as a Microsoft Excel Spreadsheet (.xls)
	 */
	public function searchResultsToXLS() {
		if(!isset($_REQUEST['start']) || !is_numeric($_REQUEST['start']) || (int)$_REQUEST['start'] < 1) $_REQUEST['start'] = 0;
		$SQL_start = (int)$_REQUEST['start'];
		unset($_REQUEST['start']);
		if(!isset($_REQUEST['limit']) || !is_numeric($_REQUEST['limit']) || (int)$_REQUEST['limit'] < 1) $_REQUEST['limit'] = 20;
		$SQL_limit = (int)$_REQUEST['limit'];
		unset($_REQUEST['limit']);
		if(!isset($_REQUEST['startDate'])) $_REQUEST['startDate'] = null;
		$startDate = $_REQUEST['startDate'];
		if(!isset($_REQUEST['endDate'])) $_REQUEST['endDate'] = null;
		$endDate = $_REQUEST['endDate'];
		if(!isset($_REQUEST['columns'])) $_REQUEST['columns'] = null;
		$Columns = $_REQUEST['columns'];
		if(!isset($_REQUEST['query'])) $_REQUEST['query'] = null;
		$QueryData = $_REQUEST['query'];
		if(!isset($_REQUEST['tableFields'])) $_REQUEST['tableFields'] = null;
		if($_REQUEST['tableFields']){
			$TableFields = $_REQUEST['tableFields']; 
		} else {
			$TableFields = null;
		}
		$Object = $this->urlParams['ID'];
		if(!isset($_REQUEST['orderBy'])) $_REQUEST['orderBy'] = null;
		if(!isset($_REQUEST['orderByDirection'])) $_REQUEST['orderByDirection'] = 'DESC';
		if(count(explode('.',$_REQUEST['orderBy']))>1){
			$OrderByTmpArr = explode('.',$_REQUEST['orderBy']);
			$OrderByTmp = $OrderByTmpArr[0].'ID';
		} else {
			$OrderByTmp = $_REQUEST['orderBy'];
		}
		$OrderBy = $_REQUEST['orderBy'] ? "{$Object}.{$OrderByTmp} {$_REQUEST['orderByDirection']}" : "{$Object}.ID DESC";
		$Query = '';
		$Join = '';
		if($Columns != null && $QueryData != null) {
			$Columns = explode(',', $Columns);	
			$subObjArray = array();
			foreach ($Columns as $Column) {
				if($Column == 'ID') {
					$ID = (int)$QueryData;
					$Query .= "$Object.ID='{$ID}' OR ";
				} else {
					if(count(explode('.',$Column))>1){
						$relation = explode('.',$Column);
						$tmpObj = Object::create($Object);
						$has_one = $tmpObj->has_one();
						$subObj = '';
						foreach($has_one as $key=>$value) {
							if($key == $relation[0]) {
								$subObj = $value;
								break;
							}
						}
						if(!in_array($subObj, $subObjArray)) {
							$Join .= "LEFT JOIN $subObj ON $subObj.ID = $Object.{$relation[0]}ID ";
							$subObjArray[] = $subObj;
						}
						$Query .= "$subObj.{$relation[1]} LIKE '%$QueryData%' OR ";
					} else {
						$Query .= "$Object.$Column LIKE '%$QueryData%' OR ";
					}
				}
			}
			$Query = substr($Query, 0, strlen($Query)-4);
			if($startDate != null && $endDate != null) {
				$Query .= " AND (DATE(TreeObject.Created) >= DATE('$startDate') AND DATE(TreeObject.Created) <= DATE('$endDate'))";
			}
		} elseif ($startDate != null && $endDate != null) {
			$Query .= "(DATE(TreeObject.Created) >= DATE('$startDate') AND DATE(TreeObject.Created) <= DATE('$endDate'))";
		}
		if($results = DataObject::get($Object, $Query, $OrderBy, $Join, "{$SQL_start},{$SQL_limit}")) {
			$filename = $this->DataObjectSetToXLS($results, $Object, $TableFields);
			return '{"success":true, "data":{"file":"' . Director::BaseURL() . 'assets/ExportedData/' . $filename . '", "filename":"' . $filename . '"}}';
		} else {
			return '{"success":false, "data":[]}';
		}
	}
	
	/**
	 * Converts a DataObjectSet to Excel Spreadsheet format
	 */
	public function DataObjectSetToXLS($dos, $classname, $fields = null){
		$filename = "{$classname}_" . md5(time()) . ".xls";
		$f = new XLSDataFormatter();
		$filedata = $f->convertDataObjectSet($dos, $fields);
		$file = fopen("../assets/ExportedData/$filename", 'w') or die('cannot open');
		fwrite($file, $filedata);
		fclose($file);
		return $filename;
	}
	
	public function selectionToXLS() {
		$headers = json_decode($_REQUEST['headers']);
		$rows = json_decode($_REQUEST['rows']);
		$data = array();
		foreach($rows as $row) {
			$tmpRow = array();
			foreach($row as $key=>$value) {
				$tmpRow[$key] = $value;
			}
			$data[] = $tmpRow;
		}
		return $this->ArrayToXLS($data, 'Selection');
	}
	
	public function ArrayToXLS($data, $filename, $download = false){
		$filename = "{$filename}_" . md5(time()) . ".xls";
		$f = new XLSDataFormatterGB();
		$filedata = $f->convertArray($data);
		$file = fopen("../assets/ExportedData/$filename", 'w') or die('cannot open');
		fwrite($file, $filedata);
		fclose($file);
		if($download) {
			header('Content-Description: File Transfer');
			header('Content-Type: application/octet-stream');
			header('Content-Disposition: attachment; filename="'.$filename.'"');
			header('Content-Transfer-Encoding: binary');
			header('Expires: 0');
			header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
			header('Pragma: public');
			header('Content-Length: ' . filesize("../assets/ExportedData/".$filename));
			ob_clean();
			flush();
			readfile("../assets/ExportedData/".$filename);
			exit;
		} else {
			return '{"success":true, "data":{"file":"' . Director::BaseURL() . 'assets/ExportedData/' . $filename . '", "filename":"' . $filename . '"}}';
		}
	}
	
	public function update_with_column_model($class, $json, $column_model_param = null) {
		if($json) {
			$temp = substr($json, 0, -3);
			$out = ", \"columnModel\":[";
			if ($object = Object::create($class)){
				$cm = $object->stat('columnModel');
				//if (is_callable($cm)) $cm = $cm($column_model_param);
				if (!is_array($cm) && is_callable(array($object, $cm))) {
					$cm = $object->$cm($column_model_param);
				}
				//$cm = (is_callable($object::columnModel)) ? $object::columnModel($column_model_param) : $object->stat('columnModel');
				foreach($cm as $column) {
					$width = "";
					if($column[2] != "") {
						$width = "\"width\":{$column[2]},";
					}
					$renderer = "";
					if($column[3] != "") {
						$renderer = "\"renderer\":{$column[3]},";
					}
					$out .= "{
						\"header\":\"{$column[0]}\", 
						\"dataIndex\":\"{$column[1]}\", 
						{$width}
						{$renderer}
						\"canSearch\":{$column[4]}, 
						\"incSearch\":{$column[5]}, 
						\"hidden\":{$column[6]}
					},";
				}
				$out = substr($out, 0, -1);
			}
			$out .= "]\n}\n";
			$temp .= $out;
			return $temp;
		}
	}
	
	
	/**
	* Updates the search results from the search function to include the data for 
	* the tree view in the JSON array.
	*/
	public function update_with_tree_data($results, $json) {
		$tree = array();
		if ($json) {
			$temp = substr($json, 0, -3);
			foreach ($results as $r) {
				if ($r instanceOf TreeObject) {
					$tree[] = $this->getJSONTreeNode($r);
				}
			}
			$temp = $temp . ', "tree":' . Convert::array2json($tree) . "\n}\n";
			return $temp;
		} else {
			return null;
		}
	}	
	
	
	public function getRootTreeNodeJSON($object) {
		$leaf = "true";
		$children = "";
		if ($object->stat('tree_root_nodes')) {
			foreach ($object->stat('tree_root_nodes') as $k => $v) {
				if ($v == 'has_one')  {
					$cls = $this->getHasOneClass($object, $k);
					$id = $k . "ID";
					if ($obj = DataObject::get_by_id($cls, $object->$id)) {
						$leaf = "false";
						$children .= $this->getRootTreeNodeJSON($obj) . ',';
					};
				} else if ($v == 'has_many') {
					$cls = $this->getHasManyClass($object, $k);
					if ($obj = Object::create($cls)) {
						$leaf = "false";
						$nn = $obj->stat('tree_node_plural_name');
						$children .= '{"text":"' . $nn . '", ';
						$children .= '"ID":"' . $obj->ID . '", ';
						$children .= '"icon":' . $this->createIcon($obj, 'default_tree_icon') . '", ';
						$children .= '"leaf":"' . $leaf . '", ';
						$children .= '"children":[]},';
					};
				}
			}
			$children = substr($children, 0, -1);
		}
		$nodeName = $this->createName($object, 'tree_node_name');
		$node = '{"text":"' . $object->$nodeName . '", ';
		$node .= '"ID":"' . $object->ID . '", ';
		$node .= '"icon":' . $this->createIcon($object, 'default_tree_icon') . '", ';
		$node .= '"leaf":"' . $leaf . '", ';
		$node .= '"children":[' . $children . ']}';
		return $node;
	}
	
	public function getJSONTreeNode($object, $children = true) {
		$nodeName = $this->createName($object, 'tree_node_name');
		$node = array(
			'text' => $nodeName,
			'ID' => $object->ID,
			'icon' => $this->createIcon($object, 'default_tree_icon'),
			'leaf' => 'false',
			'children' => $children ? $this->getTreeNodeChildren($object) : array(),
			'ClassName' => $object->ClassName,
			'Type' => 'item',
			'expandable' => 'true'
		);	
		return $node;
	}
	
	public function getTreeNodeChildren($object) {
		$children = array();
		if ($object->stat('tree_root_nodes')) {
			foreach ($object->stat('tree_root_nodes') as $k => $v) {
				if ($v == 'has_one')  {
					$cls = $this->getHasOneClass($object, $k);
					$id = $k . "ID";
					if ($obj = DataObject::get_by_id($cls, $object->$id)) {
						$children[] = $this->getJSONTreeNode($obj, false);
					};
				} else if ($v == 'has_many') {
					$cls = $this->getHasManyClass($object, $k);
					if ($obj = Object::create($cls)) {
						$tempObj = Object::create($obj->ClassName);
						$class = $this->getHasOneClass($tempObj, $object->ClassName, true);
						$id = $class . "ID";
						$count = 0;
						if($childObjects = DataObject::get($obj->ClassName, "{$id} = {$object->ID}")) {
							$count = $childObjects->Count();
							$nodeName = $this->createName($obj, 'tree_node_plural_name');
							$node = array(
								'text' => "({$count}) ".$nodeName,
								'icon' => $this->createIcon($obj, 'default_tree_icon'),
								'leaf' => 'false',
								'children' => array(),
								'ClassName' => $obj->ClassName,
								'ParentClassName' => $object->ClassName,
								'ParentID' => $object->ID,
								'Type' => 'holder',
								'expandable' => 'true'
							);
							$children[] = $node;
						}
					}
				}
			}
		}
		return $children;
	}
	
	public function getTreeNodeChildrenAJAX() {
		$data = $_REQUEST;
		$object = ($data['Type'] == 'holder') ? DataObject::get_by_id($data['ParentClassName'], (int)$data['ParentID']) : DataObject::get_by_id($data['ClassName'], (int)$data['ID']);
		$children = array();
		if ($data['Type'] == 'holder') {
			$tempObj = Object::create($data['ClassName']);
			$class = $this->getHasOneClass($tempObj, $data['ParentClassName'], true);
			$id = $class . "ID";
			$childObjects = DataObject::get($data['ClassName'], "{$id} = {$object->ID}");
			if ($childObjects) {
				foreach ($childObjects as $c) {
					$children[] = $this->getJSONTreeNode($c, false);
				}
			}
		} else if ($object->stat('tree_child_nodes')) {
			foreach ($object->stat('tree_child_nodes') as $k => $v) {
				if ($v == 'has_one')  {
					$cls = $this->getHasOneClass($object, $k);
					$id = $k . "ID";
					if ($obj = DataObject::get_by_id($cls, $object->$id)) {
						$children[] = $this->getJSONTreeNode($obj, false);
					};
				} else if ($v == 'has_many') {
					$cls = $this->getHasManyClass($object, $k);
					if ($obj = Object::create($cls)) {
						$tempObj = Object::create($obj->ClassName);
						$class = $this->getHasOneClass($tempObj, $object->ClassName, true);
						$id = $class . "ID";
						$count = 0;
						if($childObjects = DataObject::get($obj->ClassName, "{$id} = {$object->ID}")) {
							$count = $childObjects->Count();	
							$nodeName = $this->createName($obj, 'tree_node_plural_name');
							$node = array(
								'text' => "({$count}) ".$nodeName,
								'icon' => $this->createIcon($obj, 'default_tree_icon'),
								'leaf' => 'false',
								'children' => array(),
								'ClassName' => $obj->ClassName,
								'ParentClassName' => $object->ClassName,
								'ParentID' => $object->ID,
								'Type' => 'holder',
								'expandable' => 'true'
							);
							$children[] = $node;
						}
					}
				}
			}
		}
		return '{"success":true, "tree":' . Convert::array2json($children) . '}';
	}
	
	/**
	 * This function grabs a static, checks if it's a function, if so then we execute it
	 * Otherwise we split the string and extract the properties from the object.
	 *
	 */
	private function createName($object, $static) {
		$name = "";
		if ($object && $static) {
			$pattern = $object->stat($static);
			if(method_exists($object,$pattern)) {
				$name = $object->$pattern();
			} else {
				$words = explode(" ", $pattern);
				foreach($words as $word){
					$name .= $object->$word . " ";
				}
				$name = substr($name, 0, -1);
			}
		}
		$test = str_replace(" ", "", $name);
		return ($test != "") ? $name : $pattern;
	}
	
	/**
	 * Function is virtually the same as the above, apart from it sets the icons
	 * for the tree item we are working with.
	 */
	private function createIcon($object, $static) {
		$icon = "";
		if ($object && $static) {
			$val = $object->stat($static);
			if(method_exists($object,$val)) {
				$icon = $object->$val();
			} else {
				$icon = 'mysite/images/tree_icons/'.$val;
			}
		}
		return $icon;
	}
	
	/**
	 * Author Graham Bacon
	 * Finds class of a has_one relationship based on the child
	 * name provided for the class.
	 */
	private function getHasOneClass($obj, $relation_name, $flip = false) {
		$has_one = $obj->has_one();
		$has_one = $flip ? array_flip($has_one) : $has_one;
		$rtn = '';
		foreach ($has_one as $k=>$v) {
			if($k == $relation_name) {
				$rtn = $v;
				break;
			} 	
		}
		return $rtn;
	}
	
	/**
	 * Author David Sloane
	 * Finds class of a has_many relationship based on the child
	 * name provided for the class.
	 */
	private function getHasOManyClass($obj, $relation_name) {
		$has_many = $obj->has_many();
		$rtn = '';
		foreach ($has_many as $k=>$v) {
			if($k == $relation_name) {
				$rtn = $v;
				break;
			} 	
		}
		return $rtn;
	}
	
	/**
	 * Author Graham Bacon
	 * Finds class of a has_many relationship based on the child
	 * name provided for the class.
	 */
	private function getHasManyClass($obj, $relation_name) {
		$has_many = $obj->has_many();
		$rtn = '';
		foreach ($has_many as $k=>$v) {
			if($k == $relation_name) {
				$rtn = $v;
				break;
			} 	
		}
		return $rtn;
	}
	
	/**
	 * returns all children objects of the specified classname that are related to
	 * a parent object via the column name and value specified.
	 */
	public function getChildObjects(){
		set_time_limit(0);
		if(!isset($_REQUEST['column'])) $_REQUEST['column'] = null;
		$Column = isset($_REQUEST['column']) ? explode(",",$_REQUEST['column']) : null;
		if(!isset($_REQUEST['value'])) $_REQUEST['value'] = null;
		$Value = isset($_REQUEST['value']) ? explode(",",$_REQUEST['value']) : null;
		$Object = $this->urlParams['ID'];
		if(!isset($_REQUEST['orderBy'])) $_REQUEST['orderBy'] = null;
		if(!isset($_REQUEST['orderByDirection'])) $_REQUEST['orderByDirection'] = 'DESC';
		$orderByString = "";
		// order by stuff...
		$dbFields = Object::create($Object)->db();
		if ($_REQUEST['orderBy']){
			foreach (explode(',',$_REQUEST['orderBy']) as $oc){
				$OrderByTemp = "";
				if(count(explode('.',$oc))>1){
					$OrderByTmpArr = explode('.',$oc);
					$tmpObj = Object::create($Object);
					$has_one = $tmpObj->has_one();
					$subObj = '';
					foreach($has_one as $key=>$value) {
						if($key == $OrderByTmpArr[0]) {
							$subObj = ($value == "Image") ? "File" : $value;
							break;
						}
					}
					$OrderByTmp = $subObj ? "{$subObj}.{$OrderByTmpArr[1]}" : "";
				} else {
					$OrderByTmp = (in_array($oc, $dbFields)) ? "{$Object}.{$oc}" : "";
				}	
				$orderByString .= $OrderByTemp ? "{$OrderByTmp} {$_REQUEST['orderByDirection']}, " : "";
			}
			$orderByString = $orderByString ? substr($orderByString, 0, -2) : "";
		}
		$OrderBy = $_REQUEST['orderBy'] ? "{$orderByString}" : "{$Object}.ID DESC";
		$Query = '';
		if($Column != null && $Value != null) {
			$i = 0;
			foreach ($Column as $col) {
				$Query .= "{$col}='{$Value[$i]}' AND ";
				$i++;
			}
			$Query = substr($Query, 0, -5);
		}
		if($results = DataObject::get($Object, $Query, $OrderBy)) {
			$f = new JSONDataFormatter(); 
			$json = $f->convertDataObjectSet($results);
			return $json;
		} else {
			return '{"results": 0, "rows":[], "query":"'.$Query.'"}';
		}
	}
	
	/**
	* Selects a object from the database, normally for displaying a record for editing.
	*
	*/
	public function selectSingleObject() {
		$Object = $this->urlParams['ID'];
		$ID = $this->urlParams['OtherID'];
		if($result = DataObject::get_by_id($Object,(int)$ID)) {
			$f = new JSONDataFormatter();
			$json = $f->convertDataObject($result);
			return "{\"success\":true, \"data\":[$json]}";
		} else {
			return '{"success": false, "data":[]}';
		}
	}
	
	/**
	 * Generates the meta data for a given object, to be used by searches and forms
	 * 
	 * Note
	 * Should this be moved into dataobject or tree object, maybe the whole search stuff needs to be in an
	 * Object with a system defined path such as search, this way we can remove the CMS part of the system.
	 */
	public function generateMetaData($ObjectName) {
		$Object = Object::create($ObjectName);
		$fields = array();
		$db = $Object->db();
		array_push($fields, array("name"=>"ID", "type"=>"int")); //
		foreach($db as $key=>$value) {
			$value = $this->convertTypeToEXT($value);
			$xtype = $this->getInputType($value);
			array_push($fields, array("name"=>"{$key}", "type"=>"{$value}", "xtype"=>"{$xtype}")); //
		}
		$has_one = $Object->has_one();
		foreach($has_one as $key=>$value) {
			//array_push($fields, array("name"=>"{$key}", "type"=>"{$value}"));
			if($value == 'Image') {
				$xtype = $this->getInputType($value);
				array_push($fields, array("name"=>"{$key}", "mapping"=>"{$key}", "xtype"=>"{$xtype}"));
			} else {
				array_push($fields, array("name"=>"{$key}ID", "type"=>"int", "mapping"=>"{$key}ID"));
			}
			$sObject = Object::create($value);
			if($sObject == $Object) {
			} else {
				$sdb = $sObject->db();
				array_push($fields, array("name"=>"{$key}.ID", "type"=>"int", "mapping"=>"{$key}.ID")); //, "mapping"=>"{$key}.ID"
				foreach($sdb as $sKey=>$sValue) {
					$sValue = $this->convertTypeToEXT($sValue);
					$xtype = $this->getInputType($sValue);
					array_push($fields, array("name"=>"{$key}.{$sKey}", "type"=>"{$sValue}", "mapping"=>"{$key}.{$sKey}", "xtype"=>"{$xtype}")); //, "mapping"=>"{$key}.{$sKey}"
				}
				$shas_one = $sObject->has_one();
				foreach($shas_one as $sKey=>$sValue) {
					$sValue = $this->convertTypeToEXT($sValue);
					$xtype = $this->getInputType($sValue);
					array_push($fields, array("name"=>"{$key}.{$sKey}", "type"=>"{$sValue}", "mapping"=>"{$key}.{$sKey}", "xtype"=>"{$xtype}")); //, "mapping"=>"{$key}.{$sKey}"
				}
			}
		}
		$fields = Convert::array2json($fields);
		$metaData = "
		\"metaData\": {
		\"idProperty\": \"ID\",
        \"root\": \"rows\",
        \"totalProperty\": \"results\",
        \"start\": 0,
        \"limit\": 20,
        \"successProperty\": \"success\",
        \"fields\": {$fields}
       	},
       	";
		return $metaData;
	}
	
	/**
	 *
	 *
	 */
	private function convertTypeToEXT($type) {
		$rtn = '';
		switch ($type) {
    		case "String":
        		$rtn =  "string";
        		break;
        	case "Text":
        		$rtn = "string";
        		break;
        	case "Integer":
        		$rtn = "int";
        		break;
        	case "int":
        		$rtn = "int";
        		break;
        	case "Boolean":
        		$rtn = "boolean";
        		break;
        	case "Date":
        		$rtn = "date";
        		break;
        	case "SSDatetime":
        		$rtn = "date";
        		break;
        	case "Float":
        		$rtn = "float";
        		break;
        	default:
        		$rtn = "auto";
    	}
    	return $rtn;
	}
	
	/**
	 * Author  Graham Bacon
	 * Gets the data type of the field and then gets the ideal ext input type.
	 */
	private function getInputType($type) {
		$rtn = '';
		switch ($type) {
    		case "String":
        		$rtn =  "textfield";
        		break;
        	case "Text":
        		$rtn = "textfield";
        		break;
        	case "Integer":
        		$rtn = "numberfield";
        		break;
        	case "int":
        		$rtn = "numberfield";
        		break;
        	case "Boolean":
        		$rtn = "xcheckbox";
        		break;
        	case "Date":
        		$rtn = "datefield";
        		break;
        	case "SSDatetime":
        		$rtn = "datefield";
        		break;
        	case "Float":
        		$rtn = "numberfield";
        		break;
        	case "Image":
        		$rtn = "fileuploadfield";
        		break;
        	default:
        		$rtn = "textfield";
    	}
    	return $rtn;
	}
	
	/**
	 * Deletes an object forn the system, needs to be updated to delete all children as well.
	 *
	 */
	public function deleteSingleObject() {
		$Object = $this->urlParams['ID'];
		$data = $_REQUEST;
		if ($DataObject = DataObject::get_by_id($Object, (int)$data['ID'])) {
			$DataObject->delete();
			echo '{"success": true, "data":{}}';
		} else{
    		echo '{"success": false, "data":{}}';
		}
	}
	
	/**
	 * Update a single object, this will also update any files and images sent with this request.
	 *
	 */
	public function updateSingleObject() {
		$Object = $this->urlParams['ID'];
		$data = $_REQUEST;
		if ($DataObject = DataObject::get_by_id($Object, (int)$data['ID'])) {
			foreach ($data as $key=>$value) {
				$DataObject->$key = $value;
			}
			foreach($_FILES as $key=>$value) {
				$IDkey = $key.'ID';
				$has_one = $DataObject->has_one();
				if($has_one[$key] == 'Image' || $has_one[$key] == 'File') {
					if($DataObject->$IDkey < 1) {
						$subObject = Object::create($has_one[$key]);
					} else {
						$subObject = DataObject::get_by_id($has_one[$key], (int)$DataObject->$IDkey);
						if($_FILES[$key]['tmp_name'] != '') {
							$subObject->delete();
							$subObject = Object::create($has_one[$key]);
						}
					}
					$file_path = "../assets/Uploads/";
					$fileName = basename(md5(time())."_".str_replace(" ", "_", $_FILES[$key]['name']));
					$file_path = $file_path . $fileName; 
					if(move_uploaded_file($_FILES[$key]['tmp_name'], $file_path)) {
						$subObject->Name = $fileName;
						$subObject->Title = $fileName;
						$subObject->Filename = $file_path;
						$subObject->ParentID = 3;
						$subObject->OwnerID = 0;
					}
					$subObject->write();
					$DataObject->$IDkey = $subObject->ID;
				}
			}
			$RtnID = $DataObject->write();
			$f = new JSONDataFormatter();
			$json = $f->convertDataObject($DataObject);
			echo '{"success": true, "data":{"ID":"'.$RtnID.'","rows":[]}}'; //.$json.
		} else{
    		echo '{"success": false, "data":{}}';
		}
	}
	
	/**
	 * Saves a single object to the system along with any files or images sent with it.
	 *
	 */
	//WARNING
	//This function has a bug when saving files and images, this has been fixed in save multi object
	//Those changes need to be updated back into here.
	public function saveSingleObject() {
		$Object = $this->urlParams['ID'];
		$data = $_REQUEST;
		if ($DataObject = Object::create($Object)) {
			foreach ($data as $key=>$value) {
				$DataObject->$key = $value;
			}
			//$hobj = $this->processObjHasOne($DataObject, $data);
			//$hobj->write();
			foreach($_FILES as $key=>$value) {
				$IDkey = $key.'ID';
				$has_one = array();
				if($parent = get_parent_class($DataObject)) {
					if($parentObject = Object::create($parent)) {
						if($parentObject->has_one()) {
							$has_one = array_merge($DataObject->has_one(), $parentObject->has_one());
						} else {
							$has_one = $DataObject->has_one();
						}
					}
				}
				if($has_one[$key] == 'Image' || $has_one[$key] == 'File') {
					if($DataObject->$IDkey < 1) {
						$subObject = Object::create($has_one[$key]);
					} else {
						$subObject = DataObject::get_by_id($has_one[$key], (int)$DataObject->$IDkey);
						if($_FILES[$key]['tmp_name'] != '') {
							$subObject->delete();
							$subObject = Object::create($has_one[$key]);
						}
					}
					$file_path = "../assets/Uploads/";
					$fileName = basename(md5(time())."_".str_replace(" ", "_", $_FILES[$key]['name']));
					$file_path = $file_path . $fileName; 
					if(move_uploaded_file($_FILES[$key]['tmp_name'], $file_path)) {
						$subObject->Name = $fileName;
						$subObject->Title = $fileName;
						$subObject->Filename = $file_path;
						$subObject->ParentID = 3;
						$subObject->OwnerID = 0;
					}
					$subObject->write();
					$DataObject->$IDkey = $subObject->ID;
				}
			}
			$RtnID = $DataObject->write();
			$f = new JSONDataFormatter();
			$json = $f->convertDataObject($DataObject);
			echo '{"success": true, "data":{"ID":"'.$RtnID.'","rows":[]}}'; //.$json.
		} else{
    		echo '{"success": false, "data":{}}';
		}
	}
	
	
	/**
	 * Saves a object into the system along with any has one relations, has many relations files and images,
	 * only saves upto 1 depth of has one relations on the parent object or the has many object.
	 */
	public function saveMultiObject() {
		$Object = $this->urlParams['ID'];
		$data = $_REQUEST;
		$MainObject = array();
		$ChildObjects = array();
		foreach ($data as $key=>$value) {
			$hasOnes = explode('_', $key);
			if(count($hasOnes) == 4) {
				//Has many objects from the main object, a mixed collection of values, and has ones
				//Example child object has many, Object Customer 0.customers.address.postcode = value
				// It is set up in such as way to be consumed by the processHasOne function. 
				$ChildObjects[$hasOnes[0]][$hasOnes[1]][$hasOnes[2].'_'.$hasOnes[3]] = $value;
			} elseif(count($hasOnes) == 3) {
				//Has One for child objects
				//Example of a child object has one would be Object Customer customer.address.postcode = value
				$ChildObjects[$hasOnes[0]][$hasOnes[1]][$hasOnes[2]] = $value;
			} elseif(count($hasOnes) == 2) {
				//Has one main object
				//Could also be an ID on the has one.
				//Example of a 2 depth object would be Object Customer status.statusName = value
				$MainObject[$key] = $value;
			} elseif(count($hasOnes) == 1) {
				//Single value -- main object
				//This could also be the ID of a has one.
				//Example of a single depth object would be Object Customer forename = value
				$MainObject[$key] = $value;
			}
		}
		//Process the top level object and it's has ones.
		if($DataObject = $this->processObjHasOne($Object, $MainObject)) {
			$DataObject->write();
			$has_many = $DataObject->has_many();
			//Loop through the rows for the has manys
			foreach($ChildObjects as $index=>$item) {
				//Get each of the has manys convert to a has one
				foreach($item as $key=>$value) {
					//Process each has one.
					if(isset($has_many[$key])) {
						$manyObject = $this->processObjHasOne($has_many[$key], $value);
						//Get the has one relations for the many object
						$has_one = $manyObject->has_one();
						$manyID = "";
						//Loop through the has_one relations
						foreach($has_one as $hKey=>$hValue) {
							//If the many relation object matches the has one object assume that is the
							//required relation object and set the manyID value.
							if($hValue == $DataObject->ClassName) {
								$manyID = $hKey.'ID';
								break;
							}
						}
						//Assign the manyID and save the object.
						$manyObject->$manyID = $DataObject->ID;
						$manyObject->write();
					}
				}
			}
			$RtnID = $DataObject->write();
			$f = new JSONDataFormatter();
			$json = $f->convertDataObject($DataObject);
			echo '{"success": true, "data":{"ID":"'.$RtnID.'","rows":[]}}'; //'.$json.'
		} else{
    		echo '{"success": false, "data":{}}';
		}
	}
	
	/**
	 * Private function for saving the realtionships of an object, called from saveMultiObject or updateMultiObject
	 *
	 */
	private function processObjHasOne($Object, $data, $ID = null) {
		$subObject = array();
		$thisObject = array();
		foreach ($data as $key=>$value) {
			$hasOnes = explode('_', $key);
			if(count($hasOnes) == 2) {
				$subObject[$hasOnes[0]][$hasOnes[1]] = $value;
			} elseif(count($hasOnes) == 1) {
				$thisObject[$key] = $value;
			}
		}
		$DataObject = null;
		if($ID == null) {
			$DataObject = Object::create($Object);
		} else {
			$DataObject = DataObject::get_by_id($Object, $ID);
		}
		if($DataObject != null){
			foreach($thisObject as $key=>$value) {
				$DataObject->$key = $value;
			}
			foreach($subObject as $key=>$value) {
				$IDkey = $key.'ID';
				$has_one = $DataObject->has_one();
				if($DataObject->$IDkey < 1) {
					$subObject = Object::create($has_one[$key]);
				} else {
					$subObject = DataObject::get_by_id($has_one[$key], (int)$DataObject->$IDkey);
				}
				foreach($value as $sKey=>$sValue) {
					$subObject->$sKey = $sValue;
				}
				$subObject->write();
				$DataObject->$IDkey = $subObject->ID;
			}
			foreach($_FILES as $key=>$value) {
				$IDkey = $key.'ID';
				$has_one = $DataObject->has_one();
				if(isset($has_one[$key])) {
					if($has_one[$key] == 'Image' || $has_one[$key] == 'File') {
						if($DataObject->$IDkey < 1) {
							$subObject = Object::create($has_one[$key]);
						} else {
							$subObject = DataObject::get_by_id($has_one[$key], (int)$DataObject->$IDkey);
							if($_FILES[$key]['tmp_name'] != '') {
								$subObject->delete();
								$subObject = Object::create($has_one[$key]);
							}
						}
						$file_path = "../assets/Uploads/";
						$fileName = basename(md5(time())."_".str_replace(" ", "_", $_FILES[$key]['name']));
						$file_path = $file_path . $fileName; 
						if(move_uploaded_file($_FILES[$key]['tmp_name'], $file_path)) {
							$subObject->Name = $fileName;
							$subObject->Title = $fileName;
							$subObject->Filename = $file_path;
							$subObject->ParentID = 3;
							$subObject->OwnerID = 0;
						}
						$subObject->write();
						$DataObject->$IDkey = $subObject->ID;
						unset($_FILES[$key]);
					}
				}
			}
			return $DataObject;
		} else{
    		return null;
		}
	}
	
	/**
	 * Updates a multilevel object, takes care of the files and images and has one relations,
	 * needs to be updated to include has many relations.
	 */
	public function updateMultiObject() {
		$Object = $this->urlParams['ID'];
		$data = $_REQUEST;
		$ID = (int)$data['ID'];
		unset($data['ID']);
		$MainObject = array();
		$ChildObjects = array();
		foreach ($data as $key=>$value) {
			$hasOnes = explode('_', $key);
			if(count($hasOnes) == 4) {
				$ChildObjects[$hasOnes[0]][$hasOnes[1]][$hasOnes[2].'_'.$hasOnes[3]] = $value;
			} elseif(count($hasOnes) == 3) {
				$ChildObjects[$hasOnes[0]][$hasOnes[1]][$hasOnes[2]] = $value;
			} elseif(count($hasOnes) == 2) {
				$MainObject[$key] = $value;
			} elseif(count($hasOnes) == 1) {
				$MainObject[$key] = $value;
			}
		}
		//Process the top level object and it's has ones.
		if($DataObject = $this->processObjHasOne($Object, $MainObject, $ID)) {
			$DataObject->write();
			$has_many = $DataObject->has_many();
			//Loop through the rows for the has manys
			foreach($ChildObjects as $index=>$item) {
				//Get each of the has manys convert to a has one
				$childID = null;
				foreach($item as $key=>$value) {
					$thisKey = $key;
					foreach($value as $sKey=>$sValue) {
						if($sKey == 'ID') {
							$childID = $sValue;
							unset($item->$thisKey);
							break;
						}
					}
				}
				foreach($item as $key=>$value) {
					//Process each has one.
					$manyObject = $this->processObjHasOne($has_many[$key], $value, $childID);
					$has_one = $manyObject->has_one();
					$manyID = "";
					foreach($has_one as $hKey=>$hValue) {
						if($hValue == $has_many[$key]) {
							$manyID = $hKey.'ID';
							break;
						}
					}
					$manyObject->$manyID = $DataObject->ID;
					$manyObject->write();
				}
			}
			$RtnID = $DataObject->write();
			$f = new JSONDataFormatter();
			$json = $f->convertDataObject($DataObject);
			echo '{"success": true, "data":{"ID":"'.$RtnID.'","rows":[]}}'; //'.$json.'
		} else{
    		echo '{"success": false, "data":{}}';
		}
	}
	
	public function comboObjects() {
		$objectName = $this->urlParams['ID'];
		if($Object = Object::create($objectName)) {
			if($fields = $Object->stat('combo_box')) {
				if ($objects = DataObject::get($objectName)) {
					$json = '{"results": '.$objects->count().', "rows":[';
					foreach ($objects as $obj) {
						$field0 = is_numeric($obj->$fields[0]) ? $obj->$fields[0] : '"'.$obj->$fields[0].'"';
						$field1 = is_numeric($obj->$fields[1]) ? $obj->$fields[1] : '"'.$obj->$fields[1].'"';
						$json .= '{"'.$fields[0].'":'.$field0.', "'.$fields[1].'":'.$field1.'},';
					}
					$json = substr($json, 0, -1);
					$json .= ']}';
					return $json;
				}
			}
		}
		return '{"results": 0, "rows":[]}';
	}
	
/**
************************************************************    Application Start    **************************************************
*/	
	
}

?>
