package game.data;

import kext.g2basics.BasicSprite;

@:structInit
class Unit {
	public var name:String = "UnitBase";
    public var spriteName:String = "UnitSprite";
	public var health:Float = 0;
    public var maxHealth:Float = 0;
    public var damage:Float = 0;
    public var defense:Float = 0;
    public var speed:Float = 0;

    public var sprite:BasicSprite = null;

    @:optional public var healthMultiplier:Float = 1;
    @:optional public var damageMultiplier:Float = 1;
    @:optional public var defenseMultiplier:Float = 1;
    @:optional public var speedMultiplier:Float = 1;

	public function new() {

	}
}