package game;

class Player {

    public static var souls:Float;
    public static var lastSouls:Float;
    public static var soulsInt(get, null):Int;
    public static var totalSouls:Float;
    
    public static var time:Float;

    public static var heroesKilled:Float;

    public static function init() {
        souls = Data.game.startingSouls;
        lastSouls = souls;
        totalSouls = Data.game.startingSouls;
        time = 0;
        heroesKilled = 0;
    }

    public static function get_soulsInt():Int {
        return Math.floor(souls);
    }

}