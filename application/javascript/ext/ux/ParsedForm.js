/**
 * @class Ext.ux.form.ParsedForm
 * @extends Ext.Panel
 * @author Graham Bacon
 *
 * Uses Jquery to function.
 */
Ext.ux.form.ParsedForm = Ext.extend(Ext.Panel, {
    initComponent : function(){
        
        var defConfig = {
            border: false,
            layout: 'absolute',
            //title: 'form',
            formData: '',
            formWindow: '',
            labelAlign: 'top'
        };
        
        Ext.applyIf(this,defConfig);
        
        Ext.ux.form.ParsedForm.superclass.initComponent.call(this);        

    },
    afterRender : function(){
        
        var wh = this.ownerCt.getSize();
        Ext.applyIf(this, wh);
        
        Ext.ux.form.ParsedForm.superclass.afterRender.call(this);    
        
        //if (this.formUrl != '') {
        	//var url = this.formUrl;
        	var target = this.body.dom;
        	var form = this;
        	var formWindow = this.formWindow;

        		xml = (new DOMParser()).parseFromString(this.formData, "text/xml");
        		$(xml).find('pageType').each(function(){
        			form.setHeight = $(this).attr('height');
        			formWindow.setHeight = $(this).attr('height');
        			form.setWidth = $(this).attr('width');
        			formWindow.setWidth = $(this).attr('width');
        			form.setTitle = $(this).attr('label');
        			form.add(new Ext.Button({text: 'testing'}));
        		});
        		$(xml).find('pageType').children().each(function(){
					var x = $(this).attr("x");
					var y = $(this).attr("y");
					var height = $(this).attr("height");
					var width = $(this).attr("width");
					var ID = $(this).attr("id");
					var label = $(this).attr("label");
					var item = new Ext.form.TextField({
						fieldLabel: label,
						x: x,
						y: y,
						height: height,
						width: width,
						name: ID
					});
					form.add(item);
				});
				var window = new Ext.Window({
					items: [form],
					title: 'testing'
				});
				window.show();
		//}
    } 
});

Ext.reg('parsed-form', Ext.ux.form.ParsedForm); 
