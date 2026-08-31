import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

(:glance)
class PositionSwerefV2GlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_TRANSPARENT
        );

        dc.clear();

        var north = Application.Storage.getValue("lastNorth");
        var east = Application.Storage.getValue("lastEast");
        var timestamp = Application.Storage.getValue("lastTimestamp");

        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var xLabel = 5;

        var yOffset = (WatchUi.loadResource(Rez.Strings.GlanceYOffset) as Lang.String).toNumber();

        var yNorth = height * 0.15 + yOffset;
        var yEast  = height * 0.45 + yOffset;
        var yAge   = height * 0.72 + yOffset;

        var justifyLeft =
            Graphics.TEXT_JUSTIFY_LEFT |
            Graphics.TEXT_JUSTIFY_VCENTER;

        var justifyCenter =
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER;        

        if (
            north == null ||
            east == null ||
            timestamp == null
        ) {
            dc.drawText(
                width / 2,
                height / 2,
                Graphics.FONT_GLANCE,
                WatchUi.loadResource(Rez.Strings.NoPosition) as Lang.String,
                justifyCenter
            );

            return;
        }

        var now = Time.now().value();
        var minutes = (now - timestamp) / 60;

        if (minutes > 50) {
            dc.drawText(
                width / 2,
                height / 2,
                Graphics.FONT_GLANCE,
                WatchUi.loadResource(Rez.Strings.NoPosition) as Lang.String,
                justifyCenter
            );

            return;
        }

        var minutesText = Lang.format(
            WatchUi.loadResource(Rez.Strings.MinutesAgo) as Lang.String,
            [minutes.toNumber()]
        );

        dc.drawText(
            xLabel,
            yNorth,
            Graphics.FONT_GLANCE,
            "N " + north,
            justifyLeft
        );

        dc.drawText(
            xLabel,
            yEast,
            Graphics.FONT_GLANCE,
            "E    " + east,
            justifyLeft
        );
        
        dc.drawText(
            xLabel,
            yAge,
            Graphics.FONT_GLANCE,
            minutesText,
            justifyLeft
        );
    }
}