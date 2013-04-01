function addReport() {
	var moduleID = '';
	parseForm("AddReportItem.frm", "Add New Report", function(obj){
		
		obj.Template.store = new Ext.data.JsonStore({
			url: 'home/getChildObjects/Template',
			root: 'rows',
			fields: ['ID', 'name']
		});
		
		obj.Template.emptyText = 'Template to base this report on.';
		obj.Template.displayField = 'name';
		obj.Template.valueField = 'ID';
		
		obj.Query.store = new Ext.data.JsonStore({
			url: 'home/getChildObjects/SavedQuery',
			root: 'rows',
			fields: ['ID', 'name']
		});
		
		obj.Query.emptyText = 'Query to base this report on.';
		obj.Query.displayField = 'name';
		obj.Query.valueField = 'ID';
		
		obj.ReportType.store = new Ext.data.ArrayStore({
			fields: [
				'displayText'
			],
			data: [['Data'],['Email'],['Graph'],['Template']]
		});
		obj.ReportType.displayField = 'displayText';
		obj.ReportType.valueField = 'displayText';
		
		obj.CancelButton.handler = function() {
			obj.form.reset();
			obj.window.close();
		};

		obj.SaveButton.handler = function() {
			if (obj.form.isValid()) {
				var params = Object();
				params['ReportType'] = obj.ReportType.getValue();
				obj.form.submit({
					url: 'home/saveMultiObject/ReportItem',
					waitMsg: 'Saving report, please wait...',
					params: params,
					success: function() {
						obj.form.reset();
						obj.window.close();
					}
				});
			}
		};
	});
}
