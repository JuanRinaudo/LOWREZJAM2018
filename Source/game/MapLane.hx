package game;

import game.data.UnitData;
import game.data.UnitType;

class MapLane {

    public var monsterGroup:Array<Unit>;
    public var heroGroup:Array<Unit>;

    public var projectileGroup:Array<Projectile>;

    public function new() {
        monsterGroup = [];
        heroGroup = [];
        projectileGroup = [];
    }

    public function addMonster(unit:Unit) {
        monsterGroup.push(unit);
    }
    public function removeMonster(unit:Unit) {
        monsterGroup.remove(unit);
    }

    public function addHero(unit:Unit) {
        heroGroup.push(unit);
    }
    public function removeHero(unit:Unit) {
        heroGroup.remove(unit);
    }

    public function tryGetTarget(unit:Unit) {
        var targetGroup:Array<Unit> = unit.type == UnitType.MONSTER ? heroGroup : monsterGroup;
        var targetDistance:Float = Math.POSITIVE_INFINITY;
        var target:Unit = null;
        for(enemy in targetGroup) {
            var calculatedDistance = unit.x - enemy.x;
            var absoluteDistance = Math.abs(calculatedDistance) - unit.data.hitRadius;
            if(((unit.type == UnitType.MONSTER && calculatedDistance > 0) || (unit.type == UnitType.HERO && calculatedDistance < 0)) &&
                absoluteDistance < unit.range && absoluteDistance < targetDistance) {
                target = enemy;
                targetDistance = absoluteDistance;
            }
        }
        return target;
    }

    public function hasEnemy(unit:Unit) {
        return unit.type == UnitType.MONSTER ? hasHeroInLane() : hasMonsterInLane();
    }

    public function hasHeroInLane() {
        return heroGroup.length > 0;
    }
    
    public function hasMonsterInLane() {
        return monsterGroup.length > 0;
    }

    public function addProjectile(projectile:Projectile) {
        projectileGroup.push(projectile);
    }
    public function removeProjectile(projectile:Projectile) {
        projectileGroup.remove(projectile);
    }

}