package game.data;

import kha.Assets;
import kha.Image;
import kha.math.Vector2;
import kha.math.Vector2i;
import kext.Application;
import kext.Basic;
import kext.g2basics.BasicSprite;

class Hero extends Basic {
    public var unit:Unit;

    public var tileQueue:Array<Vector2i>;
    public var tileTrail:Array<Vector2i>;

    public var outOfWorld:Bool;

    private var lastDirection:Direction;

    public function new(x:Int, y:Int, unitData:UnitData, map:GameMap) {
        super();

        outOfWorld = false;

        unit = new Unit(x, y, unitData, map, UnitType.HERO);
        unit.onDeath = onUnitDeath;
    }

    private function onUnitDeath() {
        if(!outOfWorld) {
            Application.audio.playSound(Assets.sounds.Hero_Dead, 0.6);
        }
        Player.heroesKilled++;
        Player.souls += Data.game.soulsOnHeroKill;
        unit.map.heroes.remove(unit);
        unit.currentLane.removeHero(unit);
    }

    override public function update(delta:Float) {
        unit.update(delta);

        if(!unit.dead) {
            if(unit.target == null) {
                unit.tryGetTarget();
                moveUnit(delta);
            } else {
                unit.tryAttack();
            }
        }
    }

    private function moveUnit(delta:Float) {
        unit.x += unit.movementSpeed * delta;
        if(unit.x > unit.map.bounds.x) {
            outOfWorld = true;
            unit.kill();
        }
    }

    override public function render(backbuffer:Image) {
        if(!unit.dead) {
            unit.render(backbuffer);
        }
    }

}