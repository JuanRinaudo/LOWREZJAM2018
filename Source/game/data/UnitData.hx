package game.data;

import kha.math.Vector2;

class UnitData {
	public var name:String;
    public var spriteName:String;
    public var animationName:String;
    public var projectileName:String;
    public var level:Int;
    public var hitRadius:Float;
	public var health:Float;
    public var maxHealth:Float;
    public var damage:Float;
    public var defense:Float;
    public var speed:Float;
    public var range:Float;
    public var projectileSpeed:Float;
    public var projectileOffset:Vector2;

    public var createCost:Int;
    public var upgradeCost:Int;
    
    public var healthMaxLevel:Int;
    public var damageMaxLevel:Int;
    public var defenseMaxLevel:Int;
    public var speedMaxLevel:Int;

    public var important:Bool;

    public var evolutions:Array<EvolutionData>;
    public var powerNames:Array<String>;

    public var movementSpeed:Float;
}