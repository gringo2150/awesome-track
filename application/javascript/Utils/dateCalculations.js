/* Functions for manipulating dates and
 * performing date related calculations
 */
 
/* Author: David Sloane
 *
 * calculates the difference between the 2 given dates, start and end,
 * and returns the result in the units specified.
 * Note: start and end must be of the Date object type.
 * if roundUp is set to false, this function will round down rather than up.
 */
function dateDifference(start, end, unit, roundUp) {
	var units = 1000*60*60*24; // default to days
	if (unit == "milliseconds") {
		units = 1;
	}
	if (unit == "seconds") {
		units = 1000;
	}
	if (unit == "minutes") {
		units = 1000*60;
	}
	if (unit == "hours") {
		units = 1000*60*60;
	}
	if (unit == "days") {
		units = 1000*60*60*24;
	}
	if (unit == "weeks") {
		units = 1000*60*60*24*7;
	}
	if (unit == "months") {
		units = 1000*60*60*24*30;
	}
	if (unit == "calendarmonths") {
		units = 1000*60*60*24*7*4;
	}
	if (unit == "years") {
		units = 1000*60*60*24*365.25;
	}
	return roundUp ? Math.ceil((end.getTime() - start.getTime())/units) : Math.floor((end.getTime() - start.getTime())/units);
}

var dates = {
    convert:function(d) {
        return (
            d.constructor === Date ? d :
            d.constructor === Array ? new Date(d[0],d[1],d[2]) :
            d.constructor === Number ? new Date(d) :
            d.constructor === String ? new Date(d) :
            typeof d === "object" ? new Date(d.year,d.month,d.date) :
            NaN
        );
    },
    compare:function(a,b) {
        return (
            isFinite(a=this.convert(a).valueOf()) &&
            isFinite(b=this.convert(b).valueOf()) ?
            (a>b)-(a<b) :
            NaN
        );
    },
    inRange:function(d,start,end) {
        return (
            isFinite(d=this.convert(d).valueOf()) &&
            isFinite(start=this.convert(start).valueOf()) &&
            isFinite(end=this.convert(end).valueOf()) ?
            start <= d && d <= end :
            NaN
        );
    }
}