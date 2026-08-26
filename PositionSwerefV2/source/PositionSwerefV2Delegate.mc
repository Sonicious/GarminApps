import Toybox.Lang;
import Toybox.WatchUi;

class PositionSwerefV2Delegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new PositionSwerefV2MenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}