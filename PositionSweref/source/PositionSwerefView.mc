using Toybox.WatchUi as Ui;
using Toybox.Position;
using Toybox.Math;
using Toybox.Lang;

class PositionSwerefView extends Ui.View {

    /* 
     *Drawable IDs from the layout.
     */
	var _northCoordinate;
    var _eastCoordinate;
    var _qualityValue;

    function initialize() {
        View.initialize();

		_northCoordinate = null;
        _eastCoordinate = null;
        _qualityValue = null;
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));

		_northCoordinate = findDrawableById("NCoordinate");
        _eastCoordinate = findDrawableById("ECoordinate");
        _qualityValue = findDrawableById("QualityValue");
        
        // For Debugging: Abisko STF Hut!
        /*
		var tt = new [2];
		tt[0] = 68.358106;
		tt[1] = 18.783799;
        // 68.358106, 18.783799
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

    function onShow() {
		Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
    }

    function onHide() {
		Position.enableLocationEvents(
            Position.LOCATION_DISABLE,
            null 
        );
    }
    
	/*
     * Called whenever Garmin supplies a new position.
     */
    function onPosition(info as Position.Info) as Void {

		var qualityString = "";
        var northString = "--";
        var eastString = "--";

        var accuracy = info.accuracy;

		/*
         * Only calculate SWEREF when Garmin has supplied
         * an actual position with at least poor GPS quality.
         */
        if (
            info.position != null &&
            accuracy >= Position.QUALITY_POOR
        ) {
            var swerefCoordinates =
                getSweref99tmCoordinates(
                    info.position.toRadians()
                );

            northString =
                swerefCoordinates[0]
                .toNumber()
                .toString();

            eastString =
                swerefCoordinates[1]
                .toNumber()
                .toString();
        }
	    
		/*
         * Translate Garmin's GPS quality into a short
         * user-readable status.
         */
        switch (accuracy) {
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
                break;
            default:
                qualityString = "Searching ...";
                break;
        }
		
		/*
         * Update the labels.
         */
        if (_northCoordinate != null) {
            _northCoordinate.setText(northString);
        }

        if (_eastCoordinate != null) {
            _eastCoordinate.setText(eastString);
        }

        if (_qualityValue != null) {
            _qualityValue.setText(qualityString);
        }
		
		/*
         * Request a screen redraw.
         */
        Ui.requestUpdate();
	}
	
	/*
     * Convert latitude / longitude to SWEREF 99 TM.
     *
     * Input:
     *   newPosition[0] = latitude in radians
     *   newPosition[1] = longitude in radians
     *
     * Output:
     *   [Northing, Easting]
     *
     * Both values are rounded to the nearest 10 metres.
     */
    function getSweref99tmCoordinates(
        newPosition as [Lang.Numeric, Lang.Numeric]
        ) as [Lang.Numeric, Lang.Numeric] {

        var phi = newPosition[0];
        var lambda = newPosition[1];

        /*
         * GRS 1980 / SWEREF 99 TM parameters.
         */
        var axis = 6378137.0d;
        var flattening = 1.0d / 298.257222101d;

        var centralMeridian = 15.0d;
        var lambda0 = Math.toRadians(centralMeridian);

        var scale = 0.9996d;
        var falseNorthing = 0.0d;
        var falseEasting = 500000.0d;


        /*
         * Prepare ellipsoid parameters.
         */
        var e2 =
            flattening *
            (2.0d - flattening);

        var n =
            flattening /
            (2.0d - flattening);

        var n2 = n * n;
        var n3 = n2 * n;
        var n4 = n2 * n2;

        var e4 = e2 * e2;
        var e6 = e4 * e2;
        var e8 = e4 * e4;


        var aRoof =
            axis /
            (1.0d + n) *
            (
                1.0d +
                n2 / 4.0d +
                n4 / 64.0d
            );


        var A = e2;

        var B =
            (5.0d * e4 - e6) /
            6.0d;

        var C =
            (104.0d * e6 - 45.0d * e8) /
            120.0d;

        var D =
            (1237.0d * e8) /
            1260.0d;


        var beta1 =
            n / 2.0d -
            2.0d * n2 / 3.0d +
            5.0d * n3 / 16.0d +
            41.0d * n4 / 180.0d;

        var beta2 =
            13.0d * n2 / 48.0d -
            3.0d * n3 / 5.0d +
            557.0d * n4 / 1440.0d;

        var beta3 =
            61.0d * n3 / 240.0d -
            103.0d * n4 / 140.0d;

        var beta4 =
            49561.0d * n4 /
            161280.0d;


        /*
         * Convert geographic position.
         */
        var sinPhi = Math.sin(phi);

        var phiStar =
            phi -
            sinPhi *
            Math.cos(phi) *
            (
                A +
                B * Math.pow(sinPhi, 2) +
                C * Math.pow(sinPhi, 4) +
                D * Math.pow(sinPhi, 6)
            );


        var deltaLambda =
            lambda - lambda0;


        var xiPrim =
            Math.atan(
                Math.tan(phiStar) /
                Math.cos(deltaLambda)
            );


        var etaPrim =
            atanh(
                Math.cos(phiStar) *
                Math.sin(deltaLambda)
            );


        /*
         * Calculate Northing.
         */
        var N =
            scale *
            aRoof *
            (
                xiPrim +

                beta1 *
                Math.sin(2.0d * xiPrim) *
                cosh(2.0d * etaPrim) +

                beta2 *
                Math.sin(4.0d * xiPrim) *
                cosh(4.0d * etaPrim) +

                beta3 *
                Math.sin(6.0d * xiPrim) *
                cosh(6.0d * etaPrim) +

                beta4 *
                Math.sin(8.0d * xiPrim) *
                cosh(8.0d * etaPrim)
            ) +
            falseNorthing;


        /*
         * Calculate Easting.
         */
        var E =
            scale *
            aRoof *
            (
                etaPrim +

                beta1 *
                Math.cos(2.0d * xiPrim) *
                sinh(2.0d * etaPrim) +

                beta2 *
                Math.cos(4.0d * xiPrim) *
                sinh(4.0d * etaPrim) +

                beta3 *
                Math.cos(6.0d * xiPrim) *
                sinh(6.0d * etaPrim) +

                beta4 *
                Math.cos(8.0d * xiPrim) *
                sinh(8.0d * etaPrim)
            ) +
            falseEasting;


        /*
         * The exact metre value is not important for this widget.
         * Display coordinates rounded to the nearest 10 metres.
         */
        N = Math.round(N / 10.0d) * 10;
        E = Math.round(E / 10.0d) * 10;


        return [ N, E ] as [Lang.Numeric, Lang.Numeric];
    }


    /*
     * Hyperbolic sine.
     */
    function sinh(x) {
        return 0.5d *
            (
                Math.pow(Math.E, x) -
                Math.pow(Math.E, -x)
            );
    }


    /*
     * Hyperbolic cosine.
     */
    function cosh(x) {
        return 0.5d *
            (
                Math.pow(Math.E, x) +
                Math.pow(Math.E, -x)
            );
    }


    /*
     * Inverse hyperbolic tangent.
     *
     * No range check is needed here because etaPrim is
     * calculated from valid geographic coordinates.
     */
    function atanh(x) {
        return 0.5d *
            Math.ln(
                (1.0d + x) /
                (1.0d - x)
            );
    }

}
