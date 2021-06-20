package game;

import kha.Color;
import kha.Image;
import kha.math.Vector2;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import kext.g2basics.AnimatedSprite;

import game.data.UnitData;
import game.data.UnitType;
import game.data.UnitCondition;

import game.managers.PowerManager;

class Unit {
	public var health:Float;
    public var maxHealth(get, null):Float;
    public var damage(get, null):Float;
    public var defense(get, null):Float;
    public var speed(get, null):Float;
    public var range(get, null):Float;
    public var movementSpeed(get, null):Float;

    public var canUpgrade(get, null):Bool;

    public var currentLane:MapLane;

    public var x(default, set):Float;
    public var y(default, set):Float;

    public var data:UnitData;

    public var sprite:BasicSprite = null;
    public var animatedSprite:AnimatedSprite = null;

    public var powers:Array<Power>;

    public var type:UnitType = null;
    public var important:Bool = false;

    public var attackTime:Float;
    public var deadTime:Float;

    public var dead(get, null):Bool;

    public var target(default, set):Unit;
    public var map:GameMap;

    public var healthLevel(default, set):Int;
    public var damageLevel:Int;
    public var defenseLevel:Int;
    public var speedLevel:Int;
    public var tempHealth:Int;
    public var tempDamage:Int;
    public var tempDefense:Int;
    public var tempSpeed:Int;

    public var unitColor:Color;
    public var hitRedTimer:Float;

    public var conditions:Array<UnitCondition>;

    public var onEvolve:(Void -> Void);
    public var onDeath:(Void -> Void);

    public function new(x:Int, y:Int, unitData:UnitData, map:GameMap, type:UnitType) {
        data = unitData;
        this.map = map;
        this.type = type;

        healthLevel = 0;
        damageLevel = 0;
        defenseLevel = 0;
        speedLevel = 0;

        tempHealth = 0;
        tempDamage = 0;
        tempDefense = 0;
        tempSpeed = 0;

        health = maxHealth;

        unitColor = Color.White;

        important = unitData.important != null ? unitData.important : false;

        attackTime = 0;
        deadTime = 0;

        target = null;
        
        conditions = [];

        tryCreateSprite();
        tryCreateAnimatedSprite();
        tryCreatePowers();

        setTilePosition(x, y);

        currentLane = map.lanes[y];
        if(type == UnitType.MONSTER) {
            currentLane.addMonster(this);
        } else {
            currentLane.addHero(this);
        }
    }

    private function setupUnit() {
        tryCreateSprite();
        tryCreateAnimatedSprite();
        tryCreatePowers();
    }

    public function tryCreateSprite() {
        if(data.spriteName != null) {
            sprite = BasicSprite.fromFrame(0, 0, ExtAssets.frames.get(data.spriteName));
            sprite.transform.originX = 12;
            sprite.transform.originY = 8;
        }
    }

    public function tryCreateAnimatedSprite() {
        if(data.animationName != null) {
            animatedSprite = AnimatedSprite.fromAnimationName(0, 0, data.animationName);
            animatedSprite.play(Math.floor(Math.random() * animatedSprite.currentAnimation.frames.length));
            animatedSprite.transform.originX = 12;
            animatedSprite.transform.originY = 8;
        }
    }

    public function tryCreatePowers() {
        powers = [];
        if(data.powerNames != null) {
            for(name in data.powerNames) {
                powers.push(PowerManager.createByName(name, this));
            }
        }
    }

    public function setTilePosition(tx:Float, ty:Float) {
        x = tx * map.tileWidth + map.tileWidth * 0.5;
        y = ty * map.tileHeight;
    }

    private function moveUnit(delta:Float) {
        if(sprite != null) {
            sprite.transform.x = sprite.transform.x + delta;
        }
        if(animatedSprite != null) {
            animatedSprite.transform.x = animatedSprite.transform.x + delta;
        }
    }

    public function evolve(evolution:UnitData) {
        data = evolution;
        healthLevel = 0;
        damageLevel = 0;
        defenseLevel = 0;
        speedLevel = 0;
        health = maxHealth;
        sprite = null;
        animatedSprite = null;
        setupUnit();
        set_x(x);
        set_y(y);
        conditions = [];
        if(onEvolve != null) { onEvolve(); }
    }

    public function update(delta:Float) {
        hitRedTimer = Math.max(hitRedTimer - delta, 0);
        unitColor.R = 1;
        unitColor.G = 1 - hitRedTimer * Data.game.hitRedTint;
        unitColor.B = 1 - hitRedTimer * Data.game.hitRedTint;

        checkConditions(delta);

        if(dead) {

        } else {
            for(power in powers) {
                power.update(delta);
            }

            if(animatedSprite != null) { animatedSprite.update(delta); }

            attackTime = Math.min(attackTime + delta * speed, 1);
        }
    }

    private function checkConditions(delta:Float) {
        for(condition in conditions) {
            condition.duration -= delta;
            if(condition.duration <= 0) {
                conditions.remove(condition);
                changeTempStat(condition.stat, -condition.value, 0);
            }
        }
    }

    public function tryGetTarget() {
        target = currentLane.tryGetTarget(this);
    }

    public function tryAttack() {
        if(attackTime >= 1) {
            if(data.projectileSpeed > 0 && currentLane.hasEnemy(this)) { //Projectile Unit
                currentLane.addProjectile(new Projectile(x + data.projectileOffset.x, y + data.projectileOffset.y, this));
                attackTime = 0;
            } else { //Instant attack unit
                if(target != null) {
                    target.hit(damage);
                    attackTime = 0;
                    if(target.dead) {
                        target = null;
                    }
                }
            }
        }
    }

    public function hit(incomingDamage:Float) {
        var hitDamage:Float = Math.max(incomingDamage - defense, 0);
        if(hitDamage > 0) {
            health -= hitDamage;
            hitRedTimer = Data.game.hitRedTime;
            if(dead) {
                target = null;
                attackTime = 0;
                if(onDeath != null) { onDeath(); }
            }
        }
    }

    public function heal(healValue:Float) {
        health = Math.min(health + healValue, maxHealth);
    }

    public function kill() {
        hit(maxHealth * 2);
    }

    public function getHealthPercentage():Float {
        return Math.max(health / maxHealth, 0);
    }

    public function render(backbuffer:Image) {
        if(sprite != null) {
            sprite.color = unitColor;
            sprite.render(backbuffer);
        }
        if(animatedSprite != null) {
            animatedSprite.color = unitColor;
            animatedSprite.render(backbuffer);
        }

        if(sprite != null) {
            backbuffer.g2.pushTransformation(backbuffer.g2.transformation.multmat(sprite.transform.getMatrix()));
        } else {
            backbuffer.g2.pushTransformation(backbuffer.g2.transformation.multmat(animatedSprite.transform.getMatrix()));
        }
        backbuffer.g2.color = kha.Color.Red;
        backbuffer.g2.fillRect(6, 25, Math.max((map.tileWidth - 4) * getHealthPercentage(), 1), 1);
        backbuffer.g2.popTransformation();
    }

    public function get_dead():Bool {
        return health <= 0;
    }

    public function set_target(unit:Unit):Unit {
        target = unit;
        return target;
    }
    
    public function changeTempStat(stat:String, value:Int, duration:Float) {
        if(stat == "health") {
            tempHealth += value;
        } else if(stat == "defense") {
            tempDefense += value;
        } else if(stat == "damage") {
            tempDamage += value;
        } else if(stat == "speed") {
            tempSpeed += value;
        }
        if(duration > 0) {
            conditions.push({stat: stat, value: value, duration: duration});
        }
    }

    public function get_maxHealth():Float { return data.maxHealth * ((healthLevel + tempHealth) * Data.game.statMultiplier + 1); }
    public function get_damage():Float { return data.damage * ((damageLevel + tempDamage) * Data.game.statMultiplier + 1); }
    public function get_defense():Float { return data.defense * ((defenseLevel + tempDefense) * Data.game.statMultiplier + 1); }
    public function get_speed():Float { return data.speed * ((speedLevel + tempSpeed) * Data.game.statMultiplier + 1); }
    public function get_movementSpeed():Float { return data.movementSpeed * speed; }
    public function get_range():Float { return data.range; }

    public function get_canUpgrade():Bool { return Player.souls >= data.upgradeCost; }

    public function set_x(value:Float):Float {
        if(sprite != null) { sprite.transform.x = value; }
        if(animatedSprite != null) { animatedSprite.transform.x = value; }
        return x = value;
    }
    public function set_y(value:Float):Float {
        if(sprite != null) { sprite.transform.y = value; }
        if(animatedSprite != null) { animatedSprite.transform.y = value; }
        return y = value;
    }

    public function set_healthLevel(value:Int):Int {
        var percentage = health / maxHealth;
        healthLevel = value;
        health = maxHealth * percentage;
        return value;
    }
}