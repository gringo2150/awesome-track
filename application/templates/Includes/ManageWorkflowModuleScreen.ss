var moduleStore = new Ext.data.JsonStore({
	autoLoad: false,
	idProperty: 'ID',
	root: 'rows',
	totalProperty: 'results',
	fields: [
		{name: 'ID', type: 'int'},
		'name',
		'priority',
		{name: 'image', mapping: 'image.Filename', type: 'image'},
		'xPos',
		'yPos'
	],
	proxy: new Ext.data.HttpProxy({
		url: 'home/search/WorkflowCategory'
	})
});

var contextMenuStore = new Ext.data.JsonStore({
	autoLoad: false,
	idProperty: 'ID',
	root: 'rows',
	totalProperty: 'results',
	fields: [
		{name: 'ID', type: 'int'},
		'label',
		'priority',
		'action',
		{name: 'icon', mapping: 'icon', type: 'image'}
	],
	proxy: new Ext.data.HttpProxy({
		url: 'home/getChildObjects/ContextMenuItem'
	})
});

var addWorkflowCat = new Ext.Panel({
	flex: 1,
	layout: 'border',
	border: false,
	hidden: true,
	items: [{
		xtype: 'grid',
		region: 'center',
		id: 'browseModuleGrid',
		store: moduleStore,
		flex: 1,
		width: '100%',
		height: '100%',
		title: 'Manage Modules',
		frame: false,
		stripeRows: true,
		listeners: {
			rowdblclick: function(){
				var grid = Ext.getCmp('browseModuleGrid');
				var row = grid.getSelectionModel().getSelected();
				var ID = row.json.ID;
				var readOnly = false;
				var values = row.json;
				var module = (row.json.module != null) ? row.json.module : 'WorkflowCategory';
				if(module != 'WorkflowCategory') {
					executeFunctionByName(module + "_Edit", ID, readOnly, values);
				} else {
					editWorkflowModule(ID, readOnly, values);
				}
			}
		},
		tbar: new Ext.Toolbar({
			items: ['->',{
				text: 'Add Module',
				icon: 'application/images/toolbars/add.png',
				handler: function() {
					addWorkflowModule();
				}
			},{
				text: 'Edit Selected',
				icon: 'application/images/toolbars/edit.png',
				handler: function() {
					var grid = Ext.getCmp('browseModuleGrid');
					var row = grid.getSelectionModel().getSelected();
					var ID = row.json.ID;
					var readOnly = false;
					var values = row.json;
					var module = (row.json.module != null) ? row.json.module : 'WorkflowCategory';
					if(module != 'WorkflowCategory') {
						executeFunctionByName(module + "_Edit", ID, readOnly, values);
					} else {
						editWorkflowModule(ID, readOnly, values);
					}
				}
			},{
				text: 'Delete Selected',
				icon: 'application/images/toolbars/delete.png',
				handler: function() {
					deleteWorkflowModule();
				}
			}]
		}),
		colModel: new Ext.grid.ColumnModel({
       		defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', canSearch: true, incSearch: false, hidden: true},
				{header: 'Icon', dataIndex: 'image', renderer:renderIcon},
				{header: 'Module Name', dataIndex: 'name'},
				{header: 'Menu Priority', dataIndex: 'priority'},
				{header: 'Home X Pos', dataIndex: 'xPos'},
				{header: 'Home Y Pos', dataIndex: 'yPos'}
			]
   		}),
		sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
		loadMask: true,
		viewConfig: {
			forceFit: true
		}
	}]
});

//The standard module add form.
var addWorkflowModule = function() {
	parseForm('moduleAdd.frm', 'New Module', function(obj) {
		/*** Start Combo Store Config ***/
		obj.module.store = new Ext.data.ArrayStore({
			fields: [
				'displayText'
			],
			data: InstalledModules
		});
		obj.module.displayField = 'displayText';
		obj.module.valueField = 'displayText';
		/*** End Combo Store Config ***/
		
		/*** Button Config Start ***/
		//Cancel Button
		obj.cancelButton.handler = function() {
			obj.window.close();
		};
		//Save Button
		obj.saveButton.handler = function() {
			var module = (obj.module.getValue() != '') ? obj.module.getValue() : 'WorkflowCategory';
			if(module != 'WorkflowCategory') {
				executeFunctionByName(module + "_Add", window, obj.form);
			} else {
				obj.form.submit({
					url: 'home/saveSingleObject/WorkflowCategory',
					waitMsg: 'Creating new module...',
					submitEmptyText: false,
					params: {
						module: obj.module.getRawValue()
					},
					success: function(fp, o){
						Ext.Msg.alert('Success', 'New module has been added.');
						fp.reset();
						moduleStore.load();
						obj.window.close();
					}
				});
			}		
		};
		/*** End Button Config ***/
		obj.window.show();
	});
}

//The standard module edit form.
var editWorkflowModule = function(ID, readOnly, values) {
	//Check if ID or values is available, if not prompt the user.
	if(ID != undefined || values != undefined) {
		//If we don't have an ID but we have a values, populate the ID from there.
		if(ID == null || ID == undefined){
			ID = values.ID;
		}
		parseForm('moduleEdit.frm', 'Edit Module', function(obj) {
			/*** Button Config Start ***/
			//Cancel Button
			obj.cancelButton.handler = function() {
				obj.window.close();
			};
			//Save Button
			obj.saveButton.handler = function() {
				obj.form.submit({
					url: 'home/updateSingleObject/WorkflowCategory',
					waitMsg: 'Updating workflow module...',
					params: {ID: ID},
					submitEmptyText: false,
					success: function(fp, o){
						Ext.Msg.alert('Success', 'Module has been updated.');
						fp.reset();
						moduleStore.load();
						obj.window.close();
					}
				});
			};
			//Add Context Button
			obj.addContextButton.handler = function() {
				parseForm('contextMenuItem.frm', 'Add Context Item', function(sObj) {
					/*** Start Button Config ***/
					sObj.cancelButton.handler = function() {
						sObj.window.close();
					};
					sObj.saveButton.handler = function() {
						sObj.form.submit({
							url: 'home/saveSingleObject/ContextMenuItem',
							waitMsg: 'Adding context item...',
							submitEmptyText: false,
							params:{
								moduleID: ID
							},
							success: function(fp, o){
								Ext.Msg.alert('Success', 'Context has been added.');
								fp.reset();
								obj.moduleContextTable.store.load({
									params: {
										column: 'moduleID',
										value: ID
									}
								});
								sObj.window.close();
							}
						});
					};
					/*** End Button Config ***/
				});
			};
			//Delete Context Button
			obj.deleteContextButton.handler = function() {
			};
			/*** Button Config End ***/
			
			/*** Table Config Start ***/
			var contextMenuStore = new Ext.data.JsonStore({
				autoLoad: false,
				idProperty: 'ID',
				root: 'rows',
				totalProperty: 'results',
				fields: [
					{name: 'ID', type: 'int'},
					'label',
					'priority',
					'action',
					'icon'
				],
				proxy: new Ext.data.HttpProxy({
					url: 'home/getChildObjects/ContextMenuItem'
				})
			});
			var contextMenuColumnModel = new Ext.grid.ColumnModel({
				columns: [
					new Ext.grid.RowNumberer({width: 20}),
					{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', canSearch: true, incSearch: false, hidden: true},
					{header: 'Icon', dataIndex: 'icon', renderer:renderIconObject},
					{header: 'Context Label', dataIndex: 'label'},
					{header: 'Menu Priority', dataIndex: 'priority'}
				]
   			});
			obj.moduleContextTable.reconfigure(contextMenuStore, contextMenuColumnModel);
			obj.moduleContextTable.store.load({
				params: {
					column: 'moduleID',
					value: ID
				}
			});
			/*** Table Config End ***/
			obj.window.show();
			if(values != undefined || values != null) {
				obj.form.setValues(values);
				obj.image.setValue(values.image.Name);
			} else {
				obj.form.load({url:'home/selectSingleObject/WorkflowCategory/'+ID, waitMsg:'Loading record please wait...', fileUpload: true});
			}
		});
	} else {
		Ext.Msg.alert('Error','No module has been selected, please select a module to edit.');
	}
};

//Delete a module.
var deleteWorkflowModule = function(ID) {
	var selection = Ext.getCmp('browseModuleGrid').getSelectionModel().getSelections();
	if(selection[0] != undefined) {
		if(ID == null || ID == undefined) {
			ID = selection[0].id;
		}
		Ext.Msg.confirm('Are you sure?', 'Delete the selected module?', function(btn) {
			if(btn == 'yes') {
				loadingMask.show();	
				Ext.Ajax.request({
					url: 'home/deleteSingleObject/WorkflowCategory',
					waitMsg: 'Deleting the selected module...',
					success: function(data){
						loadingMask.hide();
						Ext.Msg.confirm('Success', 'Module has been deleted, a refresh is required to complete this process, refresh now?', function(btn) {
							if (btn == 'yes') {
								window.location.reload(true);
							} else {
								moduleStore.load();
							}
						});
					},
					failure: function(obj, data){
						loadingMask.hide();
						Ext.Msg.alert('Error', data.msg);
					},
					params: { ID: ID }
				});
			}
		});
	} else {
		Ext.Msg.alert('Error','No module has been selected, please select a module to delete.');
	}
};
