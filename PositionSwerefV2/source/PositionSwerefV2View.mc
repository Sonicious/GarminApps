import Toybox.Graphics;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class PositionSwerefV2View extends WatchUi.View {

    private var _swerefConverter as SwerefConverter;

    private var _northCoordinate;
    private var _eastCoordinate;
    private var _qualityValue;

    function initialize() {
        View.initialize();

        _swerefConverter = new SwerefConverter();

        _northCoordinate = null;
        _eastCoordinate = null;
        _qualityValue = null;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        _northCoordinate = findDrawableById("NCoordinate");
        _eastCoordinate = findDrawableById("ECoordinate");
        _qualityValue = findDrawableById("QualityValue");
    }

    function onShow() as Void {
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
    }

    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function onHide() as Void {
        Position.enableLocationEvents(
            Position.LOCATION_DISABLE,
            null
        );
    }

    function onPosition(info as Position.Info) as Void {
        var qualityString = "Searching ...";
        var northString = "-------";
        var eastString = "------";

        var accuracy = info.accuracy;

        if (
            info.position != null &&
            accuracy >= Position.QUALITY_POOR
        ) {
            var swerefCoordinates =
                _swerefConverter.convert(
                    info.position.toRadians()
                );

            northString =
                swerefCoordinates[0].toNumber().toString();

            eastString =
                swerefCoordinates[1].toNumber().toString();
        }

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

        if (_northCoordinate != null) {
            _northCoordinate.setText(northString);
        }

        if (_eastCoordinate != null) {
            _eastCoordinate.setText(eastString);
        }

        if (_qualityValue != null) {
            _qualityValue.setText(qualityString);
        }

        WatchUi.requestUpdate();
    }

}
