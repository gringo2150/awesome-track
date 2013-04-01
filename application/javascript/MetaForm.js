//Prehaps just update this to just get the grid and set the store and columnModel internally.
//This would allow refreshes upon completion.
function metaFormParser(store, columnModel, grid, object, editData, fromStore) {
	if(editData === undefined) {
		editData = false;
	}
	if(fromStore === undefined) {
		fromStore = false;
	}
	var fields = Array();
	if(fromStore == false) {
		Ext.each(columnModel.columns, function(column, index) {
			if(column.dataIndex != '') {
				var field = Object();
				Ext.each(store.reader.meta.fields, function(meta, mIndex) {
					if(meta.name == column.dataIndex) {
						field.type = meta.type;
						field.xtype = meta.xtype;
					}
				});
				field.name = column.dataIndex;
				field.fieldLabel = column.header;
				//Fix this to get shut of the hidden fields in the forms.
				if(column.hidden != undefined) {
					field.hidden = column.hidden;
				} else {
					field.hidden = false;
				}
				fields.push(field);
			}
		});
	} else {
		//Do the from store method
	}
	
	var form = new Ext.form.FormPanel({
		height: '100%',
		width: '100%',
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
		reader: new Ext.data.JsonReader(store.reader.meta),
		items: fields
	});
	//Need to get the edit data through for the edit method, change the submit and also the button title.
	var params = Object();
	if(editData != false) {
		params.ID = editData.ID;
	}
	var window = new Ext.Window({
		width: 350,
		title: 'Meta Form',
		border: false,
		items:[form],
		buttons: [{
			text: 'Cancel',
			handler: function() {
				window.close();
			}
		},{
			text: (editData == false) ? 'Add' : 'Update',
			handler: function() {
				if(form.getForm().isValid()) {
					form.getForm().submit({
						url: (editData == false) ? 'home/saveMultiObject/'+object : 'home/updateMultiObject/'+object, //Get this to do a if condition.
						waitMsg: 'Saving '+object+', please wait...',
						params: params,
						success: function(f, a) {
							window.close();
							store.load();	
						},
						failure: function() {
						}
					});
				}
			}
		}]
	});
	if(editData != false) {
		form.getForm().setValues(editData);
	}
	window.show();
} 
