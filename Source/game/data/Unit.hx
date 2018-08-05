package game.data;

import kha.math.Vector2i;
import kext.g2basics.BasicSprite;

enum UnitType {
    HERO;
    MONSTER;
}

@:structInit
class UnitData {
	public var name:String = "UnitBase";
    public var spriteName:String = "UnitSprite";
	public var health:Float = 0;
    public var maxHealth:Float = 0;
    public var damage:Float = 0;
    public var defense:Float = 0;
    public var speed:Float = 0;
    public var respawnTime:Float = 0;
    
    public var healthMaxMultiplier:Int = 10;
    public var damageMaxMultiplier:Int = 10;
    public var defenseMaxMultiplier:Int = 10;
    public var speedMaxMultiplier:Int = 10;
}

class Unit {
	public var name:String = "UnitBase";
    public var spriteName:String = "UnitSprite";
	public var health:Float = 0;
    public var maxHealth:Float = 0;
    private var _damage:Float = 0;
    public var damage(get, null):Float;
    private var _defense:Float = 0;
    public var defense(get, null):Float;
    private var _speed:Float = 0;
    public var speed(get, null):Float;
    private var _respawnTime:Float;
    public var respawnTime(get, null):Float;
    public var canRespawn(get, null):Bool;

    public var sprite:BasicSprite = null;

    public var type:UnitType = null;

    public var attackTime:Float = 0;
    public var deadTime:Float = 0;

    public var dead(get, null):Bool;

    private var _position:Vector2i;
    public var position(get, set):Vector2i;
    public var target(default, set):Unit;
    public var map:TileData;

    public var healthMultiplier:Float = 1;
    public var damageMultiplier:Float = 1;
    public var defenseMultiplier:Float = 1;
    public var speedMultiplier:Float = 1;

    public var healthMaxMultiplier:Int = 10;
    public var damageMaxMultiplier:Int = 10;
    public var defenseMaxMultiplier:Int = 10;
    public var speedMaxMultiplier:Int = 10;

    public function new(unitData:UnitData) {
        name = unitData.name;
        spriteName = unitData.spriteName;
        health = unitData.maxHealth;
        maxHealth = unitData.maxHealth;
        _damage = unitData.damage;
        _defense = unitData.defense;
        _speed = unitData.speed;
        _respawnTime = unitData.respawnTime == null ? -1 : unitData.respawnTime;

        healthMaxMultiplier = unitData.healthMaxMultiplier;
        damageMaxMultiplier = unitData.damageMaxMultiplier;
        defenseMaxMultiplier = unitData.defenseMaxMultiplier;
        speedMaxMultiplier = unitData.speedMaxMultiplier;

        attackTime = 0;
        deadTime = 0;

        _position = new Vector2i(0, 0);
        target = null;
    }

	public function init(map:TileData, type:UnitType) {
        this.map = map;
        this.type = type;
	}

    public function update(delta:Float) {
        if(dead) {
            deadTime = Math.min(deadTime + delta, respawnTime);
            if(canRespawn && deadTime >= respawnTime) {
                deadTime = 0;
                health = maxHealth;
                map.tileUnits[_position.y * map.width + _position.x] = this;
            }
        } else {
            if(target != null) {
                attackTime += delta * speed;
            }
        }
    }

    public function tryAttack() {
        if(target != null && attackTime > 1) {
            target.hit(damage);
            attackTime = 0;
            if(target.dead) {
                target = null;
            }
        }
    }

    public function hit(damage:Float) {
        health -= damage;
        if(dead) {
            target = null;
            attackTime = 0;
            if(respawnTime < 0) {
                map.tileUnits[position.y * map.width + position.x] = null;
            }
        }
    }

    public function getRespawnAlpha():Float {
        return (deadTime / respawnTime * 0.8) + 0.2;
    }

    public function getHealthPercentage():Float {
        return health / maxHealth;
    }

    public function get_dead():Bool {
        return health <= 0;
    }

    public function get_position():Vector2i {
        return _position;
    }

    public function set_position(vec:Vector2i):Vector2i {
        map.tileUnits[_position.y * map.width + _position.x] = null;
        _position = vec;
        map.tileUnits[_position.y * map.width + _position.x] = this;
        return _position;
    }

    public function set_target(unit:Unit):Unit {
        target = unit;
        return target;
    }

    public function get_damage():Float { return _damage * damageMultiplier; }
    public function get_defense():Float { return _defense * defenseMultiplier; }
    public function get_speed():Float { return _speed * speedMultiplier; }
    public function get_respawnTime():Float { return _respawnTime / healthMultiplier; }

    public function get_canRespawn():Bool { return _respawnTime != -1; }
}