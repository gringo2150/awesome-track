function booleanRender(value, metaData, record, rowIndex, colIndex, store) {
	var path = '';
	if(value === 'true' || value === '1' || value === 1 || value === true) {
		path = 'application/images/bool/yes.gif';
	} else {
		path = 'application/images/bool/no.gif';
	}
	return '<img src="' + path + '" />';
}