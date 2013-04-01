var ReportModule_Template = new Ext.XTemplate(
	'<div class="rpt-wrapper">',
		'<div class="rpt-scroller">',
			'<tpl for=".">',
				'<div class="rpt-group">',
					'<h2 class="rpt-group-name">Report Group - {groupName}</h2>',
					'<tpl for="groupData">',
						'<div class="rpt-item" nodeID="{ID}">',
							'<div class="rpt-item-holder">',
								'<img class="rpt-item-image" src="ExportModule/images/ReportModule/{ReportType}.png" />',
							'</div>',
							'<span class="rpt-title">{ReportName}</span>',
							'<input type="button" name="runButton" value="Run"/>',
						'</div>',
					'</tpl>',
					'<div class="rpt-clear"></div>',
				'</div>',
			'</tpl>',
			'<div class="rpt-clear"></div>',
		'</div>',
	'</div>'
);
ReportModule_Template.compile();

var ReportModule_Store = new Ext.data.JsonStore({
	root: 'data',
	fields: [
		{name: 'groupName'},
		{name: 'groupData'}
	],
	url: 'report/listReports'
});

var ReportModule_LoadMask = null;

var ReportModule = new Ext.Panel({
	border: false,
	layout: 'border',
	hidden: true,
	id: 'ReportModule',
	defaults: {
    	split: true
    },
	items: [new Ext.Panel({
		margins: '0 0 0 0',
		border: true,
		title: 'ReportModule',
		region: 'center',
		id: 'ReportModule_Panel',
		layout: 'fit',
		items: [new Ext.DataView({
			store: ReportModule_Store,
			tpl: ReportModule_Template,
			singleSelect: true,
			id: 'ReportModule_DataPanel',
			overClass:'rpt-item-hover',
			selectedClass: 'rpt-item-select',
			itemSelector:'div.rpt-item',
			emptyText: 'No reports to display.',
			listeners: {
				afterrender: function() {
					ReportModule_LoadMask = new Ext.LoadMask(ReportModule.getEl(), {msg:"Please wait...", store: ReportModule_Store});
				},
				click: function(view, index, node, event) {
					var rptID = Ext.get(node).getAttribute('nodeID');
					var rptIndex = Ext.each(ReportModule_Store.reader.jsonData.ungrouped, function(item, i) {
						if(item.ID == rptID) {
							return false;
						}
					});
					var rptRecord = ReportModule_Store.reader.jsonData.ungrouped[rptIndex]; 
					if(event.target.name == "runButton") {
						if(rptRecord.ReportType == "Data") {
							window.location = 'report/runReport/' + rptID;
						}
						if(rptRecord.ReportType == "Template") {
							window.location = 'report/runReport/' + rptID;
						}
						if(rptRecord.ReportType == "Email") {
							Ext.Ajax.request({
								url: 'report/runReport/' + rptID,
								waitMsg: 'Running report please wait',
								/*params: {
									joins: Ext.encode(joins),
									tables: Ext.encode(tables),
									columns: Ext.encode(columns),
									query: Ext.encode(query),
									sorts: Ext.encode(sorts),
									show: Ext.encode(show)
								},*/
								success: function(data){
									//console.log(data);
									//ExportModule_QueryWindow.show();
									var results = Ext.decode(data.responseText);
									Ext.Msg.alert('Report Message', results.msg);
									//ExportModule_QueryWindowStore.loadData(results, false);
								},
								failure: function(obj, data){
									Ext.Msg.alert('Report Error', obj.statusText.split('"')[1]);
								}
							});
						}
					}
				}
			}
		})]
	})]
});




