package game.data;

import game.data.Unit.UnitData;
import game.data.Unit.EvolutionData;

class UnitManager {

    public static var monsters:Map<String,UnitData> = new Map<String, UnitData>();

    public static function addMonsters(monsterToAdd:Array<UnitData>) {
        for(unit in monsterToAdd) {
            monsters.set(unit.name, unit);
        }
    }

    public static function tryEvolveMonster(unit:Unit) {
        for(evolutionData in unit.data.evolutions) {
            if(tryEvolution(unit, evolutionData)) {
                return;
            }
        }
    }

    private static function tryEvolution(unit:Unit, evolutionData:EvolutionData):Bool {
        if( unit.healthLevel >= evolutionData.healthLevel &&
            unit.damageLevel >= evolutionData.damageLevel &&
            unit.defenseLevel >= evolutionData.defenseLevel &&
            unit.speedLevel >= evolutionData.speedLevel &&
            monsters.exists(evolutionData.name)) {
                unit.evolve(monsters.get(evolutionData.name));
                return true;
        }
        return false;
    }

}