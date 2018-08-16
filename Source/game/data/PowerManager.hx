package game.data;

class PowerManager {

    public static var powers:Map<String, PowerData> = new Map<String, PowerData>();

    public static function addPowers(powersToAdd:Array<PowerData>) {
        for(power in powersToAdd) {
            powers.set(power.name, power);
        }
    }

    public static function createByName(name:String, unit:Unit) {
        return new Power(powers.get(name), unit);
    }

}