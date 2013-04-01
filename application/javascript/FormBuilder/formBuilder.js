var formBuilderWin = null;

function formBuilderWindow() {
	if(formBuilderWin == null) {
		formBuilderWin = new Ext.Window({
			contentEl:'formBuilderWindow',
			height: 480,
			width: 640,
			maximizable: true,
			title: 'Form Builder',
			closeAction: 'hide'
		});
		Ext.get('formBuilderWindow').show();
	}
	iblWinMgr.register(formBuilderWin);
	formBuilderWin.show();
	//formBuilderWin.maximize();
}

//Needs to call newformbuilderform(name,width,height); when done, to start in the flash. (newForm)
function formBuilderNew() {
	parseForm('formBuilderNew.frm', 'New Form', function(obj) {
		//Create Button action
		obj.createButton.handler = function() {
			if (obj.form.isValid()) {
				var frmName = obj.formName.getValue();
				var frmHeight = obj.formHeight.getValue();
				var frmWidth = obj.formWidth.getValue();
				getFlashMovie('formBuilderFlash').newForm(frmName, frmWidth, frmHeight);
				obj.window.close();
			}
		};
		//Cancel Button action
		obj.cancelButton.handler = function() {
			obj.window.close();
		};
	});
}

//Needs to call openformBuilderForm(xmlStr); when done to start the flash. (openForm)
function formBuilderOpen() {
	parseForm('formBuilderOpen.frm', 'Open Form', function(obj) {
		//Open Button action
		obj.openButton.handler = function() {
			var selection = obj.openFormList.getSelectionModel().getSelections();
			if(selection[0].data.dir == false) {
				var randomGetData = new Date().getTime();
				var url = 'application/forms/' + selection[0].data.path + '/' + selection[0].data.name + '?_gd=' + randomGetData;
				$.get(url, function(data) {
					getFlashMovie('formBuilderFlash').openForm(data);
					obj.window.close();
				});
			} else {
				var dirPath = '';
				if(selection[0].data.name == '..') {
					dirPath = selection[0].data.path + '/';
				} else {
					dirPath = selection[0].data.path + selection[0].data.name + '/';
				}
				tableStore.load({
					params: {
						dir: dirPath
					}
				});
			}
		};
		//Cancel Button action
		obj.cancelButton.handler = function() {
			obj.window.close();
		};
		var tableStore = new Ext.data.JsonStore({
			idProperty: 'ID',
			root: 'rows',
			totalProperty: 'results',
			fields: [
				'icon',
				'name',
				{name:'dir', type: 'boolean'},
				'path'
			],
			sortInfo: {
				field: 'dir',
			    direction: 'DESC'
			},
			url: 'home/listForms',
			autoLoad: false
		});
		tableStore.load({
			params: {
				dir: '/'
			}
		});
		obj.openFormList.store = tableStore;
		obj.openFormList.colModel = new Ext.grid.ColumnModel({
	      	defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{header: '', width: 16, dataIndex: 'icon', renderer:renderIcon},
				{header: 'Form Name', width: 150, dataIndex: 'name'}
			]
	   	});
		obj.openFormList.on('rowdblclick', function() {
			var selection = obj.openFormList.getSelectionModel().getSelections();
			if(selection[0].data.dir == false) {
				var url = 'application/forms/' + selection[0].data.path + '/' + selection[0].data.name;
				$.get(url, function(data) {
					getFlashMovie('formBuilderFlash').openForm(data);
					obj.window.close();
				});
			} else {
				var dirPath = '';
				if(selection[0].data.name == '..') {
					dirPath = selection[0].data.path + '/';
				} else {
					dirPath = selection[0].data.path + selection[0].data.name + '/';
				}
				tableStore.load({
					params: {
						dir: dirPath
					}
				});
			}
		});
	   	obj.openFormList.reconfigure(obj.openFormList.store, obj.openFormList.colModel);
	});
}

function formBuilderSave(obj) {
	//loadingMask.show();
	Ext.Ajax.request({
		url: 'home/saveForm',
		waitMsg: 'Saving the form please wait',
		success: function(data){
			//loadingMask.hide();
			Ext.Msg.alert('Form Builder', 'The form ' + obj.name + '.frm has been saved to the form store.');
		},
		failure: function(data){
			//loadingMask.hide();
		},
		params: { name: obj.name, data: obj.data }
	});
}

function formBuilderAlert(obj) {
	Ext.Msg.alert('Form Builder', obj.msg);
}

function formBuilderHelp() {
	alert('help pressed');
}

//call updateFormProp to update
function formBuilderComponentProps(obj) {
	if(obj.data.component == 'textBox') {
		parseForm('system/FormBuilder/properties/FormTextboxProps.frm', 'Textbox Properties', function(pObj) {
			pObj.form.setValues(obj.data);
		});
	}
}

function getFlashMovie(movieName) {
  var isIE = navigator.appName.indexOf("Microsoft") != -1;
  return (isIE) ? window[movieName] : document.embeds[movieName];
}
