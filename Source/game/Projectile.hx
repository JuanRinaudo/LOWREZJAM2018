package game;

import kha.Image;
import kext.Basic;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;

import game.data.UnitType;
import game.states.GameState;

class Projectile extends Basic {

    public var type:UnitType;
    public var onwerUnit:Unit;

    public var sprite:BasicSprite;

    public function new(x:Float, y:Float, onwerUnit:Unit) {
        super();

        this.onwerUnit = onwerUnit;

        tryCreateSprite(x, y);
        GameState.mainCamera.add(this);
    }

    public function tryCreateSprite(x:Float, y:Float) {
        if(onwerUnit.data.projectileName != null) {
            sprite = BasicSprite.fromFrame(x, y, ExtAssets.frames.get(onwerUnit.data.projectileName));
            sprite.transform.originX = sprite.box.x * 0.5;
            sprite.transform.originY = sprite.box.y * 0.5;
        }
    }

    override public function update(delta:Float) {
        sprite.transform.x -= delta * onwerUnit.data.projectileSpeed;
        if(sprite.transform.x < -onwerUnit.map.bounds.x) {
            destroyProjectile();
        } else {
            checkHit();
        }
    }

    private function checkHit() {
        var lane:MapLane = onwerUnit.currentLane;
        var group:Array<Unit> = onwerUnit.type == UnitType.MONSTER ? lane.heroGroup : lane.monsterGroup;
        for(unit in group) {
            if(Math.abs(unit.x - sprite.transform.x) < unit.data.hitRadius) {
                if(onwerUnit != null) {
                    unit.hit(onwerUnit.damage);
                    destroyProjectile();
                }
            }
        }
    }

    private function destroyProjectile() {
        GameState.mainCamera.remove(this);
        onwerUnit = null;
    }

    override public function render(backbuffer:Image) {
        sprite.render(backbuffer);
    }

}