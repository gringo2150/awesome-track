var shortcutBar = new Ext.Toolbar({
	xtype: 'toolbar',
	layout: 'hbox',
	autoHeight: true,
	hidden: true,
	height: 'auto',
	items: [{
		xtype: 'button',
    	cls: 'x-btn-icon',
    	icon: 'application/images/buttons_icons/configure.png',
    	scale: 'large',
    	tooltip: "Customer Configuration, edit and change settings relating to customers",
    	handler: function(){
			for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
				Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
			}
			customerConfigurationWorkflow.show();
			main.doLayout();
		}
	}]
});
