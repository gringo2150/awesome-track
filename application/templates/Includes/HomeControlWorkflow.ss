<% if adminPermissionCheck %>

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

<% end_if %>
