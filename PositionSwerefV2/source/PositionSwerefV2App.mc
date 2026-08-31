import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class PositionSwerefV2App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [
            new PositionSwerefV2View(),
            new PositionSwerefV2Delegate()
        ];
    }

    function getGlanceTheme() as AppBase.GlanceTheme {
        return AppBase.GLANCE_THEME_BLUE;
    }

    function getGlanceView()
        as [ WatchUi.GlanceView ]
        or [ WatchUi.GlanceView, WatchUi.GlanceViewDelegate ]
        or Null {

        return [
            new PositionSwerefV2GlanceView()
        ];
    }
}

function getApp() as PositionSwerefV2App {
    return Application.getApp() as PositionSwerefV2App;
}