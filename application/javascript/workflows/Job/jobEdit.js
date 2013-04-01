function jobEdit(ID, store) {
	if(store == null || store == undefined){
		var search = Ext.getCmp('SearchModule')
		store = search.store;
	}
	parseForm('Job_Add.frm','Edit Job', function(obj){
		
		/*** Start Combo Store Config ***/
		/*** End Combo Store Config ***/
		
		/*** Start Table Config ***/
		
		obj.MeasureTable.store = new Ext.data.JsonStore({
			autoLoad: false,
			idProperty: 'ID',
			root: 'rows',
			totalProperty: 'results',
			fields: [
				"ID",
				"Unit",
				"Value", 
				"Cost"
			],
			baseParams: {
				column: 'JobID',
				value: ID
			},
			proxy: new Ext.data.HttpProxy({
				url: 'home/getChildObjects/Measure'
			})
		});
		obj.MeasureTable.colModel = new Ext.grid.ColumnModel({
			defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', canSearch: true, incSearch: false, hidden: true},
				{header: 'Unit', dataIndex: 'Unit', canSearch: true, incSearch: true, hidden: false},
				{header: 'Value', dataIndex: 'Value', canSearch: true, incSearch: true, hidden: false},
				{header: 'Cost', dataIndex: 'Cost', canSearch: true, incSearch: true, hidden: false}
			]
		});
		obj.MeasureTable.reconfigure(obj.MeasureTable.store, obj.MeasureTable.colModel);
		
		/*** End Table Config ***/
		
		/*** Button Config Start ***/
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.form.reset();
			obj.window.close();
		};
		
		
		obj.AddButton.setText('Update');
		obj.AddButton.handler = function() {
			obj.form.submit({
				url: 'home/updateSingleObject/Job' + ID,
				waitMsg: 'Updating Job...',
				submitEmptyText: false,
				params: {},
				success: function(fp, o){
					Ext.Msg.show({
						title:'Updated Job',
						msg: 'A new job '+ ID +' has been updated',
						buttons: Ext.Msg.OK,
						icon: Ext.MessageBox.INFO
					});
					if(store != null || store != undefined) {
						store.load();
					}
					obj.form.reset();
					obj.window.close();
				}
			});
		};
		
		obj.form.trackResetOnLoad = true;
		obj.form.load({
			url:'home/selectSingleObject/Job/'+ID,
			waitMsg:'Loading record please wait...',
			fileUpload: true,
			success: function(form, action){
			}
		});
	});
}