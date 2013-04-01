<?php
$val .= <<<SSVIEWER
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<link href="favicon.ico" rel="shortcut icon" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="ExportModule/css/ExportModule.css" />
<link rel="stylesheet" type="text/css" href="ExportModule/css/ReportModule.css" />
<link rel="stylesheet" type="text/css" href="application/javascript/ext/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="application/javascript/ext/resources/css/xtheme-pluto.css" />
<link rel="stylesheet" type="text/css" href="application/css/layout.css" />
<link rel="stylesheet" type="text/css" href="application/css/icons.css" />
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/fileuploadfield/css/fileuploadfield.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/IconCombo.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/XCheckbox.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/ColorField.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/ux-all.css" />
<script type="text/javascript" src="application/javascript/ext/adapter/ext/ext-base-debug.js"></script>
<script type="text/javascript" src="application/javascript/ext/ext-all-debug.js"></script>
<script type="text/javascript" src="application/javascript/ext/ux/ux-all.js"> </script>
<script type="text/javascript" src="application/javascript/ext/debug.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/jsonp.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/IconCombo.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/XCheckbox.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/ColorField.js"> </script>
<script type="text/javascript" src="application/javascript/jquery.js"></script>
<script type="text/javascript" src="application/javascript/MetaForm.js"></script>
<script type="text/javascript" src="application/javascript/FormParser.js"></script>

SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

<script type="text/javascript" src="application/javascript/FormBuilder/formBuilder.js"></script>

SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

<script type="text/javascript" src="application/javascript/Utils/cellRenderers.js"></script>
<script type="text/javascript" src="application/javascript/Utils/dateCalculations.js"></script>
<script type="text/javascript" src="workflows.script"></script>

SSVIEWER;
$val .=  $item->XML_val("moduleScripts",null,true) ;
 $val .= <<<SSVIEWER

<script>
if (Ext.isIE) {
	Ext.enableGarbageCollector = false;
}

var loadingMask = new Ext.LoadMask(Ext.getBody(), {msg: "Preforming action please wait..."});

Ext.WindowMgr.zseed = 11000;
var iblWinMgr = new Ext.WindowGroup();
iblWinMgr.zseed = 10000;

var main = null;

var isAdmin = 
SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER
1
SSVIEWER;
 } else { ;
 $val .= <<<SSVIEWER
0
SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER
;

var main = Object();

function executeFunctionByName(functionName/*, args */) {
  var context = window;
  var args = Array.prototype.slice.call(arguments).splice(1);
  /*var namespaces = functionName.split(".");
  var func = namespaces.pop();
  for(var i = 0; i < namespaces.length; i++) {
    context = context[namespaces[i]];
  }*/
  return window[functionName].apply(this, args);
}

/*********************
System Variables

Modules, the list of modules installed in the system
Objects, the list of objects installed in the system.
*********************/

var InstalledModules = [
SSVIEWER;
$val .=  $item->XML_val("workflowModules",null,true) ;
 $val .= <<<SSVIEWER
];
var InstalledObjects = [
SSVIEWER;
$val .=  $item->XML_val("databaseObjects",null,true) ;
 $val .= <<<SSVIEWER
];

/*******************
System Vars END
*******************/

Ext.onReady(function(){
	
	Ext.Ajax.timeout = 120000;
	Ext.BLANK_IMAGE_URL = '
SSVIEWER;
$val .=  $item->XML_val("BaseHref",null,true) ;
 $val .= <<<SSVIEWER
application/javascript/ext/resources/images/default/s.gif';
	Ext.QuickTips.init(false);
		
	var HomeMenu = [

SSVIEWER;
 if($item->hasValue("isParticipant")) {  ;
 $val .= <<<SSVIEWER

{
	text: 'Help',
	icon: 'application/images/built_in_menus/help.png',
	tooltip: 'Need Help?, opens up the help documents panel, here you can find out how aspects of the system work.',
	handler: function() {
		window.open('application/images/UserHelp.pdf', '_blank');
	}
},{
	text: 'Give feedback',
	icon: 'application/images/built_in_menus/questions2.png',
	tooltip: 'Begin or continue to answer the questions set out for you. You can save your progress at any point and return to answering at a later time.',
	handler: function() {
		var selection = Ext.getCmp('ParticipantGrid').getSelectionModel().getSelected();
		var ID = selection.json.ParticipantID ? selection.json.ParticipantID : null;
		var ProjectID = selection.json.ProjectID ? selection.json.ProjectID : null;
		if(ID != null && ProjectID != null) {
			respondeeAnswerQuestion(ID, ProjectID);
		} else {
			Ext.Msg.alert("Choose Participant", "No participant selected. You must first select a participant from the table on the right");
		}
	}
},{
	text: 'Change Password',
	icon: 'application/images/built_in_menus/key.png',
	tooltip: 'Change the password you use to login to the system.',
	handler: function() {
		var ID = 
SSVIEWER;
$val .=  $item->obj("CurrentMember",null,true)->XML_val("ID",null,true) ;
 $val .= <<<SSVIEWER
;
		changePassword(ID);
	}
}

SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER


SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

{
	text: 'Help',
	icon: 'application/images/built_in_menus/help.png',
	tooltip: 'Need Help?, opens up the help documents panel, here you can find out how aspects of the system work.',
	handler: function() {
		alert('Load help menu');
	}
}

SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

];

/*
{
	text: 'View Calendar',
	icon: 'application/images/built_in_menus/calendar.png',
	tooltip: 'Your calendar, this contains all the company wide events and your follow up actions.',
	handler: function() {
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		HomeWorkflowCalandar.show();
		Ext.getCmp('main').doLayout();
	}
},
*/

SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

var AdministrationMenu = [{
	text: 'Manage Modules',
	icon: 'application/images/built_in_menus/module_edit.png',
	tooltip: 'Module Manager, this section allows for new modules to be added to the system, new modules can either be a workflow or a plugin.',
	handler: function() {
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		addWorkflowCat.show();
		moduleStore.load();
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Manage Menus',
	icon: 'application/images/built_in_menus/menu_edit.png',
	tooltip: 'Menu Manager, this section allows for new menus to be added to the system, new menus appear under modules and can either be a workflow or a plugin.',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		addWorkflowItem.show();
		itemStore.load();
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Import Data',
	icon: 'application/images/built_in_menus/import_data.png',
	tooltip: 'Allows the import of data into the system from CSV files.',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		ImportModule.show();
		Ext.getCmp('ImportModule_Center').setTitle('Import Data');
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Export Data',
	icon: 'application/images/built_in_menus/export_data.png',
	tooltip: 'Allows queries to be built and the data viewed and used in reports.',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		ExportModule.show();
		Ext.getCmp('ExportModule_North').setTitle('Export Data');
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'System Properties',
	icon: 'application/images/built_in_menus/system_props.png',
	tooltip: '',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		SearchModule.show();
		Ext.getCmp('SearchModule_AddButton').setText('Add System Property');
		Ext.getCmp('SearchModule_EditButton').setText('Edit System Property');
		Ext.getCmp('SearchModule').setTitle('System Properties Search');
		SearchModule.object = 'SystemParameter';
		SearchModule_Store.proxy.setUrl('home/search/SystemParameter', true);
		SearchModule_Store.removeAll();
		SearchModule_Store.baseParams = {start: 0,limit: 20,meta: true,columnModel: true};
		SearchModule_Store.load();
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Form Builder',
	icon: 'application/images/built_in_menus/form_builder.png',
	tooltip: '',
	handler: function(){
		formBuilderWindow();
	}
}];

SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER


var HomePanel = new Ext.Toolbar({
	flex: 2, 
	layout: 'vbox',
	height: '100%',
	autoWidth: true,
	width: 'auto', 
	layoutConfig: { 
		align: 'stretch', 
		pack: 'start'
	}, 
	hidden: false, 
	defaults: { 
		margins: '5 5 0 5',
		 
		cls: 'leftButton' 
	},
	items: HomeMenu	
});


SSVIEWER;
$val .=  $item->XML_val("modulePanels",null,true) ;
 $val .= <<<SSVIEWER



SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER
 
var AdministrationPanel = new Ext.Toolbar({
	flex: 2, 
	layout: 'vbox',
	height: '100%',
	autoWidth: true,
	width: 'auto', 
	layoutConfig: { 
		align: 'stretch', 
		pack: 'start'
	}, 
	hidden: true, 
	defaults: { 
		margins: '5 5 0 5',
		 
		cls: 'leftButton' 
	},
	items: AdministrationMenu
});

SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER


var subNavigationHolder = new Ext.Panel({
	flex: 2,
	border: false,
	id: 'subNavigationHolder',
	items: [
		HomePanel
		
SSVIEWER;
$val .=  $item->XML_val("moduleNaviagtionPanels",null,true) ;
 $val .= <<<SSVIEWER
 
		
SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

			,AdministrationPanel
		
SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

	]
});
	
var mainNavPanel = {
	xtype: 'panel',
	id: 'mainNavPanel',
	title: 'Navigation',
	region:'west',
	collapsible: false,
	margins: '5 0 5 5',
	width: 200,
	minSize: 100,
	maxSize: 225,
	layout:'vbox',
	layoutConfig: {
		align : 'stretch',
		pack  : 'start'
	},
	items: [
		subNavigationHolder,
		{ 
			border: false, 
			layoutConfig: {
				align: 'stretch',
				pack: 'end',
				width: '100%'				
			},
			items: [
				
SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

				new Ext.Button({
					cls: 'x-toolbar',
					width: '100%',
					text: 'Home',
					icon: 'application/images/built_in_menus/home.png',
					handler: function() {
						for (var i=0; i<subNavigationHolder.items.items.length; i++) {
							subNavigationHolder.items.items[i].hide();
						}
						HomePanel.show();
						for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
							Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
						}
						homeControlWorkflow.show();
						Ext.getCmp('main').doLayout();
					}
				})
				
SSVIEWER;
$val .=  $item->XML_val("moduleNavigation",null,true) ;
 $val .= <<<SSVIEWER

				, new Ext.Button({
					cls: 'x-toolbar',
					width: '100%',
					text: 'Administration',
					icon: 'application/images/built_in_menus/administration.png',
					handler: function() {
						for (var i=0; i<subNavigationHolder.items.items.length; i++) {
							subNavigationHolder.items.items[i].hide();
						}
						AdministrationPanel.show();
						for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
							Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
						}
						adminWorkflow.show();
						Ext.getCmp('main').doLayout();
					}
				})
				
SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

			]
		}
	]	
};

	var mainMenu = new Ext.Toolbar({
	items : [
	'->',
	'Logged in as 
SSVIEWER;
$val .=  $item->obj("CurrentMember",null,true)->XML_val("FirstName",null,true) ;
 $val .= <<<SSVIEWER
 
SSVIEWER;
$val .=  $item->obj("CurrentMember",null,true)->XML_val("Surname",null,true) ;
 $val .= <<<SSVIEWER
',
	'-',
	{
		text: 'Logout',
		icon: 'application/images/login/logout.png',
		handler: function() {
			Ext.MessageBox.confirm('Confirm', 'Are you sure you want to logout?', function(button){
				if (button == 'yes') {
					loadingMask.show();
					location.href = 'Security/logout';
				}
			});
		}
	}]
});

/*
{
		text: 'Home',
		icon: 'application/images/built_in_menus/home.png',
		menu: HomeMenu
	},
	topMenuNavigation
	< if adminPermissionCheck >
	{
		text: 'Administration',
		icon: 'application/images/built_in_menus/administration.png',
		menu: AdministrationMenu
	},
	< end_if >
	
*/

    
	
SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER


var homeControlWorkflow = new Ext.Panel({
	hidden: false,
	border: false,
	layout: 'border',
	defaults: {
    	split: true
    },
	items: [{
		xtype: 'panel',
		title: 'Home',
		frame: false,
		layout: 'absolute',
		region: 'center',
		defaults: {
			height: 60,
			width: '150'
		},
		items: []
	}]
});


SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER


	
SSVIEWER;
$val .=  $item->XML_val("includeModulesTemplates",null,true) ;
 $val .= <<<SSVIEWER

	
SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

		var adminWorkflow = new Ext.Panel({
	hidden: true,
	id: 'adminWorkflow',
	border: false,
	layout: 'border',
	items: [{
		xtype: 'panel',
		region: 'center',
		title: 'Administration',
		frame: false,
		layout: 'absolute',
		defaults: {
			height: 60,
			width: '150'
		},
		items: [
			/*new Ext.Button({
				text: 'Manage Modules',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 20,
				iconAlign: 'top',
				handler: function() {
					for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
						Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
					}
					addWorkflowCat.show();
					moduleStore.load();
					main.doLayout();
				}
			}),
			new Ext.Button({
				text: 'Manage Menus',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 100,
				iconAlign: 'top',
				handler: function() {
					for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
						Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
					}
					addWorkflowItem.show();
					itemStore.load();
					main.doLayout();
				}
			}),
			new Ext.Button({
				text: 'Import Data',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 180,
				iconAlign: 'top',
				handler: function() {
					
				}
			}),
			new Ext.Button({
				text: 'Export Data',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 260,
				iconAlign: 'top',
				handler: function() {
					
				}
			}),
			new Ext.Button({
				text: 'System Properties',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 190,
				y: 100,
				iconAlign: 'top',
				handler: function() {
					for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
						Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
					}
					systemPropertiesPanel.show();
					main.doLayout();
				}
			}),
			new Ext.Button({
				text: 'Form Builder',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 360,
				y: 100,
				iconAlign: 'top',
				handler: function() {
					formBuilderWindow();
				}
			})*/
		]
	}]
});

	
SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

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

	var itemStore = new Ext.data.JsonStore({
	autoLoad: false,
	idProperty: 'ID',
	root: 'rows',
	totalProperty: 'results',
	fields: [
		{name: 'ID', type: 'int'},
		'name',
		'priority',
		{name: 'image', mapping: 'image.Filename', type: 'image'},
		{name: 'category', mapping: 'category.name'},
		'xPos',
		'yPos',
		'showOnHome'
	],
	proxy: new Ext.data.HttpProxy({
		url: 'home/search/WorkflowItem'
	})
});

var addWorkflowItem = new Ext.Panel({
	layout: 'border',
	border: false,
	flex: 1,
	hidden: true,
	items: [{
		xtype: 'grid',
		region: 'center',
		store: itemStore,
		flex: 1,
		width: '100%',
		height: '100%',
		title: 'Manage Workflow Items',
		id: 'browseItemGrid',
		frame: false,
		listeners: {
			rowdblclick: function() {
				editWorkflowItem();
			}
		},
		tbar: new Ext.Toolbar({
			items: ['->',{
				text: 'Add Workflow Item',
				icon: 'application/images/toolbars/add.png',
				handler: function() {
					addNewWorkflowItem();
				}
			},{
				text: 'Edit Selected',
				icon: 'application/images/toolbars/edit.png',
				handler: function() {
					editWorkflowItem();
				}
			},{
				text: 'Delete Selected',
				icon: 'application/images/toolbars/delete.png',
				handler: function() {
					deleteWorkflowItem();
				}
			}]
		}),
		colModel: new Ext.grid.ColumnModel({
       		defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', hidden: true},
				{header: 'Icon', dataIndex: 'image', renderer:renderIcon},
				{header: 'Item Name', dataIndex: 'name'},
				{header: 'Module Category', dataIndex: 'category'},
				{header: 'Menu Priority', dataIndex: 'priority'},
				{header: 'X Pos', dataIndex: 'xPos'},
				{header: 'Y Pos', dataIndex: 'yPos'}
			]
    	}),
		sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
		loadMask: true,
		viewConfig: {
			forceFit: true
		}
	}]
});

var editWorkflowItem = function(ID) {
	var selection = Ext.getCmp('browseItemGrid').getSelectionModel().getSelections();
	//console.log(selection);
	if(selection[0] != undefined) {
		if(ID == null || ID == undefined) {
			ID = selection[0].id;
		}
		var window = new Ext.Window({
			title: 'Edit Item',
			icon: 'application/images/toolbars/edit.png',
			layout: 'fit',
			height: 260,
			width: 620,
			border: false,
			items: [
				new Ext.form.FormPanel({
					border: false,
					id: 'edit-item-form',
					height: '100%',
					width: '100%',
					frame: true,
					fileUpload: true,
					submitEmptyText: false,
					reader: new Ext.data.JsonReader({
						idProperty: 'ID',
						successProperty: 'success',
						root: 'data',
						fields: [
							'name',
							'priority',
							'action',
							'tooltip',
							'categoryID',
							{name:'image', mapping: 'image.Name'},
							{name: 'category', mapping: 'category.name'},
							'xPos',
							'yPos',
							{name:'showOnHome', type:'boolean'}
						]
					}),
					margins: '5 5 5 5',
        			defaults: {
            			anchor: '-18',
            			allowBlank: false,
            			msgTarget: 'side'
        			},
        			defaultType: 'textfield',
					items: [{
						fieldLabel: 'Workflow Name',
						emptyText: 'Enter a name for this item, this name will be what appears on the left menu',
						name: 'name',
						allowBlank:false
					},{
						fieldLabel: 'Workflow Tooltip',
						emptyText: 'Enter a tooltip to display when this item is hovered over',
						name: 'tooltip',
						allowBlank:false
					},new Ext.ux.IconCombo({
						fieldLabel: 'Module',
						store: new Ext.data.ArrayStore({
							fields: ['ID', 'name', 'image'],
							data: [
SSVIEWER;
$val .=  $item->XML_val("moduleComboList",null,true) ;
 $val .= <<<SSVIEWER
]
						}),
						valueField: 'ID',
						displayField: 'name',
						iconClsField: 'image',
						triggerAction: 'all',
						emptyText: 'Select the module that this item shall be attached to',
						mode: 'local',
						allowBlank: false,
						width: 160,
						name: 'category',
						hiddenName: 'categoryID'
					}),{
						xtype: 'fileuploadfield',
            			emptyText: 'Browse for an image...',
            			fieldLabel: 'Workflow Icon',
            			name: 'image',
            			buttonText: 'Browse for File',
            			buttonCfg: {
                			icon: 'application/images/buttons_icons/image_add.png'
            			}
					},{
						fieldLabel: 'Menu Priority',
						emptyText: 'Enter a number between 1 and 9999, this is used to order the menu items',
						name: 'priority',
						allowBlank:true
					},{
						fieldLabel: 'Workflow Action',
						emptyText: 'Select an action for this menu to run upon selection',
						name: 'action',
						allowBlank:true
					},{
    					xtype: 'compositefield',
    					fieldLabel: 'Home Page Conf',
    					items: [{
            				xtype: 'textfield',
            				name: 'xPos',
            				emptyText: 'x position',
            				width: 125
        				},{
            				xtype: 'textfield',
            				name: 'yPos',
            				emptyText: 'y position',
            				width: 125
        				},{
            				xtype: 'xcheckbox',
            				name: 'showOnHome',
            				boxLabel: 'Show module on home screen?',
            				submitOffValue: 0, 
							submitOnValue: 1,
            				flex: 1
        				}]
        			}],
					buttons: [{
						text: 'Cancel',
						handler: function() {
							window.close();
						}
					},{
						text: 'Save',
						handler: function() {
							Ext.getCmp('edit-item-form').getForm().submit({
								url: 'home/updateSingleObject/WorkflowItem',
								waitMsg: 'Updating workflow item...',
								params: {ID: ID},
								submitEmptyText: false,
								success: function(fp, o){
									Ext.Msg.alert('Success', 'Item has been updated.');
									fp.reset();
									itemStore.load();
									window.close();
								}
							});
						}
					}]
				})
			]
		});
		window.show();
		Ext.getCmp('edit-item-form').getForm().load({url:'home/selectSingleObject/WorkflowItem/'+ID, waitMsg:'Loading record please wait...', fileUpload: true});
	} else {
		Ext.Msg.alert('Error','No item has been selected, please select a module to edit.');
	}
};

var addNewWorkflowItem = function() {
	var window = new Ext.Window({
		title: 'Add New Item',
		icon: 'application/images/toolbars/edit.png',
		layout: 'fit',
		height: 260,
		width: 620,
		border: false,
		items: [{
			xtype: 'form',
			id: 'new-item-form',
			labelWidth: 100,
       		frame: true,
       		fileUpload: true,
       		submitEmptyText: false,
       		width: '100%',
       		height: '100%',
       		margins: '0 0 5 0',
       		defaults: {
       	    	anchor: '-18',
       	    	allowBlank: false,
       	    	msgTarget: 'side'
       		},
       		defaultType: 'textfield',
			items: [{
				fieldLabel: 'Workflow Name',
				emptyText: 'Enter a name for this workflow, this name will be what appears on the left menu',
				name: 'name',
				allowBlank:false
			},{
				fieldLabel: 'Workflow Tooltip',
				emptyText: 'Enter a tooltip to display when this item is hovered over',
				name: 'tooltip',
				allowBlank: false
			},new Ext.ux.IconCombo({
				fieldLabel: 'Module',
				store: new Ext.data.ArrayStore({
					fields: ['ID', 'name', 'image'],
					data: [
SSVIEWER;
$val .=  $item->XML_val("moduleComboList",null,true) ;
 $val .= <<<SSVIEWER
]
				}),
				valueField: 'ID',
				displayField: 'name',
				iconClsField: 'image',
				triggerAction: 'all',
				emptyText: 'Select the module that this item shall be attached to',
				mode: 'local',
				allowBlank: false,
				width: 160,
				name: 'category',
				hiddenName: 'categoryID'
			}),{
				xtype: 'fileuploadfield',
        		emptyText: 'Browse for an image...',
       	    	fieldLabel: 'Workflow Icon',
       	    	name: 'image',
       	    	buttonText: 'Browse for File',
       	    	buttonCfg: {
       	    	    icon: 'application/images/buttons_icons/image_add.png'
       	    	}
			},{
				fieldLabel: 'Menu Priority',
				emptyText: 'Enter a number between 1 and 9999, this is used to order the menu items',
				name: 'priority',
				allowBlank:true
			},{
				fieldLabel: 'Workflow Action',
				emptyText: 'Select an action for this menu to run upon selection',
				name: 'action',
				allowBlank:true
			},{
    			xtype: 'compositefield',
    			fieldLabel: 'Home Page Conf',
    			items: [{
            		xtype: 'textfield',
            		name: 'xPos',
            		emptyText: 'x position',
            		width: 125
        		},{
            		xtype: 'textfield',
            		name: 'yPos',
            		emptyText: 'y position',
            		width: 125
        		},{
            		xtype: 'xcheckbox',
            		name: 'showOnHome',
            		boxLabel: 'Show module on home screen?',
            		submitOffValue: 0, 
					submitOnValue: 1,
            		flex: 1
        		}]
        	}],
        	buttons: [{
        		text: 'Cancel',
        		handler: function() {
        			window.close();
        		}
        	},{
				text: 'Save',
				handler: function() {
					Ext.getCmp('new-item-form').getForm().submit({
						url: 'home/saveMultiObject/WorkflowItem',
						waitMsg: 'Creating new module...',
						submitEmptyText: false,
						success: function(fp, o){
							Ext.Msg.alert('Success', 'New module has been added.');
							fp.reset();
							itemStore.load();
							window.close();
						}
					});
				}
			}]
		}]
	});
	window.show();
};

var deleteWorkflowItem = function(ID) {
	var selection = Ext.getCmp('browseItemGrid').getSelectionModel().getSelections();
	if(selection[0] != undefined) {
		if(ID == null || ID == undefined) {
			ID = selection[0].id;
		}
		Ext.Msg.confirm('Are you sure?', 'Delete the selected item?', function(btn) {
			if(btn == 'yes') {
				loadingMask.show();
				Ext.Ajax.request({
					url: 'home/deleteSingleObject/WorkflowItem',
					waitMsg: 'Deleting the selected item...',
					success: function(data){
						loadingMask.hide();
						Ext.Msg.confirm('Success', 'Item has been deleted, a refresh is required to complete this process, refresh now?', function(btn) {
							if (btn == 'yes') {
								window.location.reload(true);
							} else {
								itemStore.load();
							}
						});
					},
					failure: function(data){
						loadingMask.hide();
					},
					params: { ID: ID }
				});
			}
		});
	} else {
		Ext.Msg.alert('Error','No item has been selected, please select a module to delete.');
	}
};

	
    main = new Ext.Viewport({
		layout: 'border',
		id: 'main',
		items: [{
			xtype: 'panel',
			region:'center',
			margins: '0 0 0 0',
			layout:'border',
			defaults: {
				collapsible: true,
				split: true
			},
			items: [mainNavPanel,
			{
				id: 'centerWorkflowHolder',
				collapsible: false,
				region:'center',
				margins: '5 5 5 0',
				layout: 'anchor',
				height: '100%',
				width: '100%',
				border: false,
				layoutConfig: {
					align: 'stretch',
					pack: 'start'
				},
				defaults: {
					anchor: '100% 100%',
					height: '100%',
					width: '100%',
					renderHidden: true
				},
				items: [
					homeControlWorkflow,
					addWorkflowCat, 
					addWorkflowItem,
					
SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

						adminWorkflow,
					
SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

					
SSVIEWER;
$val .=  $item->XML_val("includeModules",null,true) ;
 $val .= <<<SSVIEWER

				]
			}],
			tbar: {
				xtype: 'container',
				layout: 'anchor',
				defaults: { anchor : '100%' },
				items: [
					mainMenu
				]
			},
			bbar: new Ext.Toolbar({
				enableOverflow: true,
				id: 'windowManagerArea',
				items: [{
					icon: 'application/images/toolbars/desktop.png',
					handler: function() {
						iblWinMgr.hideAll();
					}	
				},'-']
    	    })
		}]
	});

});

/* Generated Functions */


SSVIEWER;
$val .=  $item->XML_val("moduleAddEditTemplates",null,true) ;
 $val .= <<<SSVIEWER


/* End Generrated Functions */

</script>
</head>
<body style="height: 100%; width: 100%;">

SSVIEWER;
 if($item->hasValue("adminPermissionCheck")) {  ;
 $val .= <<<SSVIEWER

<div id="formBuilderWindow" style="display: none; height: 100%; width: 100%;">
	<object width="100%" height="100%">
		<param name="movie" value="application/builder/IBLProcessBuilder.swf" />
		<param name="wmode" value="transparent" />
		<embed id="formBuilderFlash" wmode="transparent" src="application/builder/IBLProcessBuilder.swf" width="100%" height="100%"></embed>
	</object>
</div>

SSVIEWER;
 }  ;
 $val .= <<<SSVIEWER

</body>
</html>

SSVIEWER;
