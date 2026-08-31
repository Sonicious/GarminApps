import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PositionSwerefV2App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new PositionSwerefV2View(), new PositionSwerefV2Delegate() ];
    }

}

function getApp() as PositionSwerefV2App {
    return Application.getApp() as PositionSwerefV2App;
}