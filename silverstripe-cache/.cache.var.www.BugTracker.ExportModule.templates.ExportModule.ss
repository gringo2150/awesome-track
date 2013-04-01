<?php
$val .= <<<SSVIEWER
var Exp_Graphics = null;

var ExportModule_DrawRelations = function() {
	if(Exp_Graphics == null) {
		Exp_Graphics = new jsGraphics(document.getElementById('ExportModule_Draw'));
	} else {
		Exp_Graphics.clear();
	}
	
	Ext.each(ExportModule_Joins.data.items, function(item, index) {
		var fromDv = ExportModule_Tables[item.data.tableFrom].dataView;
		var toDv = ExportModule_Tables[item.data.tableTo].dataView;
		var fromWindow = ExportModule_Tables[item.data.tableFrom].window.getEl();
		var toWindow = ExportModule_Tables[item.data.tableTo].window.getEl();
		var fromStore = fromDv.getStore();
		var toStore = toDv.getStore();
		var fieldFromRecordIndex = fromStore.find('fieldName', item.data.fieldFrom);
		var fieldToRecordIndex = toStore.find('fieldName', item.data.fieldTo);
		var col = fromStore.getAt(fieldFromRecordIndex);
		col = '#'+col.data.color;
		var fieldFromNode = fromDv.getNode(fieldFromRecordIndex);
		var fieldToNode = toDv.getNode(fieldToRecordIndex);
		var fieldFromEl = Ext.get(fieldFromNode);
		var fieldToEl = Ext.get(fieldToNode);
		var fromXY = fieldFromEl.getXY();
		var fromXYOff = fieldFromEl.getOffsetsTo(Ext.get('ExportModule_Draw'));
		var toXY = fieldToEl.getXY();
		var toXYOff = fieldToEl.getOffsetsTo(Ext.get('ExportModule_Draw'));
		//LeftRight
		if(fromXYOff[0] < toXYOff[0]) {
			fromXYOff[0] = (fromXYOff[0] + fieldFromEl.getWidth()) + 10;
		}
		if(toXYOff[0] < fromXYOff[0]) {
			toXYOff[0] = (toXYOff[0] + fieldToEl.getWidth()) - 10;
		}
		//Top Bottom
		//To Window
		if(toXYOff[1] < toWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1]) {
			toXYOff[1] = toWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1] + 15;
		}
		if(toXYOff[1] > (toWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1] + toWindow.getHeight())) {
			toXYOff[1] = (toWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1] + toWindow.getHeight()) - 5;
		}
		//From Window
		if(fromXYOff[1] < fromWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1]) {
			fromXYOff[1] = fromWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1] + 15;
		}
		if(fromXYOff[1] > (fromWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1] + fromWindow.getHeight())) {
			fromXYOff[1] = (fromWindow.getOffsetsTo(Ext.get('ExportModule_Draw'))[1] + fromWindow.getHeight()) - 5;
		}
		//if(toXYOff[1] < fromXYOff[1]) {
		//	toXYOff[1] = toXYOff[1] + toWindow.getHeight();
		//}
		var color = new jsColor(col);
		var pen = new jsPen(color,5);
		var pt1 = new jsPoint(fromXYOff[0],fromXYOff[1]);
		var pt2 = new jsPoint(toXYOff[0], toXYOff[1]);
		var lineEl = Ext.get(Exp_Graphics.drawLine(pen,pt1,pt2));
		lineEl.on('click', function() {
			Ext.Msg.alert('Click','Line has been clicked');
		});
	});
    
};

var ExportModule_Template = new Ext.XTemplate(
	'<div class="exp-table">',
		'<div class="exp-table-column-labels">',
			'<div class="x-grid3-header exp-table-cell-hd"></div>',
			'<div class="x-grid3-header exp-table-cell-hd">Field</div>',
			'<div class="x-grid3-header exp-table-cell-hd">Table</div>',
			'<div class="x-grid3-header exp-table-cell-hd">Sort</div>',
			'<div class="x-grid3-header exp-table-cell-hd">Show</div>',
			'<div class="x-grid3-header exp-table-cell-hd">Criteria</div>',
			'<div class="x-grid3-header exp-table-cell-hd exp-last">Or</div>',
			'<div class="x-grid3-header exp-table-cell-hd"></div>',
		'</div>',
		'<div class="exp-view">',
		'<div id="exp-column-scroller" class="exp-scroll">',
		'<tpl for=".">',
			'<div class="exp-table-column">',
				'<div class="x-grid3-header exp-table-cell-h">{field}</div>',
				'<div class="exp-table-cell x-grid3-row">',
					'<span class="exp-field">{fieldName}<span>',
				'</div>',
				'<div class="exp-table-cell x-grid3-row x-grid3-row-alt">',
					'<span class="exp-co-table">{table}<span>',
				'</div>',
				'<div class="exp-table-cell x-grid3-row">',
					'<span class="exp-co-sort">{sort}</span>',
				'</div>',
				'<div class="exp-table-cell x-grid3-row x-grid3-row-alt">',
					'<span class="exp-co-show">{show}<span>',
				'</div>',
				'<div class="exp-table-cell x-grid3-row">',
					'<span class="exp-criteria">{criteria}</span>',
				'</div>',
				'<div class="exp-table-cell x-grid3-row x-grid3-row-alt"><span class="exp-or">{or}<span></div>',
			'</div>',
		'</tpl>',
		'</div>',
		'</div>',
	'</div>'
);
ExportModule_Template.compile();

var ExportModule_Store = new Ext.data.Store({
	reader: new Ext.data.JsonReader({
		root: 'data',
		fields: [
			{name: 'field'},
			{name: 'fieldName'},
			{name: 'table'},
			{name: 'sort'},
			{name: 'show'},
			{name: 'criteria'},
			{name: 'or'}
		]
	}),
	proxy: new Ext.data.MemoryProxy({})
});

/**
 * Author Graha Bacon
 * Used to track table colors within the system, so we do not repeat ourselves.
 */
var ExportModule_Table_Colors = Object();

/**
 * Author Graham Bacon
 * This holds the data of what tables we have in the exporter we dont want to allow a table more than once.
 */
var ExportModule_Tables = Object();

var ExportModule_JoinsTemplate = new Ext.XTemplate(
	'<div class="exp-window-add-view">',
		'<div class="exp-window-add-scroll">',
			'<tpl for=".">',
				'<div class="exp-window-item"><span>{tableName}</span></div>',
			'</tpl>',
		'</div>',
	'</div>'
);

/**
 * Author Graha Bacon
 * This holds the joins in the exporter, used for generating queries and reports.
 */
var ExportModule_Joins = new Ext.data.Store({
	reader: new Ext.data.JsonReader({
		root: 'data',
		fields: [
			'tableFrom',
			'fieldFrom',
			'tableTo',
			'fieldTo',
			'direction'
		]
	}),
	proxy: new Ext.data.MemoryProxy({}),
	listeners: {
		load: function(store, records, options) {
			ExportModule_DrawRelations();
		}
	}
});

/**
* START of the add table window.
**/

var ExportModule_AddTableTemplate = new Ext.XTemplate(
	'<div class="exp-window-add-view">',
		'<div class="exp-window-add-scroll">',
			'<tpl for=".">',
				'<div class="exp-window-item"><span>{tableName}</span></div>',
			'</tpl>',
		'</div>',
	'</div>'
);

var ExportModule_TableNames = {data:[]};
Ext.each(InstalledObjects, function(object, index) {
	ExportModule_TableNames.data.push({tableName: object[0]});
});

var ExportModule_AddTableStore = new Ext.data.Store({
	reader: new Ext.data.JsonReader({
		root: 'data',
		fields: [
			{name: 'tableName'}
		]
	}),
	proxy: new Ext.data.MemoryProxy({})
});

ExportModule_AddTableStore.loadData(ExportModule_TableNames);

var initializePatientDragZone = function(v) {
    v.dragZone = new Ext.dd.DragZone(v.getEl(), {
        getDragData: function(e) {
            var sourceEl = e.getTarget(v.itemSelector, 10);
            if (sourceEl) {
                d = sourceEl.cloneNode(true);
                d.id = Ext.id();
                return v.dragData = {
                    sourceEl: sourceEl,
                    repairXY: Ext.fly(sourceEl).getXY(),
                    ddel: d,
                    column: v.getRecord(sourceEl).data
                }
            }
        },
        getRepairXY: function() {
            return this.dragData.repairXY;
        }
    });
}

var ExportModule_AddTableWindow = new Ext.Window({
	title: 'Add Table',
	height: 350,
	width: 250,
	closeAction: 'hide',
	autoScroll: true,
	items: [new Ext.DataView({
		store: ExportModule_AddTableStore,
		tpl: ExportModule_AddTableTemplate,
		autoHeight:true,
		singleSelect: true,
		overClass:'exp-window-over-item',
		itemSelector:'div.exp-window-item',
		emptyText: 'No items to display',
		listeners: {
            dblclick: function(view, index, node, event) {
            	var record = ExportModule_AddTableStore.getAt(index);
            	var fieldStore = new Ext.data.Store({
					reader: new Ext.data.JsonReader({
						root: 'data',
						fields: [
							{name: 'fieldName'},
							{name: 'tableName'},
							{name: 'key'},
							{name: 'primaryKey'},
							{name: 'joinObject'},
							{name: 'color'}
						]
					}),
					proxy: new Ext.data.MemoryProxy({})
				});
				var fieldTemplate = new Ext.XTemplate(
					'<div class="exp-window-add-view-f">',
						'<div class="exp-window-add-scroll-f">',
							'<tpl for=".">',
								'<tpl if="primaryKey == true">',
									'<div class="exp-window-item exp-drop-zone" table="{tableName}"><span class="primKey" style="background: #{color};">{fieldName}</span></div>',
								'</tpl>',
								'<tpl if="primaryKey == false">',
									'<tpl if="key == true">',
										'<div class="exp-window-item exp-drop-zone" table="{tableName}"><span class="key" style="background: #{color};">{fieldName}</span></div>',
									'</tpl>',
									'<tpl if="key == false">',
										'<div class="exp-window-item" table="{tableName}"><span>{fieldName}</span></div>', //style="background: #{color};"
									'</tpl>',
								'</tpl>',
							'</tpl>',
						'</div>',
					'</div>'
				);
				if(ExportModule_Tables[record.data.tableName] == undefined) {
					Ext.Ajax.request({
						url: 'exporter/listObjectDB/'+record.data.tableName,
						waitMsg: 'Reteriving table columns please wait.',
						success: function(data){
							var columns = Ext.decode(data.responseText);
							Ext.each(columns.data, function(column, index) {
								if(ExportModule_Table_Colors[column.joinObject] == undefined) {
									ExportModule_Table_Colors[column.joinObject] = generatePastelColor();
								}
								columns.data[index].color = ExportModule_Table_Colors[column.joinObject];
							});
							var dataView = new Ext.DataView({
								store: fieldStore,
								tpl: fieldTemplate,
								singleSelect: true,
								overClass:'exp-window-over-item',
								itemSelector:'div.exp-window-item',
								emptyText: 'No items to display',
								listeners: {
									render: initializePatientDragZone
								}
							});
							var window = new Ext.Window({
								title: record.data.tableName,
								width: 200,
								height: 150,
								autoScroll: true,
								constrainHeader: true,
								shadow: false,
								renderTo: 'ExportModule_NorthContent',
								x: 0,
								y: 0,
								listeners: {
									move: function(win, x, y) {
										win.getEl().setStyle({
											'z-index': 500
										});
										ExportModule_DrawRelations();
									},
									resize: function(){
										ExportModule_DrawRelations();
									}
								},
								items: [dataView]
							});
							fieldStore.loadData(columns);
							ExportModule_Tables[record.data.tableName] = {
								color: ExportModule_Table_Colors[record.data.tableName],
								dataView: dataView,
								window: window,
								joins: {}
							};
							window.show();
						},
						failure: function(obj, data){
							//var msg = Ext.decode(data.responseText).msg;
							//Ext.Msg.alert('Importer', msg);
							//console.log(data);
						}
					});
				}
            }
        }
	})]
});

/**
* END of the add table window.
**/

var initializeHospitalDropZone = function(g) {
    g.dropZone = new Ext.dd.DropZone(Ext.getCmp('ExportModule').bwrap, {

        getTargetFromEvent: function(e) {
            return e.getTarget('.exp-drop-zone');
        },

        onNodeEnter : function(target, dd, e, data){ 
            Ext.fly(target).addClass('exp-target-hover');
        },

        onNodeOut : function(target, dd, e, data){ 
            Ext.fly(target).removeClass('exp-target-hover');
        },

        onNodeOver : function(target, dd, e, data){ 
            return Ext.dd.DropZone.prototype.dropAllowed;
        },

        onNodeDrop : function(target, dd, e, data){
            var dropTable = Ext.get(target).getAttribute('table');
            if(dropTable != '' && dropTable != undefined) {
				var rec = ExportModule_Tables[dropTable].dataView.getRecord(target);
				var item = {
					data: [{
						tableFrom: data.column.tableName,
						fieldFrom: data.column.fieldName,
						tableTo: rec.data.tableName,
						fieldTo: rec.data.fieldName,
						direction: 'LEFT'
					}]
				};
				ExportModule_Joins.loadData(item, true);
			} else {
            	var item = {
					data: [{
						fieldName: '',
						field: data.column.tableName + '.' + data.column.fieldName,
						table: data.column.tableName,
						sort: 'NONE',
						show: 'true',
						criteria: '',
						or: ''
					}]
				}
				var scroller = Ext.get('exp-column-scroller');
				var width = ((ExportModule_Store.getCount() + 2) * 140);
				if(scroller != undefined) {
					scroller.setWidth(width);
				}
				ExportModule_Store.loadData(item, true);
			}
        }
    });
}

/*****
 Start of the query viewer window config
*****/

var ExportModule_QueryWindowStore = new Ext.data.Store({
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
			Ext.getCmp('ExportModule_QueryWindowGrid').reconfigure(store, cm);
		}
	},
	reader: new Ext.data.JsonReader(),
	proxy: new Ext.data.MemoryProxy({results: 0, rows: []})
});

var ExportModule_QueryWindow = new Ext.Window({
	title: 'Query Viewer',
	closeAction: 'hide',
	height: 400,
	width: 500,
	layout:'fit',
	items: [new Ext.grid.GridPanel({
		id: 'ExportModule_QueryWindowGrid',
		border: false,
		store: ExportModule_QueryWindowStore,
		colModel: new Ext.grid.ColumnModel({}),
		loadMask: true
	})]
});

/*****
 End of the query viewer window config
*****/

var ExportModule_NorthTemplate = Array(
	'<div id="ExportModule_NorthContent" style="z-index: 500; overflow: auto; height: 100%; width: 100%; position: relative;">',
		'<div id="ExportModule_Draw" style="z-index: 490; overflow: auto; height: 100%; width: 100%;" >',
		'</div>',
	'</div>'
).join('');

var ExportModule = new Ext.Panel({
	border: false,
	layout: 'border',
	hidden: true,
	id: 'ExportModule',
	defaults: {
    	split: true
    },
	items: [new Ext.Panel({
		border: true,
		region: 'center',
		title: 'ExportModule',
		id: 'ExportModule_North',
		html: ExportModule_NorthTemplate,
		tbar: new Ext.Toolbar({
			id: 'ExportModule_TopToolbar',
			padding: '2 2 2 2',
			items: [{
				text: 'Add Table',
				icon: 'ExportModule/images/table_add.png',
				handler: function() {
					ExportModule_AddTableWindow.show();
				}
			},{
				text: 'Edit Joins',
				icon: 'ExportModule/images/table_relationship.png',
				handler: function() {
				}
			},{
				text: 'View Query',
				icon: 'ExportModule/images/table_go.png',
				handler: function() {
					if(ExportModule_Store.getCount() > 0) {
						var tables = Object();
						var columns = Array();
						var query = Array();
						var sorts = Array();
						var show = Object();
						Ext.each(ExportModule_Store.data.items, function(item, i) {
							if(tables[item.data.table] == undefined) {
								tables[item.data.table] = item.data.table;
							}
							//Get all the query data from the columns to send to the server.
							var queryLine = '';
							var hasQuery = false;
							if(item.data.criteria != '' && item.data.criteria != undefined) {
								queryLine += item.data.field + " " + item.data.criteria; 
								hasQuery = true;
							}
							if(item.data.or != '' && item.data.or != undefined) {
								queryLine += " OR " + item.data.field + " " + item.data.or;
								hasQuery = true;
							}
							if(hasQuery == true) {
								query.push(queryLine);
							}
							//Get all the sorts
							if(item.data.sort !== 'NONE') {
								sorts.push(item.data.field + ' ' + item.data.sort);
							}
							//Get Hidden columns
							show[item.data.field] = item.data.show;
							//Get all the columns from the store and stick them in an array.
							columns.push(item.data.field);
						});
						//Get all the joins from the store and stick them in an array.
						var joins = Array();
						Ext.each(ExportModule_Joins.data.items, function(item, i) {
							joins.push(item.data);
							if(tables[item.data.tableTo] != undefined) {
								tables[item.data.tableTo] = undefined;
							}
						});
						//Send the data to the server.
						Ext.Ajax.request({
							url: 'exporter/runQuery/',
							waitMsg: 'Exporting data please wait',
							params: {
								joins: Ext.encode(joins),
								tables: Ext.encode(tables),
								columns: Ext.encode(columns),
								query: Ext.encode(query),
								sorts: Ext.encode(sorts),
								show: Ext.encode(show)
							},
							success: function(data){
								ExportModule_QueryWindow.show();
								var results = Ext.decode(data.responseText);
								ExportModule_QueryWindowStore.loadData(results, false);
							},
							failure: function(obj, data){
								Ext.Msg.alert('Query Error', obj.statusText.split('"')[1]);
							}
						});
					}
				}
			},{
				text: 'Save Query',
				icon: 'ExportModule/images/table_save.png',
				handler: function() {
					var formID = Ext.id();
					var window = new Ext.Window({
						title: 'Save Query',
						width: 350,
						border: false,
						items: [new Ext.form.FormPanel({
							height: '100%',
							width: '100%',
							id: formID,
							margins: '5 5 5 5',
							defaults: {
								anchor: '-18',
								allowBlank: false,
	 							msgTarget: 'side'
       						},
							frame: true,
							fileUpload: true,
							labelAlign: 'top',
							submitEmptyText: false,
							items: [{
								xtype: 'textfield',
								fieldLabel: 'Query Name',
								name: 'name'
							}]
						})],
						buttons: [{
							text: 'Cancel',
							handler: function() {
								window.close();
							}
						},{
							text: 'Save',
							handler: function() {
								var tables = Object();
								var columns = Array();
								var query = Array();
								var sorts = Array();
								var show = Object();
								Ext.each(ExportModule_Store.data.items, function(item, i) {
									if(tables[item.data.table] == undefined) {
										tables[item.data.table] = item.data.table;
									}
									//Get all the query data from the columns to send to the server.
									var queryLine = '';
									var hasQuery = false;
									if(item.data.criteria != '' && item.data.criteria != undefined) {
										queryLine += item.data.field + " " + item.data.criteria; 
										hasQuery = true;
									}
									if(item.data.or != '' && item.data.or != undefined) {
										queryLine += " OR " + item.data.field + " " + item.data.or;
										hasQuery = true;
									}
									if(hasQuery == true) {
										query.push(queryLine);
									}
									//Get all the sorts
									if(item.data.sort !== 'NONE') {
										sorts.push(item.data.field + ' ' + item.data.sort);
									}
									//Get Hidden columns
									show[item.data.field] = item.data.show;
									//Get all the columns from the store and stick them in an array.
									columns.push(item.data.field);
								});
								//Get all the joins from the store and stick them in an array.
								var joins = Array();
								Ext.each(ExportModule_Joins.data.items, function(item, i) {
									joins.push(item.data);
									if(tables[item.data.tableTo] != undefined) {
										tables[item.data.tableTo] = undefined;
									}
								});
								var form = Ext.getCmp(formID).getForm();
								form.submit({
									url: 'exporter/saveQuery/',
									waitMsg: 'Saving query please wait...',
									params: {
										joins: Ext.encode(joins),
										tables: Ext.encode(tables),
										columns: Ext.encode(columns),
										query: Ext.encode(query),
										sorts: Ext.encode(sorts),
										show: Ext.encode(show)
									},
									success: function(data){
										//clear stores and windows, close save window...?
										window.close();
										Ext.Msg.alert('Query Saved', 'Query has been saved and can now be used in reports.');
									},
									failure: function(obj, data){
										//Show error message
										Ext.Msg.alert('Query Error', obj.statusText.split('"')[1]);
									}
								});
							}
						}]
					});
					window.show();
				}
			}/*,{
				text: 'Load Query',
				icon: 'ExportModule/images/table_edit.png',
				handler: function() {
				}
			}*/]
		})
	}),new Ext.Panel({
		border: true,
		region: 'south',
		id: 'ExportModule_South',
		height: 200,
		minSize: 200,
		maxSize: 200,
		margins: '0 0 0 0',
		items: new Ext.DataView({
            store: ExportModule_Store,
            tpl: ExportModule_Template,
            height: 200,
            singleSelect: true,
            id: 'ExportModule_ColumnPanel',
            cls: 'exp-drop-zone',
            overClass:'exp-table-over',
            itemSelector:'div.exp-table-column',
            emptyText: 'No columns to display.',
            plugins: [
            	new Ext.DataView.LabelEditor({
					dataIndex: 'or',
					labelSelector: 'span.exp-or'
				}),
				new Ext.DataView.LabelEditor({
					dataIndex: 'criteria',
					labelSelector: 'span.exp-criteria'
				}),
				new Ext.DataView.ExpCombo({
					dataIndex: 'show',
					comboValues: [['true'],['false']],
					labelSelector: 'span.exp-co-show'
				}),
				new Ext.DataView.ExpCombo({
					dataIndex: 'sort',
					comboValues: [['ASC'], ['DESC'], ['NONE']],
					labelSelector: 'span.exp-co-sort'
				}),
				new Ext.DataView.LabelEditor({
					dataIndex: 'fieldName',
					labelSelector: 'span.exp-field'
				})
				//Temp disable the table changer until store can be updated.
				/*,
				new Ext.DataView.ExpCombo({
					dataIndex: 'table',
					comboValues: InstalledObjects,
					labelSelector: 'span.exp-co-table'
				})*/
            ],
            listeners: {
            	render: initializeHospitalDropZone
        	}
        })

	})]
});


SSVIEWER;
