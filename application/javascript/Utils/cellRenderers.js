/* custom cell renders */
/* Various functions for render data in search grids throughout the application */
     

/* Renderer - used in column model column object */	 
function renderIcon(val) {
	if(val != undefined) {
    	return '<img src="' + val + '" style="width: 16px; height: 16px; padding: 0px; margin: 0px;">';
    }
}

/* Renderer - used in column model column object */	
function renderIconObject(obj) {
	if(obj != undefined) {
		return '<img src="' + obj.Filename + '" style="width: 16px; height: 16px; padding: 0px; margin: 0px;">';
	}
}

/* Render Icons for yes/no true/false conditions */
function boolIcon(val) {
	var icon = 'application/images/bool/false2.png';
	if(val == "true" || val == 1 || val == true) {
		icon = 'application/images/bool/true.png';
	}
	return '<img src="' + icon + '" style="width: 16px; height: 16px; padding: 0px; margin: 0px;">';
}

/* Renderer - used in column model column object */	
function ukMoney(val) {
	var v = val ? parseFloat(val) : 0;
    return '&pound;' + v.toFixed(2);
}

/* Renderer - used in column model column object */	
function booleanYesNo(val) {
    return (val == 1) ? "Yes" : "No";
}

/* Converter - used in data store field object */	
function convertDataMapping(v, record) {
	console.log(v);
	console.log(record);
}

/**
 * Author: David Sloane
 *
 * Handles null values and undefined mapping data to stop
 * javascript tables throwing errors.
 *
 * Converter - used in data store field object
 */
function dataMapping(v, record) {
	return (v != null && v != undefined) ? v : "";
}

/**
 * Author: David Sloane
 *
 * Extracts the title, forename and surname attributes of a contact record,
 * and returns as a single string.
 *
 * Converter - used in data store field object
 */
function contactName(v, record) {
	return record.title.name + " " + record.forename + " " + record.surname;
}

/**
 * Author: David Sloane
 *
 * Extracts the title, forename and surname attributes of a contact record,
 * and returns as a single string.
 *
 * Converter - used in data store field object
 */
function incidentContactName(v, record) {
	return record.contactName + " " + record.contactSurname;
}

/**
 * Author: David Sloane
 *
 * Work's out wether a contact belongs to a supplier or customer and returns
 * the relevent company or supplier name.
 *
 * Converter - used in data store field object
 */
function contactCompany(v, record) {
	if (record.customerID != "0" && record.customerID != null && record.customerID != undefined) {
		return record.customer.companyName;
	} else if (record.supplierID != "0" && record.supplierID != null && record.supplierID != undefined) {
		return record.supplier.companyName;
	} else {
		return "Not Specified";
	}
}

/**
 * Author: David Sloane
 *
 * Extracts the Reg Number, Make and Description attributes of a vehicle record,
 * and returns as a single string. used in add vehicle to quote item screen.
 *
 * Converter - used in data store field object
 */
function vehicleDescription(v, record) {
	return record.Vrm + " " + record.Make + " " + record.DVLABodyPlanDescription;
}

/**
 * Author: David Sloane
 *
 * Extracts the Reg Number, Make and Description attributes of a vehicle record,
 * and returns as a single string. used in add vehicle to quote item screen.
 *
 * Renderer - used in column model column object
 */
function vehicleDescriptionRender(v) {
	return v.Vrm + " " + v.Make + " " + v.DVLABodyPlanDescription;
}

/**
 * Author: David Sloane
 *
 * Collates all the entitlements attatched either directly to this policy,
 * or to vehicles that this policy covers.
 *
 * Renderer - used in column model column object
 */
function policyEntitlements(icons) {
	if(typeof icons == "string") {
		icons = Ext.decode(icons);
		icons = icons.rows[0].icons;
	}
	if (icons == null || icons == undefined || icons.length == 0) {
		return '<p>no entitlements</p>';
	} else {
		var output = '';
		for (var i=0; i<icons.length; i++) {
			output += '<img src="' + icons[i].icon + '" style="width: 16px; height: 16px; padding: 0px; margin: 0px 5px 0px 0px;" alt="' + icons[i].tooltip + '" title="' + icons[i].tooltip + '" />';
		}
		return output;
	}
}

/**
 * Author Graham Bacon
 * A custom render to map the VAT Type for display in the quotes section
 *
 * Returns the VAT Type as a String
 */
function quoteVatType(obj){
	if(obj.vatType != undefined) {
		return obj.vatType.name;
	} else {
		return "None";
	}
}

/**
 * Author: David Sloane
 *
 * Takes a silverstripe SSDateTime string of the format "Y-m-d H:i:s"
 * and returns the date portion, reformaatted as "d/m/Y"
 * E.g passing in "2011-01-23 10:15:32" would return "23/01/2011".
 *
 * Renderer - used in column model column object
 */
function SSDatetime_Date(date_string) {
	var myDate = Date.parseDate(date_string, "Y-m-d H:i:s");
	return myDate.format("d/m/Y");
}

/**
 * Author: David Sloane
 *
 * Takes a silverstripe SSDateTime string of the format "Y-m-d H:i:s"
 * and returns the time portion, reformaatted as "H:i"
 * E.g passing in "2011-01-23 10:15:32" would return "10:15".
 *
 * Renderer - used in column model column object
 */
function SSDatetime_Time(date_string) {
	var myDate = Date.parseDate(date_string, "Y-m-d H:i:s");
	return myDate.format("H:i");
}

/* Render star icon if selected value is true */
function yesIcon(val) {
	if(val == "true" || val == 1 || val == true) {
		return '<img src="application/images/bool/yes.png" style="width: 16px; height: 16px; padding: 0px; margin: 0px;">';
	}
	return '';
}

/* Render building icon if supplier is HQ */
function isHQ(val) {
	if(val == "true" || val == 1 || val == true) {
		return '<img src="application/images/bool/hq.png" style="width: 16px; height: 16px; padding: 0px; margin: 0px;">';
	}
	return '';
}

/**
 * Author Graham Bacon
 * Function is not a cell renderer persay, it generates random pastel colors for use in the application.
 * Returns the color as a HTML Hex.
**/
function generatePastelColor() {
    var red = Math.floor(Math.random() * 256);
    var green = Math.floor(Math.random() * 256);
    var blue = Math.floor(Math.random() * 256);

	red = (red + 255) / 2;
	green = (green + 255) / 2;
	blue = (blue + 255) / 2;
    
    return RGBtoHex(red, green, blue);
}

function RGBtoHex(R,G,B) {return toHex(R)+toHex(G)+toHex(B)}

function toHex(N) {
	if (N==null) return "00";
	N=parseInt(N); if (N==0 || isNaN(N)) return "00";
	N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
	return "0123456789ABCDEF".charAt((N-N%16)/16) + "0123456789ABCDEF".charAt(N%16);
}


