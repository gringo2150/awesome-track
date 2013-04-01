<?php

class SearchModule extends WorkflowCategory {
	
	public static $db = array(  
		"object"=>"Text",
		"addButton"=>"Text",
		"addButtonTitle"=>"Text",
		"addButtonHandler"=>"Text",
		"editButton"=>"Text",
		"editButtonTitle"=>"Text",
		"editButtonHandler"=>"Text",
		"deleteButton"=>"Text",
		"deleteButtonTitle"=>"Text",
		"deleteButtonHandler"=>"Text",
		"groupedView"=>"Text",
		"groupField"=>"Text",
		"extraParams"=>"Text",
		"searchURL"=>"Text",
		"setAsHome"=>"Boolean"
	);
	
	public static $has_one = array(

	);
	
	public static $has_many = array(

	);
	
	public function onBeforeWrite() {
		
		parent::onBeforeWrite();
	}
	
	public function getTemplate() {
		$module = $this->renderWith(array('SearchModule'));
		return $module;
	}
	
	public function __getNavigation() {
		/* ADD BUTTON START */
		$addButtonTitle = ($this->addButtonTitle != "" || $this->addButtonTitle != null) ? $this->addButtonTitle : "Add {$this->object}";
		$addButtonHandlerDefault = "
			metaFormParser(
				SearchModule_Store, 
				Ext.getCmp('SearchModule').getColumnModel(), 
				Ext.getCmp('SearchModule'), 
				Ext.getCmp('SearchModule').searchObject
			);
		";
		$addButtonHandler = ($this->addButtonHandler != "" || $this->addButtonHandler != null) ? $this->addButtonHandler : $addButtonHandlerDefault;
		$addButton = "
			Ext.getCmp('SearchModule_AddButton').setText('{$addButtonTitle}');
			Ext.getCmp('SearchModule_AddButton').handler = function() {
				{$addButtonHandler}
			};
		";
		if($this->addButton == "true") {
			$addButton .= "
				Ext.getCmp('SearchModule_AddButton').show();
			";
		} else {
			$addButton .= "
				Ext.getCmp('SearchModule_AddButton').hide();
			";
		}
		/* ADD BUTTON END */
		/* EDIT BUTTON START */
		$editButtonTitle = ($this->editButtonTitle != "" || $this->editButtonTitle != null) ? $this->editButtonTitle : "Edit {$this->object}";
		$editButtonHandlerDefault = "
			var selection = Ext.getCmp('SearchModule').getSelectionModel().getSelections();
			var formData = undefined;
			if(selection[0] != undefined) {
				formData = selection[0].json;
				metaFormParser(
					SearchModule_Store, 
					Ext.getCmp('SearchModule').getColumnModel(), 
					Ext.getCmp('SearchModule'), 
					Ext.getCmp('SearchModule').searchObject,
					formData
				);
			} else {
				Ext.Msg.alert('Error','No item has been selected, please select an item to edit.');
			}
			
		";
		$editButtonHandler = ($this->editButtonHandler != "" || $this->editButtonHandler != null) ? $this->editButtonHandler : $editButtonHandlerDefault;
		$editButton = "
			Ext.getCmp('SearchModule_EditButton').setText('{$editButtonTitle}');
			Ext.getCmp('SearchModule_EditButton').handler = function() {
				var selection = Ext.getCmp('SearchModule').getSelectionModel().getSelected();
				if (selection != null && selection != undefined) {
					var ID = selection.json.ID ? selection.json.ID : null;
					{$editButtonHandler}
				}
			};
			var rowListeners = Ext.getCmp('SearchModule').events.rowdblclick;
			if(rowListeners !== true) {
				if(rowListeners.listeners.length > 0) {
					Ext.each(rowListeners.listeners, function(item, index) {
						Ext.getCmp('SearchModule').un('rowdblclick',item.fn);
					});
				}
			}
			Ext.getCmp('SearchModule').on('rowdblclick',function(grid, index, event){
				var selection = Ext.getCmp('SearchModule').getSelectionModel().getSelected();
				if (selection != null && selection != undefined) {
					if(event.target.type != \"button\") {
						var ID = selection.json.ID ? selection.json.ID : null;
						{$editButtonHandler}
					}
				}
			});
		";
		if($this->editButton == "true") {
			$editButton .= "
				Ext.getCmp('SearchModule_EditButton').show();
			";
		} else {
			$editButton .= "
				Ext.getCmp('SearchModule_EditButton').hide();
			";
		}
		/* EDIT BUTTON END */
		/* DELETE BUTTON START */
		$deleteButtonTitle = ($this->deleteButtonTitle != "" || $this->deleteButtonTitle != null) ? $this->deleteButtonTitle : "Delete {$this->object}";
		$deleteButtonHandlerDefault = "
			var selection = Ext.getCmp('SearchModule').getSelectionModel().getSelections();
			var ID = undefined;
			if(selection[0] != undefined) {
				ID = selection[0].id;
				Ext.Msg.confirm('Are you sure?', 'Delete the selected item?<br />This action cannot be undone', function(btn) {
					if(btn == 'yes') {
						Ext.getCmp('SearchModule').loadMask.show();	
						Ext.Ajax.request({
							url: 'home/deleteSingleObject/{$this->object}',
							waitMsg: 'Deleting the selected item...',
							params: { ID: ID },
							success: function(data){
								Ext.getCmp('SearchModule').loadMask.hide();
								Ext.getCmp('SearchModule').store.load();
							},
							failure: function(obj, data){
								Ext.getCmp('SearchModule').loadMask.hide();
								Ext.Msg.alert('Error', data.msg);
							}
						});
					}
				});
			} else {
				Ext.Msg.alert('Error','No item has been selected, please select an item to delete.');
			}
			
		";
		$deleteButtonHandler = ($this->deleteButtonHandler != "" && $this->deleteButtonHandler != null) ? $this->deleteButtonHandler : $deleteButtonHandlerDefault;
		$deleteButton = "
			Ext.getCmp('SearchModule_DeleteButton').setText('{$deleteButtonTitle}');
			Ext.getCmp('SearchModule_DeleteButton').handler = function() {
				var selection = Ext.getCmp('SearchModule').getSelectionModel().getSelected();
				if (selection != null && selection != undefined) {
					var ID = selection.json.ID ? selection.json.ID : null;
					{$deleteButtonHandler}
				}
			};
		";
		if($this->deleteButton == "true") {
			$deleteButton .= "
				Ext.getCmp('SearchModule_DeleteButton').show();
			";
		} else {
			$deleteButton .= "
				Ext.getCmp('SearchModule_DeleteButton').hide();
			";
		}
		if($this->groupedView == "true") {
			$grouping = "
				SearchModule_Store.sortField = \"{$this->groupField}\";
				SearchModule_Store.groupField = \"{$this->groupField}\";
				SearchModule_Store.groupDir = \"ASC\";
				SearchModule_Store.sortInfo = {
					field: \"{$this->groupField}\",
					direction: 'ASC'
				};
				";
		} else {
			
			$grouping = "
				SearchModule_Store.sortField = null;
				SearchModule_Store.groupField = null;
				SearchModule_Store.groupDir = null;
				SearchModule_Store.sortInfo = {
					field: \"ID\",
					direction: 'DESC'
				};
			";
		}
		$extraParams = ($this->extraParams != null && $this->extraParams != "") ? ",extraParams: '{$this->extraParams}'" : "";
		$searchURL = ($this->searchURL == "") ? "home/search/{$this->object}" : "{$this->searchURL}{$this->object}";
		return "
			SearchModule.show();
			{$addButton}
			{$editButton}
			{$deleteButton}
			Ext.getCmp('SearchModule').setTitle('{$this->name}');
			Ext.getCmp('SearchModule').searchObject = '{$this->object}';
			SearchModule_Store.proxy.setUrl('{$searchURL}', true);
			SearchModule_Store.removeAll();
			SearchModule_Store.storeRefresh = true;
			SearchModule_Store.baseParams = {start: 0,limit: 20,meta: true,columnModel: true{$extraParams}, columns: ''};
			{$grouping}
			SearchModule_Store['tableFields[]'] = [];
			SearchModule_Store.load();
		";
	}
	
	public function getNavigation() {
		$nav = $this->__getNavigation();
		$extra = '';
		if($this->setAsHome == true) {
			$extra = "
				setTimeout(function(){
					for (var i=0; i<subNavigationHolder.items.items.length; i++) {
						subNavigationHolder.items.items[i].hide();
					}
					{$nav}
				}, 1000);";
		}
		return "
			{$nav}
		";
	}
	
	public function moduleAddScreen() {
		$addForm = $this->renderWith(array('SearchModule_Add'));
		return $addForm;
	}
	
	public function moduleEditScreen() {
		$editForm = $this->renderWith(array('SearchModule_Edit'));
		return $editForm;
	}
	
}

?>
