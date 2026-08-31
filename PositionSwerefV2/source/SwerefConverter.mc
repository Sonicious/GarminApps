import Toybox.Lang;
import Toybox.Math;

class SwerefConverter {

    function initialize() {
    }

    function convert(
        position as [Lang.Numeric, Lang.Numeric]
    ) as [Lang.Numeric, Lang.Numeric] {

        var phi = position[0];
        var lambda = position[1];

        var axis = 6378137.0d;
        var flattening = 1.0d / 298.257222101d;

        var centralMeridian = 15.0d;
        var lambda0 = Math.toRadians(centralMeridian);

        var scale = 0.9996d;
        var falseNorthing = 0.0d;
        var falseEasting = 500000.0d;

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

        var northing =
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

        var easting =
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

        var roundedNorthing =
            Math.round(northing / 10.0d) * 10;
        //System.println("North rounded: " + roundedNorthing);

        var roundedEasting =
            Math.round(easting / 10.0d) * 10;
        //System.println("East rounded: " + roundedEasting);

        return [
            roundedNorthing,
            roundedEasting
        ];
    }


    private function sinh(x as Lang.Numeric) as Double {

        return 0.5d *
            (
                Math.pow(Math.E, x) -
                Math.pow(Math.E, -x)
            );
    }


    private function cosh(x as Lang.Numeric) as Double {

        return 0.5d *
            (
                Math.pow(Math.E, x) +
                Math.pow(Math.E, -x)
            );
    }


    private function atanh(x as Lang.Numeric) as Double {

        return 0.5d *
            Math.ln(
                (1.0d + x) /
                (1.0d - x)
            );
    }
}