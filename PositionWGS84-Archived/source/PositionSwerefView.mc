using Toybox.WatchUi as Ui;
using Toybox.Position;
using Toybox.System;
using Toybox.Math;

class PositionSwerefView extends Ui.View {

    function initialize() {
        View.initialize();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    // Load your resources here
    function onLayout(dc) {
    	//System.println(dc.getWidth());
    	//System.println(dc.getHeight());
        setLayout(Rez.Layouts.MainLayout(dc));
        
        // For Debugging: Abisko STF Hut!
        /*
		var tt = new [2];
		tt[0] = 68.358106;
		tt[1] = 18.783799;
		System.println("N: " + tt[0]);
		System.println("E: " + tt[1]);
		tt[0] = Math.toRadians(tt[0]);
		tt[1] = Math.toRadians(tt[1]);
		var tt_sweref = getSweref99tmCoordinates(tt);
        System.println("N: " + tt_sweref[0]);
		System.println("E: " + tt_sweref[1]);
		*/
		// Must be: 
		// N: 7587571
		// E: 655650
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    function onPosition(info) {
	    var myLocation = info.position.toDegrees();
	    var myAccuracy = info.accuracy;
	    var qualityString = "";
	    var swerefCoordinates = [0, 0];
	    
	    if (myAccuracy >= Position.QUALITY_POOR )
	    {
	    	swerefCoordinates = getSweref99tmCoordinates(info.position.toRadians());
	    }
	    
	    var viewX = Ui.View.findDrawableById("NCoordinate");
	    viewX.setText(swerefCoordinates[0].toNumber().toString());
	    var viewY = Ui.View.findDrawableById("ECoordinate");
	    viewY.setText(swerefCoordinates[1].toNumber().toString());
	    var viewQ = Ui.View.findDrawableById("QualityValue");
	    switch (myAccuracy) {
	    	case Position.QUALITY_NOT_AVAILABLE:
	    		qualityString = "GPS Disabled";
	    		break;
	    	case Position.QUALITY_LAST_KNOWN:
	    		qualityString = "Searching ...";
	    		break;
	    	case Position.QUALITY_POOR:
	    		qualityString = "Poor";
	    		break;
	    	case Position.QUALITY_USABLE:
	    		qualityString = "Usable";
	    		break;
	    	case Position.QUALITY_GOOD:
	    		qualityString = "Good";
	    		// save Battery:
	    		//qualityString = "Finished";
	    		//Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
	    		break;
		}
		    viewQ.setText(qualityString);
		    Ui.requestUpdate();		
	}
	
	// Calculations for SWEREF 99 TM:
	function getSweref99tmCoordinates(newPosition)	
	{	
		var phi = newPosition[0]; //Lat
		var lambda = newPosition[1]; //Long
		var sweref = new [2];
				
	    // all parameters for GRS80 and SWEREF 99 TM
		var axis = 6378137.0; // GRS 1980
		var flattening = 1.0 / 298.257222101; // GRS 1980.
		var central_meridian = 15; // 15°E
		var lambda_0 = Math.toRadians(central_meridian);
		var scale = 0.9996;
		var false_northing = 0.0;
		var false_easting = 500000.0;
		
		// Prepare ellipsoid-based stuff.
		var e2 = flattening * (2.0 - flattening);
		var n = flattening / (2.0 - flattening);
		var a_roof = axis / (1.0 + n) * (1.0 + n*n/4.0 + n*n*n*n/64.0);
		var A = e2;
		var B = (5.0*e2*e2 - e2*e2*e2) / 6.0;
		var C = (104.0*e2*e2*e2 - 45.0*e2*e2*e2*e2) / 120.0;
		var D = (1237.0*e2*e2*e2*e2) / 1260.0;
		var beta1 = n/2.0 - 2.0*n*n/3.0 + 5.0*n*n*n/16.0 + 41.0*n*n*n*n/180.0;
		var beta2 = 13.0*n*n/48.0 - 3.0*n*n*n/5.0 + 557.0*n*n*n*n/1440.0;
		var beta3 = 61.0*n*n*n/240.0 - 103.0*n*n*n*n/140.0;
		var beta4 = 49561.0*n*n*n*n/161280.0;
	    
	    // convert
		var phi_star = phi-Math.sin(phi)*Math.cos(phi)*(A+B*Math.pow(Math.sin(phi),2)+C*Math.pow(Math.sin(phi),4)+D*Math.pow(Math.sin(phi),6));
		var delta_lambda = lambda - lambda_0;
		var xi_prim = Math.atan(Math.tan(phi_star) / Math.cos(delta_lambda));
		var eta_prim = atanh(Math.cos(phi_star) * Math.sin(delta_lambda));
		
		var N = scale * a_roof * (xi_prim + beta1 * Math.sin(2.0*xi_prim) * cosh(2.0*eta_prim) + beta2 * Math.sin(4.0*xi_prim) * cosh(4.0*eta_prim) + beta3 * Math.sin(6.0*xi_prim) * cosh(6.0*eta_prim) + beta4 * Math.sin(8.0*xi_prim) * cosh(8.0*eta_prim)) + false_northing;
		var E = scale * a_roof * (eta_prim + beta1 * Math.cos(2.0*xi_prim) * sinh(2.0*eta_prim) + beta2 * Math.cos(4.0*xi_prim) * sinh(4.0*eta_prim) + beta3 * Math.cos(6.0*xi_prim) * sinh(6.0*eta_prim) + beta4 * Math.cos(8.0*xi_prim) * sinh(8.0*eta_prim)) + false_easting;
		
		sweref[0] = Math.floor(N/10.0)*10.0;
		sweref[1] = Math.floor(E/10.0)*10.0;
		
		return sweref;
	}
	
	function sinh(x)
	{
		return 0.5*( Math.pow(Math.E, x) - Math.pow(Math.E, -x) );
	}
	
	function cosh(x)
	{
		return 0.5*( Math.pow(Math.E, x) + Math.pow(Math.E, -x) );
	}
	
	// no check if |x|<1
	function atanh(x)
	{
		return 0.5* Math.ln( (1+x)/(1-x) );
	}

}
