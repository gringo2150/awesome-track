<?php
$val .= <<<SSVIEWER
//Search Module Store --> Move into own ext file with rest of module.
var SearchModule_Store = new Ext.data.GroupingStore({
	autoLoad: false,
	url: 'home/search/',
	paramNames: {
		sort: 'orderBy',
		dir: 'orderByDirection'
	},
	groupField:'',
	reader: new Ext.data.JsonReader({
		idProperty: 'ID',
		root: 'rows',
		totalProperty: 'results',
		fields: [
			{name: 'ID', type: 'int'}
		]
	}),
	remoteSort: true,
	storeRefresh: true,
	//sortInfo:{field: '', direction: "ASC"},
	groupOnSort: false, //Need to fix this param causing group remote sorting issues...
	baseParams: {
		start: 0,
		limit: 30,
		meta: true,
		columnModel: true
	},
	listeners: {
		beforeload: function(store, options) {
			if(store.storeRefresh == false) {
				var grid = Ext.getCmp('SearchModule');
				var columns = grid.getColumnModel().getColumnsBy(function(c){
					return c.incSearch;
				});
				colString = '';
				var i=0;
				for (i; i<columns.length; i++) {
					colString += columns[i].dataIndex + ',';
				}
				store.baseParams.columns = colString.substr(0, colString.length -1);
				if(store.fields != undefined) {
					Ext.apply(store.baseParams, {
						'tableFields[]': store.fields.keys
					});
				}
			} else {
				store.storeRefresh = false;
			}
		},
		metachange: function(store, meta) {
			var tempExtraParams = (store.baseParams.extraParams != null && store.baseParams.extraParams != undefined) ? store.baseParams.extraParams : "";
			store.baseParams = {
				start: 0,
				limit: 30,
				extraParams: tempExtraParams 
			};
			store.reader.jsonData.columnModel.unshift(new Ext.grid.RowNumberer({width: 20}))
			var cm = new Ext.grid.ColumnModel({
				defaults: {
					sortable: true
				},
				columns: store.reader.jsonData.columnModel
			});
			try {
				if(store.sortField != null) {
					store.groupBy(store.sortField);
					store.singleSort(store.sortField);
				} else {
					store.clearGrouping();
				}
			} catch(err) {  }
			Ext.getCmp('SearchModule').reconfigure(store, cm);
		},
		load: function(store, options) {
			Ext.getCmp('SearchModule_ExportButton').enable();
			Ext.getCmp('main').doLayout();
		},
		exception: function(misc){
			//console.log(misc);
			Ext.getCmp('SearchModule_ExportButton').disable();
			Ext.getCmp('SearchModule').store.removeAll();
		}
	}
});
//SearchModule Panel -> move into own ext file.
var SearchModule = new Ext.Panel({
	border: false,
	layout: 'border',
	hidden: true,
	defaults: {
    	split: true
    },
	items: [{
		xtype: 'grid',
		title: 'SearchModule',
		searchObject: null,
		region: 'center',
		frame: false,
		stripeRows: true,
		id: 'SearchModule',
		store: SearchModule_Store,
		width: '100%',
		height: '100%',
		listeners: {
			reconfigure: function(grid, store, columnModel) {
				var columns = columnModel.getColumnsBy(function(c){
					return c.canSearch;
				});
				var gridFilterMenu = new Ext.menu.Menu();
				var i=0;
				for (i; i<columns.length; i++) {	
					gridFilterMenu.add(new Ext.menu.CheckItem({
						text: columns[i].header,
						checked: columns[i].incSearch,
						dataIndex: columns[i].dataIndex,
						hideOnClick: false,
						checkHandler: function (item, checked) {
							var column = columnModel.getColumnsBy(function(c){
								return c.canSearch;
							});
							var j=0;
							for(j; j<column.length; j++) {
								if(item.dataIndex == column[j].dataIndex) {
									column[j].incSearch = checked;
								}
							}
						}
					}));
				}
				if(Ext.getCmp('SearchModule_Filters') !== undefined) {
					Ext.getCmp('SearchModule_TopToolbar').remove(Ext.getCmp('SearchModule_Filters'));
				}
				Ext.getCmp('SearchModule_TopToolbar').insert(0,{id: 'SearchModule_Filters', text: 'Search Filters', icon: 'SearchModule/images/search.png', menu: gridFilterMenu});
				Ext.getCmp('main').doLayout();
			}
		},
		tbar: new Ext.Toolbar({
			id: 'SearchModule_TopToolbar',
			items: [{
            	icon: 'SearchModule/images/clearTable.png',
            	tooltip: 'Clear Results',
            	handler: function() {
            		Ext.getCmp('SearchModule').store.removeAll();
            	}
            },'-','Search: ',
            new Ext.ux.form.SearchField({
                store: SearchModule_Store,
                width: 200
            }),'->',{
            	id: 'SearchModule_AddButton',
            	text: 'Add Button',
				icon: 'SearchModule/images/add.png',
				handler: function() {
				}
			},{
				id: 'SearchModule_EditButton',
				text: 'Edit Button',
				icon: 'SearchModule/images/edit.png',
				handler: function() {
				}
			},{
				id: 'SearchModule_DeleteButton',
				text: 'Delete Button',
				icon: 'SearchModule/images/delete.png',
				handler: function() {
				}
			}]
		}),
		bbar: new Ext.PagingToolbar({
	        store: SearchModule_Store,
	        displayInfo: true,
	        pageSize: 30,
	        prependButtons: false,
			items:[
				'-', {
				id: 'SearchModule_ExportButton',
				text: 'Export To Spreadsheet',
				icon: 'SearchModule/images/export.png',
				handler: function(btn, pressed){
					var store = SearchModule_Store;
					var lastParams = store.lastOptions;
					var bParams;
					if (lastParams.params) {
						bParams = lastParams.params;
					} else {
						bParams = store.baseParams;
					}
					Ext.Ajax.request({
						url: 'home/searchResultsToXLS/'+Ext.getCmp('SearchModule').searchObject,
						success: function(response, opts){
							result = Ext.decode(response.responseText).data;
							Ext.Msg.alert('Success', '<p>The data has been exported to a spreadsheet:</p><br /><p><a href="'+result.file+'">Click here to download ' + result.filename + '</a></p>');
						},
						failure: function(){
						   Ext.Msg.alert('Error', 'There was a problem exporting data');
						},
						params: bParams,
						method: "POST"
					});
				}
			}]
	    }),
		colModel: new Ext.grid.ColumnModel({}),
		sm: new Ext.grid.RowSelectionModel({singleSelect: true}),
		loadMask: true,
		view: new Ext.grid.GroupingView({
			forceFit: true,
			hideGroupedColumn: true,
			startCollapsed: true
		})
	}]
});

SSVIEWER;
