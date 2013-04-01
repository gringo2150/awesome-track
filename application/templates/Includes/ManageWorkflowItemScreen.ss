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
							data: [$moduleComboList]
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
					data: [$moduleComboList]
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
