package game.data;

import kha.Assets;
import kha.Image;
import kha.math.Vector2;
import kha.math.Vector2i;
import kext.Application;
import kext.Basic;
import kext.g2basics.BasicSprite;
import kext.g2basics.AnimatedSprite;

class Monster extends Basic {
    public var unit:Unit;

    public var initialPosition:Vector2i;

    public function new(x:Int, y:Int, unitData:UnitData, map:GameMap) {
        super();

        unit = new Unit(x, y, unitData, map, UnitType.MONSTER);
        unit.onEvolve = onUnitEvolve;
        unit.onDeath = onUnitDeath;

        map.tileUnits[x + y * map.width] = unit;
        initialPosition = new Vector2i(x, y);
    }

    private function onUnitEvolve() {
        Application.audio.playSound(Assets.sounds.Evolve, 0.4);
    }

    private function onUnitDeath() {
        Application.audio.playSound(Assets.sounds.Monster_Dead, 0.6);
        unit.map.tileUnits[initialPosition.x + initialPosition.y * unit.map.width] = null;
        unit.map.monsters.remove(unit);
        unit.currentLane.removeMonster(unit);
    }

    override public function update(delta:Float) {
        unit.update(delta);

        if(!unit.dead) {
            if((unit.data.projectileSpeed == 0 || unit.data.projectileSpeed == null) && unit.target == null) {
                unit.tryGetTarget();
            } else {
                unit.tryAttack();
            }
        }
    }

    override public function render(backbuffer:Image) {
        if(!unit.dead) {
            unit.render(backbuffer);
        }
    }

}