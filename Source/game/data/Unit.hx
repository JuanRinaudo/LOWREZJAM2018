package game.data;

import kha.math.Vector2i;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;

enum UnitType {
    HERO;
    MONSTER;
}

@:structInit
class EvolutionData {
	public var name:String = "UnitBase";
    public var healthLevel:Int = 0;
    public var damageLevel:Int = 0;
    public var defenseLevel:Int = 0;
    public var speedLevel:Int = 0;
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
    
    public var healthMaxLevel:Int = 10;
    public var damageMaxLevel:Int = 10;
    public var defenseMaxLevel:Int = 10;
    public var speedMaxLevel:Int = 10;

    public var evolutions:Array<EvolutionData>;
}

class Unit {
	public var health:Float = 0;
    public var maxHealth(get, null):Float;
    public var damage(get, null):Float;
    public var defense(get, null):Float;
    public var speed(get, null):Float;
    private var _respawnTime:Float;
    public var respawnTime(get, null):Float;
    public var canRespawn(get, null):Bool;

    public var data:UnitData;

    public var sprite:BasicSprite = null;

    public var type:UnitType = null;

    public var attackTime:Float = 0;
    public var deadTime:Float = 0;

    public var dead(get, null):Bool;

    private var _position:Vector2i;
    public var position(get, set):Vector2i;
    public var target(default, set):Unit;
    public var map:TileData;

    public var healthLevel(default, set):Int = 0;
    public var damageLevel:Int = 0;
    public var defenseLevel:Int = 0;
    public var speedLevel:Int = 0;

    public var onEvolve:(Void -> Void);

    public function new(unitData:UnitData) {
        data = unitData;

        health = maxHealth;
        _respawnTime = unitData.respawnTime == null ? -1 : unitData.respawnTime;

        attackTime = 0;
        deadTime = 0;

        _position = new Vector2i(0, 0);
        target = null;
    }

    public function createSprite() {
        var x:Float = 0;
        var y:Float = 0;
        if(sprite != null) {
            x = sprite.transform.x;
            y = sprite.transform.y;
        }
        sprite = BasicSprite.fromFrame(x, y, ExtAssets.frames.get(data.spriteName));
        sprite.transform.originY -= (map.tileHeight - sprite.box.y * 0.5);
    }

    public function evolve(evolution:UnitData) {
        data = evolution;
        healthLevel = 0;
        damageLevel = 0;
        defenseLevel = 0;
        speedLevel = 0;
        health = maxHealth;
        onEvolve();
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
                health = data.maxHealth;
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

    public function hit(incomingDamage:Float) {
        health -= Math.max(incomingDamage - defense, 0);
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
        return Math.max(health / maxHealth, 0);
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

    public function get_maxHealth():Float { return data.maxHealth * (healthLevel * 0.1 + 1); }
    public function get_damage():Float { return data.damage * (damageLevel * 0.1 + 1); }
    public function get_defense():Float { return data.defense * (defenseLevel * 0.1 + 1); }
    public function get_speed():Float { return data.speed * (speedLevel * 0.1 + 1); }
    public function get_respawnTime():Float { return _respawnTime / (healthLevel * 0.1 + 1); }

    public function get_canRespawn():Bool { return _respawnTime != -1; }

    public function set_healthLevel(value:Int):Int {
        var percentage = health / maxHealth;
        healthLevel = value;
        health = maxHealth * percentage;
        return value;
    }
}