package game.data;

class UnitManager {

    public static var defaultUnit:UnitData;

    public static var monsters:Map<String, UnitData> = new Map<String, UnitData>();
    public static var heroes:Map<String, UnitData> = new Map<String, UnitData>();
    public static var heroByLevel:Map<Int, Array<UnitData>> = new Map<Int, Array<UnitData>>();

    public static function defaultUnitData(unitsToDefault:Array<UnitData>) {
        // for(unit in unitsToDefault) {
        //     defaultData(unit);
        // }
    }

    public static function defaultData() {

    }

    public static function addMonsters(monsterToAdd:Array<UnitData>) {
        for(unit in monsterToAdd) {
            monsters.set(unit.name, unit);
        }
    }

    public static function addHeroes(heroesToAdd:Array<UnitData>) {
        for(unit in heroesToAdd) {
            heroes.set(unit.name, unit);
            var heroes:Array<UnitData>;
            if(heroByLevel.exists(unit.level)) {
                heroes = heroByLevel.get(unit.level);
            } else {
                heroes = new Array<UnitData>();
                heroByLevel.set(unit.level, heroes);
            }
            heroes.push(unit);
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