<?php
$val .= <<<SSVIEWER
var ImportModule_Store = new Ext.data.Store({
	remoteSort: false,
	listeners: {
		metachange: function(store, meta) {
			store.reader.jsonData.columnModel.unshift(new Ext.grid.RowNumberer({width: 20}))
			var cm = new Ext.grid.ColumnModel({
				defaults: {
					sortable: true
				},
				columns: store.reader.jsonData.columnModel
			}); 
			Ext.getCmp('ImportModule_Center').reconfigure(store, cm);
		}
	},
	reader: new Ext.data.JsonReader(),
	proxy: new Ext.data.MemoryProxy({results: 0, rows: []})
});

var ImportModule_FileStore = new Ext.data.SimpleStore({
	id: 'ImportModule_FileStore',
	fields: [
		{name:'id', type:'text', system:true},
		{name:'shortName', type:'text', system:true},
		{name:'fileName', type:'text', system:true},
		{name:'filePath', type:'text', system:true},
		{name:'fileCls', type:'text', system:true},
		{name:'input', system:true},
		{name:'form', system:true},
		{name:'state', type:'text', system:true},
		{name:'error', type:'text', system:true},
		{name:'progressId', type:'int', system:true},
		{name:'bytesTotal', type:'int', system:true},
		{name:'bytesUploaded', type:'int', system:true},
		{name:'estSec', type:'int', system:true},
		{name:'filesUploaded', type:'int', system:true},
		{name:'speedAverage', type:'int', system:true},
		{name:'speedLast', type:'int', system:true},
		{name:'timeLast', type:'int', system:true},
		{name:'timeStart', type:'int', system:true},
		{name:'pctComplete', type:'int', system:true}
	],
	data: []
});

var ImportModule_UploaderConfig = {
	store: ImportModule_FileStore,
	name: 'file',
	url: 'importer/preview'
};

var ImportModule_Uploader = new Ext.ux.FileUploader(ImportModule_UploaderConfig);

var ImportModule_ObjectHeaders = null;

ImportModule_Uploader.on('fileresponse', function(uploader, response) {
	var data = Ext.decode(response.responseText);
	ImportModule_Store.loadData(data);
	ImportModule_FileStore.each(function(record){
		ImportModule_FileStore.remove(record);
	});
	Ext.getCmp('ImportModule_ClearImportButton').enable();
	Ext.getCmp('ImportModule_ImportButton').enable();
	Ext.getCmp('ImportModule_Center').loadMask.hide();
});

var ImportModule = new Ext.Panel({
	border: false,
	layout: 'border',
	hidden: true,
	id: 'ImportModule',
	defaults: {
    	collapsible: false,
    	split: true
    },
	items: [new Ext.grid.GridPanel({
		border: true,
		region: 'center',
		title: 'ImportModule',
		id: 'ImportModule_Center',
		tbar: new Ext.Toolbar({
			id: 'ImportModule_TopToolbar',
			padding: '2 2 2 2',
			items: ['Import Object',new Ext.form.ComboBox({
				typeAhead: true,
				triggerAction: 'all',
				lazyRender:true,
				id: 'ImportModule_ObjectCombo',
				mode: 'local',
				width: 200,
				store: new Ext.data.ArrayStore({
					id: 0,
					fields: [
						'displayValue'
					],
					data: InstalledObjects
				}),
				valueField: 'displayValue',
				displayField: 'displayValue',
				listeners: {
					select: function(feild, record, index) {
						Ext.Ajax.request({
							url: 'importer/CSVHeaders/'+record.id,
							waitMsg: 'Importing data please wait',
							success: function(data){
								ImportModule_ObjectHeaders = Ext.decode(data.responseText).data;
								//Only Process if we have atleast one header.
								if(ImportModule_ObjectHeaders.length > 0) {
									var cm = Ext.getCmp('ImportModule_Center').getColumnModel();
									Ext.each(ImportModule_ObjectHeaders, function(header, index) {
										var colIndex = cm.findColumnIndex(header);
										if(colIndex != -1) {
											cm.setRenderer(colIndex,function(value, meta) {
												meta.attr = 'style="background: #99FFCC;"';
												return value;
											});
											var colID = cm.getColumnId(colIndex);
											var col = cm.getColumnById(colID);
											col.objectMapping = header;
										}
									});
									var grid = Ext.getCmp('ImportModule_Center');
									grid.reconfigure(grid.store, grid.colModel);
								}
							},
							failure: function(obj, data){
								//var msg = Ext.decode(data.responseText).msg;
								//Ext.Msg.alert('Importer', msg);
								//console.log(data);
							}
						});
					}
				}
			}),{
				id: 'ImportModule_HeadersButton',
				text: 'Get Headers',
				icon: 'ImportModule/images/table_headers.png',
				handler: function(){
					//Dont actually want the header json data here, instead it would be nice to get the excel file to populate...
					var object = Ext.getCmp('ImportModule_ObjectCombo').getValue();
					if(object != '') {
						Ext.Ajax.request({
							url: 'importer/CSVHeaders/'+object,
							waitMsg: 'Importing data please wait',
							success: function(data){
								ImportModule_ObjectHeaders = Ext.decode(data.responseText).data;
							},
							failure: function(obj, data){
							}
						});
					} else {
						Ext.Msg.alert('Error', 'No object selected, please select an object.');
					}
				}
			},'-',{
				xtype: 'browsebutton',
				text: 'Browse CSV',
				icon: 'ImportModule/images/browse_file.png',
				handler: function(bb){
					var inp = bb.detachInputFile();
					inp.addClass('x-hidden');
					var fileName = bb.getFileName(inp);
					var fileClass = bb.getFileCls(fileName)
					if(fileClass == 'csv') {
						// create new record and add it to store
						var rec = new ImportModule_FileStore.recordType({
							input: inp,
							fileName: fileName,
							filePath: bb.getFilePath(inp),
							shortName: Ext.util.Format.ellipsis(fileName, 18),
							fileCls: fileClass,
							state: 'queued'
						}, 'csvFile');
						rec.commit();
						ImportModule_FileStore.add(rec);
					} else {
						Ext.Msg.alert('Error', 'The importer only supports *.csv files, please select a csv file to import');
					}
				}
			},{
				id: 'ImportModule_UploadPreviewButton',
				text: 'Preview Upload',
				icon: 'ImportModule/images/preview_upload_file.png',
				handler: function(){
					Ext.getCmp('ImportModule_Center').loadMask.show();
					ImportModule_Uploader.upload();
				}
			}]
		}),
		bbar: new Ext.Toolbar({
			id: 'ImportModule_BottomToolbar',
			padding: '2 2 2 2',
			items: ['->',{
				text: 'Clear',
				icon: 'ImportModule/images/clear_table.png',
				disabled: true,
				id: 'ImportModule_ClearImportButton',
				handler: function() {
					ImportModule_Store.loadData({results: 0, rows: []});
					Ext.getCmp('ImportModule_ClearImportButton').disable();
					Ext.getCmp('ImportModule_ImportButton').disable();
					Ext.getCmp('ImportModule_Center').reconfigure(ImportModule_Store, new Ext.grid.ColumnModel({}));
				}
			},{
				text: 'Import',
				icon: 'ImportModule/images/table_import.png',
				disabled: true,
				id: 'ImportModule_ImportButton',
				handler: function() {
					var cm = Ext.getCmp('ImportModule_Center').getColumnModel();
					var columns = cm.getColumnsBy(function(c){
						var rtn = false;
						if(c.objectMapping != undefined && c.objectMapping !== "") {
							rtn = true;
						}
						return rtn;
					});
					var headers = Array();
					Ext.each(columns, function(column, index) {
						headers[index] = column.objectMapping;
					});
					var rows = Array();
					Ext.each(ImportModule_Store.data.items, function(item, i) {
						var tmpRow = Object();
						Ext.each(columns, function(column, j) {
							if(item.data[column.dataIndex] != undefined) {
								tmpRow[column.objectMapping] = item.data[column.dataIndex];
							}
						});
						rows[i] = tmpRow;
					});
					var object = Ext.getCmp('ImportModule_ObjectCombo').getValue();
					if(object != '') {
						Ext.getCmp('ImportModule_Center').loadMask.show();
						Ext.Ajax.request({
							url: 'importer/importCSV',
							waitMsg: 'Importing data please wait',
							success: function(data){
								var rData = Ext.decode(data.responseText);
								ImportModule_Store.loadData({results: 0, rows: []});
								Ext.getCmp('ImportModule_ClearImportButton').disable();
								Ext.getCmp('ImportModule_ImportButton').disable();
								Ext.getCmp('ImportModule_Center').reconfigure(ImportModule_Store, new Ext.grid.ColumnModel({}));
								Ext.getCmp('ImportModule_Center').loadMask.hide();
								Ext.Msg.alert('Importer', rData.msg);
							},
							failure: function(obj, data){
								var rData = Ext.decode(data.responseText);
								Ext.getCmp('ImportModule_Center').loadMask.hide();
								Ext.Msg.alert('Importer', rData.msg);
							},
							params: {
								object: object,
								headers: Ext.encode(headers),
								rows: Ext.encode(rows)
							}
						});
					} else {
						Ext.Msg.alert('Error', 'The importer needs to know what type of object you are importing, please select an object.');
					}
				}
			}]
		}),
		store: ImportModule_Store,
		colModel: new Ext.grid.ColumnModel({}),
		loadMask: true,
		viewConfig: {
			forceFit: true,
			/**
			 * This is a huge hack, checked out the source for view and now i've overloaded this internal function 
			 * which allows me to fire a new event for whn the header menu is opened with the data I need.
			 **/
			handleHdDown : function(e, target) {
				if (Ext.fly(target).hasClass('x-grid3-hd-btn')) {
					e.stopEvent();
            		var grid = Ext.getCmp('ImportModule_Center');
					var colModel  = grid.view.cm,
						header    = grid.view.findHeaderCell(target),
						index     = grid.view.getCellIndex(header),
						sortable  = colModel.isSortable(index),
						menu      = grid.view.hmenu,
						menuItems = menu.items,
						menuCls   = grid.view.headerMenuOpenCls;
            
					grid.view.hdCtxIndex = index;

					Ext.fly(header).addClass(menuCls);
					menuItems.get('asc').setDisabled(!sortable);
					menuItems.get('desc').setDisabled(!sortable);

					menu.on('hide', function() {
						Ext.fly(header).removeClass(menuCls);
					}, grid.view, {single:true});
            		menu.show(target, 'tl-bl?');
            		grid.fireEvent('headermenuclick', grid, index, e);
				}
			}
		},
		listeners: {
			headermenuclick: function(grid, columnIndex, event) {
				if(ImportModule_ObjectHeaders != null) {
					//Find a way to save this context, building it new each time takes too long
					//Maybe cache an unchecked version of it, and then loop through after?
					var cm = grid.getColumnModel();
					var columnID = cm.getColumnId(columnIndex);
					var column = cm.getColumnById(columnID);
					var cmContextItems =  Array();
					Ext.each(ImportModule_ObjectHeaders, function(header, index){
						var checked = false;
						if(header == column.objectMapping) {
							checked = true;
						}
						cmContextItems[index] = new Ext.menu.CheckItem({
							text: header,
							checked: checked,
							dataIndex: column.dataIndex,
							columnID: columnID,
							columnIndex: columnIndex,
							objectMapping: header,
							hideOnClick: false,
							checkHandler: function (item, checked) {
								var gridHandler = Ext.getCmp('ImportModule_Center');
								var cmHandler = gridHandler.getColumnModel();
								var colHandler = cmHandler.getColumnById(item.columnID);
								if(checked == true) {
									colHandler.objectMapping = item.objectMapping;
									cm.setRenderer(item.columnIndex,function(value, meta) {
										meta.attr = 'style="background: #99FFCC;"';
										return value;
									});
								} else {
									colHandler.objectMapping = '';
									cm.setRenderer(item.columnIndex,function(value, meta) {
										meta.attr = '';
										return value;
									});
								}
								gridHandler.reconfigure(gridHandler.store, cmHandler);
							}
						});
					});
					Ext.getCmp('ImportModule_ColumnMappingMenu').removeAll();
					Ext.getCmp('ImportModule_ColumnMappingMenu').add(cmContextItems);
				}
			},
			afterrender: function(grid){
				grid.view.hmenu.add({
  					text: 'Column Mapping',
  					menu: new Ext.menu.Menu({id:'ImportModule_ColumnMappingMenu'})
				});
			}
		}
	})]
});

SSVIEWER;
