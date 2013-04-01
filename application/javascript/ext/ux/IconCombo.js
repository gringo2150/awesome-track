// Create user extensions namespace (Ext.ux)
Ext.namespace('Ext.ux');
 
/**
  * Ext.ux.IconCombo Extension Class
  *
  * @author  Jozef Sakalos
  * @version 1.0
  *
  * @class Ext.ux.IconCombo
  * @extends Ext.form.ComboBox
  * @constructor
  * @param {Object} config Configuration options
  */
Ext.ux.IconCombo = function(config) {
 
    // call parent constructor
    Ext.ux.IconCombo.superclass.constructor.call(this, config);
 	
 	this.icon = '';
 	
    this.tpl = config.tpl ||
          '<tpl for="."><div class="x-combo-list-item x-icon-combo-item" style="background: url({' 
        + this.iconClsField 
        + '}) top left no-repeat;">{' 
        + this.displayField 
        + '}</div></tpl>'
    ;
 
    this.on({
        render:{scope:this, fn:function() {
            var wrap = this.el.up('div.x-form-field-wrap');
            this.wrap.applyStyles({position:'relative'});
            this.el.addClass('x-icon-combo-input');
            this.icon = Ext.DomHelper.append(wrap, {
                tag: 'div', style:'position:absolute; height: 16px; width: 16px;'
            });
        }}
    });
} // end of Ext.ux.IconCombo constructor
 
// extend
Ext.extend(Ext.ux.IconCombo, Ext.form.ComboBox, {
 
    setIconCls: function() {
        var rec = this.store.query(this.valueField, this.getValue()).itemAt(0);
        if(rec) {
			this.icon.className = 'x-icon-combo-icon';
			var obj = Ext.get(this.icon);
			obj.setStyle({position:'absolute', background: "url('"+ rec.get(this.iconClsField) +"') top left no-repeat", height: '16px', width: '16px'});
        }
    },
 
    setValue: function(value) {
        Ext.ux.IconCombo.superclass.setValue.call(this, value);
        this.setIconCls();
    }
 
}); // end of extend
 
// end of file
