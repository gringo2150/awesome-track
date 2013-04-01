Ext.namespace("Ext.ux"); 

Ext.ux.StoreDependencyController = function(config) { 
     
    Ext.apply(this, {  
        comboboxes: [], 
        comboload: 0,
        params: null,
        allLoaded: false
    });   
     
}; 

Ext.apply(Ext.ux.StoreDependencyController.prototype, { 
    registerCombo: function(combo){ 
		if(combo.mode == 'remote') {       
        	this.comboboxes.push(combo);
        	this.refreshStores();
        }
    },
    refreshStores: function() {
    	this.allLoaded = false;
    	this.comboload = 0;
    	if(this.comboboxes.length != this.comboload){
			Ext.each(this.comboboxes, function(combo, index, all){
				if(combo.store != undefined || combo.store != null) {
					if(combo.mode == 'remote') {
						combo.store.on('load', function(){ 
							this.comboload += 1;
							if (this.comboboxes.length == this.comboload) { 
								this.allLoaded = true;
								if(this.params != undefined || this.params != null){
									this.deferredLoadStore.load(this.params);
								} else {
									this.deferredLoadStore.load();
								}         
							} 
						}, this);
					}
				}
		    }, this);
        } else {
        	this.allLoaded = true;
			if(this.params != undefined || this.params != null){
				this.deferredLoadStore.load(this.params);
			} else {
				this.deferredLoadStore.load();
			}
        }
    },
    loadStores: function() {
    	Ext.each(this.comboboxes, function(combo, index, all){
    		if(combo.store != undefined || combo.store != null) { 
    			if(combo.mode == 'remote') {
    				combo.store.load();
    			}
    		}
    	});
    },
    setDeferredLoadStore: function(store){ 
        this.deferredLoadStore = store; 
    },
    setBaseParams: function(params){
    	this.params = params;
    }
});

/**
 * Clone Function
 * @param {Object/Array} o Object or array to clone
 * @return {Object/Array} Deep clone of an object or an array
 * @author Ing. Jozef Sakáloš
 */
Ext.ux.clone = function(obj){
   var seenObjects = [];
   var mappingArray = [];
   var	f = function(simpleObject) {
      var indexOf = seenObjects.indexOf(simpleObject);
      if (indexOf == -1) {			
         switch (Ext.type(simpleObject)) {
            case 'object':
               seenObjects.push(simpleObject);
               var newObject = {};
               mappingArray.push(newObject);
               for (var p in simpleObject) 
                  newObject[p] = f(simpleObject[p]);
               newObject.constructor = simpleObject.constructor;				
            return newObject;
 
            case 'array':
               seenObjects.push(simpleObject);
               var newArray = [];
               mappingArray.push(newArray);
               for(var i=0,len=simpleObject.length; i<len; i++)
                  newArray.push(f(simpleObject[i]));
            return newArray;
 
            default:	
            return simpleObject;
         }
      } else {
         return mappingArray[indexOf];
      }
   };
   return f(obj);	
}; // eo function clone 

function parseForm(formName, formTitle, callback) {
	var loadingMask = new Ext.LoadMask(Ext.getBody(), {msg:"Loading window please wait..."});
	loadingMask.show();
	var randomGetData = new Date().getTime();
	var url = 'application/forms/' + formName + '?_gd=' + randomGetData;
	$.get(url, function(data) {
		var xml = null;
		try {
			parser=new DOMParser();
			xml=parser.parseFromString(data,"text/xml");
		} catch(err) { // Internet Explorer
			xml=new ActiveXObject("Microsoft.XMLDOM");
			xml.async="false";
			xml.loadXML(data); 
		}
		//var xml = (new DOMParser()).parseFromString(data, "text/xml");
		//Set-up form properties
		var formHeight;
		var formWidth;
		var iconCls;
		var ID = Ext.id();
		var formID = Ext.id();
		var returnObject = new Object();
		var formItems = new Array();
		var readerField = new Array();
		var comboStoreControler = new Ext.ux.StoreDependencyController();
		$(xml).find('pageType').each(function(){
			formHeight = parseInt($(this).attr("height"));
			formWidth = parseInt($(this).attr("width"));
			iconCls = $(this).attr("iconCls");
			$("body").append("<div id=\""+ID+"\" class=\"iblForm\" style=\"display: none; position: relative; height: "+formHeight+"px; width: "+formWidth+"px;\"><form id=\""+formID+"\"style=\"height: "+formHeight+"px; width: "+formWidth+"px;\"></form></div>");
		});
		//Call the form item parser to do the heavy lifting and make this a little more recursive
		var renderedItems = __processFormItems(xml, formID, comboStoreControler);
		$.extend(returnObject, renderedItems.returnObject);
		$.merge(formItems, renderedItems.formItems);
		$.merge(readerField, renderedItems.readerField);
		//Mask for the form
		var myMask = new Ext.LoadMask(Ext.get(ID), {msg:"Please wait..."});
		var extForm = new Ext.form.BasicForm(formID, {
			fileUpload: true,
			listeners: {
				beforeaction: function(form, action) {
					if(action.type == 'load') {
						myMask.show();
						if(comboStoreControler.allLoaded == false) {
							comboStoreControler.setBaseParams(action.options);
							comboStoreControler.refreshStores();
							comboStoreControler.loadStores();
						}
						return comboStoreControler.allLoaded;
					}
				},
				actioncomplete: function(form, action) {
					if(action.type == 'load') {
						myMask.hide();
					}
				}
			}
		});
		comboStoreControler.setDeferredLoadStore(extForm);
		/*Ext.get(formID).on('contextmenu', function(e) {
			if(returnObject['isReadOnlyMode'] == false) {
				if(returnObject['contextMenu'].items.items.length > 0) {
					returnObject['contextMenu'].showAt(e.getXY());
				} else {
					
				}
			} else {
				returnObject['readOnlyContextMenu'].showAt(e.getXY());
			}
			e.preventDefault();
		});*/
		for (var i=0; i<formItems.length; i++) {
			extForm.add(formItems[i]);
		}
		extForm.reader = new Ext.data.JsonReader({
			idProperty: 'ID',
			root: 'data',
			totalProperty: 'results',
			fields: readerField
		});
		returnObject['form'] = extForm;
		$('#'+ID).show();
		var managerButtonID = Ext.id();
		//Read only mode config
		returnObject['isReadOnlyMode'] = false;
		returnObject['isReadOnlyObjects'] = Array();
		returnObject['setReadOnlyMode'] = function (mode, objArr) {
			setReadOnlyMode(returnObject.form, mode, objArr);
			returnObject['isReadOnlyObjects'] = objArr;
			returnObject['isReadOnlyMode'] = mode;
		}
		//Context Menu config
		returnObject['contextMenu'] = new Ext.menu.Menu({
			items: []
		});
		//Internal read only context menu config
		returnObject['readOnlyContextMenu'] = new Ext.menu.Menu({
			items: [{
				text: 'Edit Form',
				icon: 'application/images/toolbars/edit.png',
				handler: function() {
					setReadOnlyMode(returnObject.form, false, returnObject['isReadOnlyObjects']);
					returnObject['isReadOnlyMode'] = false;
				}
			}]
		});
		//Popup window config
		returnObject['cancelWarning'] = true;
		returnObject['cancelFlag'] = false;
		//Need to set in a before close event, a cancel answer flag and an enable cancel warning flag.
		var window = new Ext.Window({
			contentEl: ID,
			layout: 'fit',
			width: (formWidth + 14),
			height: (formHeight + 32),
			closeAction:'close',
			plain: false,
			resizable: false,
			title: formTitle,
			//iconCls: iconCls ? iconCls : 'cake',
			constrain: true,
			minimizable: true,
			managerButtonID: managerButtonID,
			listeners: {
				beforeclose: function() {
					if(returnObject['cancelFlag'] == false && returnObject['cancelWarning'] == true) {
						if(extForm.isDirty()) {
							Ext.Msg.confirm('Form has changed', 'Closing this form now will lose information entered, are you sure you want to do this?', function(btn) {
								if (btn == 'yes') {
									returnObject['cancelFlag'] =  true;
									window.close();
								} else {
									returnObject['cancelFlag'] =  false;
								}
							});	
						} else {
							returnObject['cancelFlag'] = true;
							window.close();
						}
					}
					return returnObject['cancelFlag'];
				},
				close: function() {
					iblWinMgr.unregister(window);
					Ext.getCmp('windowManagerArea').remove(managerButtonID);
				},
				minimize: function() {
					window.hide();
				}
			}
		});
		Ext.getCmp('windowManagerArea').add(new Ext.SplitButton({
			cls: 'wmButton',
			id: managerButtonID,
			text: window.title + '&nbsp;',
			//iconCls: window.iconCls,
			handler: function(b, e) {
				var activeWindow = iblWinMgr.getActive();
				if(activeWindow == null) {
					window.show();
				} else {
					if(activeWindow.id == window.id) {
						if(window.hidden == false){
							window.hide();
						}
					} else {
						if(window.hidden == true) {
							window.show();
						}
						iblWinMgr.bringToFront(window.id);
					}
				}
			},
			arrowHandler: function() {
				window.close();
			}
		}));
		iblWinMgr.register(window);
		returnObject['window'] = window;
		returnObject['loadMask'] =  myMask;
		returnObject['processJson'] = function(object) {
			var tempParams = extForm.getValues();
			Ext.applyIf(tempParams,object);
			var jsonData = new Object();
			for(var index in tempParams) {
				var depth = index.split('.');
				if(depth.length > 1) {
					var tempObject = '';
					for(var i=0; i<depth.length; i++) {
						if(tempObject == '') {
							tempObject += depth[i];
						} else {
							tempObject += '.'+depth[i];
						}
						if(i+1 != depth.length) {
							if(eval('jsonData.'+tempObject) == undefined) {
								eval('jsonData.'+tempObject+' = new Object();');
							}
						} else {
							eval('jsonData.'+tempObject+' = tempParams[index];');
						}
					}
					
				} else {
					jsonData[index] = tempParams[index];
				}
			}
			return jsonData;
		};
		window.show();
		loadingMask.hide();
		callback(returnObject);
		Ext.getCmp('main').doLayout();
	});
}

function __processFormItems(xml, formID, comboStoreControler) {
	var returnObject = new Object();
	var formItems = new Array();
	var readerField = new Array();
	$(xml).find('pageType').children().each(function(){
		var x = $(this).attr("x");
		var y = $(this).attr("y");
		var height = $(this).attr("height");
		var width = $(this).attr("width");
		var extID = Ext.id();
		var elID = $(this).attr("id");
		var label = $(this).attr("label");
		var validation = $(this).attr("validation");
		var allowBlank = $(this).attr("allowBlank");
		var tabOrder = $(this).attr("tabOrder") ? parseInt($(this).attr("tabOrder")) : 0;
		if($(this).is("textBox")) {
			var inputType = ($(this).attr("password") == 'true') ? 'password' : 'text';
			var input = '<input id="'+extID+'" name="'+elID+'" class="iblTextBox validate" type="'+inputType+'" style="width: '+(width - 8)+'px; height: '+(height - 4)+'px; line-height: '+(height - 4)+'px;" validation="'+validation+'" >';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			var vtype = null;
			var mask = firstLetterUpper;
			if( validation != 'none') {
				if (validation == 'notNull') {
				} else if (validation == 'postcode') {
					mask = toUpper;
					vtype = validation;
				} else if (validation == 'email') {
					mask = function(f){};
					vtype = validation;
				} else {
					vtype = validation;
				}
			}
			if(allowBlank == 'true') {
				allowBlank = true;
			} else {
				allowBlank = false;
			}
			returnObject[elID] = new Ext.form.TextField({
				applyTo: extID, 
				vtype: vtype,
				inputType: inputType,
				allowBlank: allowBlank, 
				msgDisplay: 'block',
				enableKeyEvents: true,
				tabIndex: tabOrder,
				listeners: {
					/*render: function(c) {
  						Ext.QuickTips.register({
    						target: c.getEl(),
    						text: 'this is a test message',
    						anchor: 'right',
    						cls: 'formTip'
  						});
					},*/
					//keyup: mask
				}
			});
			formItems.push(returnObject[elID]);
			readerField.push({name: elID, type: 'string', mapping: elID});
		}
		if($(this).is("datebox")) {
			var input = '<input id="'+extID+'" name="'+elID+'" class="iblDateField validate" style="width: '+(width - (8 + 17))+'px; height: '+(height - 4)+'px; line-height: '+(height - 4)+'px;" validation="'+validation+'" >';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+width+"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			var vtype = null;
			var mask = firstLetterUpper;
			if( validation != 'none') {
				if (validation == 'notNull') {
				} else {
					vtype = validation;
				}
			}
			if(allowBlank == 'true') {
				allowBlank = true;
			} else {
				allowBlank = false;
			}
			returnObject[elID] = new Ext.form.DateField({
				applyTo: extID, 
				//vtype: vtype, 
				allowBlank: allowBlank, 
				msgDisplay: 'block',
				enableKeyEvents: true,
				tabIndex: tabOrder,
				listeners: {
				},
				width: width,
				height: height,
				format: 'd/m/Y'
			});
			formItems.push(returnObject[elID]);
			readerField.push({name: elID, type: 'string', mapping: elID});
		}
		if($(this).is("button")) {
			var icon = $(this).attr("icon");
			var input = '<input id="'+extID+'" name="'+elID+'" class="iblButton" type="button" style="display: none;width: '+(width - 2)+'px; height: '+height+'px; line-height: '+height+'px;" value="'+label+'" >';
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] = new Ext.Button({
				applyTo: extID,
				tabIndex: tabOrder,
				width: width, 
				height: height, 
				text: label,
				icon: icon ? 'application/images/forms/'+icon : false
				//tooltip: 'Testing button tooltip.'
			});
			//formItems.push(returnObject[elID]);
		}
		if($(this).is("comboBox")) {
			var input = '<div><input id="'+extID+'" style="width: '+(width - (8 + 17))+'px; height: '+(height - 4)+'px; line-height: '+(height - 4)+'px;" \/\></div>';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			/*var vtype = null;
			var allowBlank = true;
			if( validation != 'none') {
				if (validation == 'notNull') {
					allowBlank = false;
				} else {
					vtype = validation;
					allowBlank = false;
				}
			}*/
			returnObject[elID] = new Ext.form.ComboBox({
				applyTo: extID,
				name: elID,
				hiddenName: elID + 'ID',
				width: width,
				height: height,
				lazyRender:true,
				tabIndex: tabOrder,
				triggerAction: 'all',
				forceSelection: true,
				//vtype: vtype,
				allowBlank: true,
				mode: ($(this).attr("mode") == "local") ? "local" : "remote"
			});
			comboStoreControler.registerCombo(returnObject[elID]);
			formItems.push(returnObject[elID]);
			readerField.push({name: elID + 'ID', type: 'int', mapping: elID+'ID'});
		}
		if($(this).is("colorBox")) {
			var input = '<div id="'+extID+'" style="width: '+(width - (8 + 17))+'px; height: '+(height - 4)+'px; line-height: '+(height - 4)+'px;" ></div>';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] = new Ext.ux.ColorField({
				renderTo: extID,
				name: elID,
				hiddenName: elID + 'ID',
				width: width,
				height: height,
				lazyRender:true,
				tabIndex: tabOrder,
				triggerAction: 'all',
				//vtype: vtype,
				allowBlank: true,
				fallback: true
			});
			formItems.push(returnObject[elID]);
			readerField.push({name: elID + 'ID', type: 'int', mapping: elID+'.ID'});
		}
		if($(this).is("addFileBox")) {
			var input = '<div id="'+extID+'"></div>';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			var vtype = null;
			var allowBlank = true;
			if( validation != 'none') {
				if (validation == 'notNull') {
					allowBlank = false;
				} else {
					vtype = validation;
					allowBlank = false;
				}
			}
			returnObject[elID] = new Ext.ux.form.FileUploadField({
				renderTo: extID,
				name: elID,
				width: width,
				height: height,
				tabIndex: tabOrder,
				//vtype: vtype,
				//allowBlank: allowBlank,
				emptyText: 'Browse...',
				fieldLabel: 'Workflow Icon',
				buttonCfg: {
					icon: 'application/images/buttons_icons/image_add.png'
				}
			});
			formItems.push(returnObject[elID]);
		}
		if($(this).is("hSlider")) {
			var input = '<div id="'+extID+'"></div>';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] = new Ext.Slider({
				renderTo: extID,
				name: elID,
				width: (parseInt(width) - 8),
				height: height,
				minValue: 0,
				maxValue: 100
			});
			//formItems.push(returnObject[elID]);
		}
		if($(this).is("hRule")) {
			var input = "<div id=\""+extID+"\" class=\"iblHRule\"style=\"height: "+(height - 1)+"px; width: "+width+"px;\"><p class=\"inputLabel\" style=\"width: "+width+"px;\">"+label+"</p></div>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
		}
		if($(this).is("label")) {
			var input = "<div id=\""+extID+"\" class=\"iblLabel\"style=\"height: "+(height - 1)+"px; width: "+width+"px;\"><p class=\"inputLabel\" style=\"width: "+width+"px;\">"+label+"</p></div>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] = new Ext.form.Label({
				applyTo: extID, 
				width: width, 
				height: height,
				text: label
			});
			//formItems.push(returnObject[elID]);
		}
		if($(this).is("image")) {
			var input = '<div id="'+extID+'"></div>';
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] =  new Ext.Component({
				renderTo: extID, 
				autoEl: { tag: 'img', src: '', height: 100, width: 100},
				name: elID,
				setValue: function(src) {
					returnObject[elID].el.dom.src = src;
				},
				getValue: function() {
					return returnObject[elID].el.dom.src;
				}
			});
			//formItems.push(returnObject[elID]);
		}
		if($(this).is("numberbox")) {
			var input = '<input id="'+extID+'" name="'+elID+'" style="width: '+(width - (8 + 17))+'px; height: '+(height - 4)+'px; line-height: '+(height - 4)+'px;" validation="'+validation+'" >';
			var labelObj = "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+width+"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] = new Ext.form.NumberField({
				applyTo: extID,
				tabIndex: tabOrder,
				width: width,
				height: height
			});
			formItems.push(returnObject[elID]);
			readerField.push({name: elID, type: 'int', mapping: elID});
		}
		if($(this).is("textArea")) {
			var richText = ($(this).attr("richText") == 'true') ? true : false;
			var input = '';
			if(richText == true) {
				input = '<div id="'+extID+'"></div>';
			} else {
				input = '<textarea id="'+extID+'" name="'+elID+'"></textarea>';
			}
			var labelObj= "<p class=\"inputLabel\" style=\"width: "+width+"px; height: 20px;\">"+label+":</p>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += labelObj;
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			if(richText == false) {
				returnObject[elID] = new Ext.form.TextArea({
					applyTo: extID, 
					tabIndex: tabOrder,
					width: (width -1), 
					height: (height -1)
				});
			} else {
				returnObject[elID] = new Ext.form.HtmlEditor({
					renderTo: extID, 
					tabIndex: tabOrder,
					name: elID,
					value: '',
					width: (width -1), 
					height: (height -30),
					//lazyRender: false,
					deferredRender: false
				});
			}
			formItems.push(returnObject[elID]);
			readerField.push({name: elID, type: 'string', mapping: elID});
		}
		if($(this).is("checkBox")) {
			var input = '<div class="iblCheckBox" id="'+extID+'"></div>';
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			returnObject[elID] = new Ext.ux.form.XCheckbox({
				renderTo: extID, 
				name: elID,
				tabIndex: tabOrder,
				width: width, 
				height: height, 
				boxLabel: label, 
				submitOffValue: 'false', 
				submitOnValue: 'true'
			});
			formItems.push(returnObject[elID]);
			readerField.push({name: elID, type: 'boolean', mapping: elID});
		}
		if($(this).is("TableField")) {
			var input = "<div id=\""+extID+"\" style=\"width: "+width+"px; height: "+height+"px;\" class=\"iblTableField\"></div>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			var ss = ($(this).attr("multiSelect") == 'true') ? false : true;
			var border = true;
			var heightMod = 33;
			if($(this).attr("border") == 'false'){
				border = false;
				heightMod = 0;
			}
			returnObject[elID] = new Ext.grid.GridPanel({
				renderTo: extID, 
				name: elID,
				width: parseInt(width), 
				height: (parseInt(height)-heightMod), 
				title: (border == true) ? label : '',
				store: new Ext.data.JsonStore({}),
				colModel: new Ext.grid.ColumnModel({}),
				frame: border,
				border: border,
				hideBorders: !border,
				sm: new Ext.grid.RowSelectionModel({singleSelect:ss}),
				loadMask: true,
				listeners: {
					reconfigure: function(grid, store, cols){
						grid.getView().refresh();
					}
				},
				viewConfig: {
					forceFit: true
				}
			});
		}
		if($(this).is("map")) {
			var input = "<div id=\""+extID+"\" style=\"width: "+width+"px; height: "+height+"px;\" class=\"iblMapPanel\"></div>";
			var item = "<div class=\"inputContainer\" style=\" width: "+ width +"px; height: "+height+"px; top: "+y+"px; left: "+x+"px; \" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			var ss = ($(this).attr("multiSelect") == "true") ? false : true;
			var zoomLevel = $(this).attr("zoomLevel") ? parseInt($(this).attr("zoomLevel")) : 2;
			var lat = parseFloat($(this).attr("lat"));
			var lon = parseFloat($(this).attr("lon"));
			returnObject[elID] = new Ext.ux.OpenMapPanel({
				renderTo: extID, 
				name: elID, 
				width: parseInt(width), 
				height: parseInt(height), 
				title: label,
				zoomLevel: zoomLevel,
				frame: false,
				border: true,
				listeners: {
					mapReady: function(map) {
						map.setCenterLatLng(lat, lon, zoomLevel);
					}
				}
			});
		}
		if($(this).is("tabPanel")) {
			var tabHeight = height;
			var border = false;
			if($(this).attr("border") == 'true') {
				border = true;
				height = height - 28;
			}
			var itemWrapper = Ext.id();
			var input = "<div id=\""+extID+"\" style=\"width: "+width+"px; height: "+tabHeight+"px; \" class=\"iblTabPanel\"></div>";
			var item = "<div id=\""+itemWrapper+"\" class=\"inputContainer\" style=\" width: "+ width +"px; height: "+tabHeight+"px; top: "+y+"px; left: "+x+"px; overflow: hidden;\" >";
			item += input;
			item += "</div>";
			$('#' + formID).append(item);
			var tabItemsArray = $(this).attr("tabsToLoad").split(',');
			var tabLabelArray = $(this).attr("tabsLabels").split(',');
			var tabItems = [];
			$.each(tabItemsArray, function(index, value){
				var randomGetData = new Date().getTime();
				var url = 'application/forms/' + tabItemsArray[index] + '.frm?_gd=' + randomGetData;
				if (tabItemsArray[index] != 'null') {
					var tabID = Ext.id();
					var tabItem = "<div id=\""+tabID+"\" class=\"iblTabItem\" style=\"width: "+width+"px; height: "+tabHeight+"px; position: relative;\"></div>";
					$('#' + itemWrapper).append(tabItem);
					tabItems.push({contentEl:tabID, title:tabLabelArray[index], border: false, frame: false});
					$.ajax({
						url: url,
						async: false,
						success: function(data){
							var xml = null;
							try {
								parser=new DOMParser();
								xml=parser.parseFromString(data,"text/xml");
							} catch(err) { // Internet Explorer
								xml=new ActiveXObject("Microsoft.XMLDOM");
								xml.async="false";
								xml.loadXML(data); 
							}
							var renderedItems = __processFormItems(xml, tabID, comboStoreControler);
							$.extend(returnObject, renderedItems.returnObject);
							$.merge(formItems, renderedItems.formItems);
							$.merge(readerField, renderedItems.readerField);
						}
					});
				}
			});
			returnObject[elID] = new Ext.TabPanel({
				renderTo: extID,
				name: elID,
				height: parseInt(height),
				width: parseInt(width),
				enableTabScroll: true,
				frame: false,
				border: border,
				hideBorders: !border,
				activeTab: 0,
				defaults: {
					hideMode: 'offsets'
				},
				deferredRender: false, //This beaks the table forceFit! ...
				items:tabItems
			});
		}
		
	});
	return {returnObject: returnObject, formItems:formItems, readerField:readerField};
}

function firstLetterUpper(f) {
	var str = f.getValue();
	f.setValue(str.substr(0, 1).toUpperCase() + str.substr(1));
}

function toUpper(f) {
	var str = f.getValue();
	f.setValue(str.toUpperCase());
}

function setReadOnlyMode(f, v, but) {
	if (v == null || v == undefined) v = true;
	for(var i=0; i < f.items.length; i++){
		try{
			f.items.items[i].setDisabled(v);
		}  catch(e) {
			//console.log(e);
		}		
	}
	if(but != null && but != undefined) {
		for(var i=0; i<but.length; i++) {
			if(v == true) {
				if(but[i] != undefined) {
					but[i].disable();
				}
			} else {
				if(but[i] != undefined) {
					but[i].enable();
				}
			}
		}
	}
}
