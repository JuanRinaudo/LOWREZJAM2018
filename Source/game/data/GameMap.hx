package game.data;

import kha.math.Vector2;
import game.states.GameState;

class GameMap {

    public var offset:Vector2;

    public var lanes:Array<MapLane>;
    public var laneProjectiles:Array<Projectile>;
    public var availableLanes:Array<Bool>;

    public var tileUnits:Array<Unit>;
	
    public var width:Int;
    public var height:Int; 
    public var tileWidth:UInt;
    public var tileHeight:UInt;

    public var bounds:Vector2;

    public var monsters:Array<Unit>;
    public var heroes:Array<Unit>;

    public var importantMonsters(get, null):Int;

    public function new(width:Int, height:Int, tileWidth:UInt, tileHeight:UInt) {
        offset = new Vector2(0, 0);

        lanes = [for(i in 0...height) { new MapLane(); }];
        tileUnits = [for(i in 0...width) { for(j in 0...height) { null; }}];
        availableLanes = Data.game.lanesAvailable;

        this.width = width;
        this.height = height;
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;

        bounds = new Vector2(tileWidth * width * 1.2, tileWidth * width * 1.2);

        monsters = [];
        heroes = [];
    }

    public function createHero(x:Int, y:Int, unitData:UnitData) {
        var hero:Hero = new Hero(x, y, unitData, this);
        heroes.push(hero.unit);
        GameState.camera.add(hero);
    }

    public function createMonster(x:Int, y:Int, unitData:UnitData) {
        var monster:Monster = new Monster(x, y, unitData, this);
        monsters.push(monster.unit);
        GameState.camera.add(monster);
    }

    public function checkTileEmpty(tx:Int, ty:Int):Bool {
        return tx >= 0 && tx < width && ty >= 0 && ty < height
            && tileUnits[ty * width + tx] == null && availableLanes[ty];
    }

    public function checkTileUnitType(tx:Int, ty:Int, type:UnitType):Bool {
        return tx >= 0 && tx < width && ty >= 0 && ty < height &&
            tileUnits[ty * width + tx] != null && tileUnits[ty * width + tx].type == type;
    }

    public function getUnitInTile(tx:Int, ty:Int):Unit {
        if(tx >= 0 && tx < width && ty >= 0 && ty < height) {
            return tileUnits[ty * width + tx];
        } else {
            return null;
        }
    }

    public inline function getMonstersInRange(x:Float, y:Float, range:Float) {
        return getUnitsOfTypeInRange(x, y, range, UnitType.MONSTER);
    }

    public inline function getHeroesInRange(x:Float, y:Float, range:Float) {
        return getUnitsOfTypeInRange(x, y, range, UnitType.HERO);
    }

    public function getUnitsOfTypeInRange(x:Float, y:Float, range:Float, type:UnitType) {
        var units:Array<Unit> = [];
        var unitPool:Array<Unit>;
        if(type == UnitType.MONSTER) {
            unitPool = monsters;
        } else {
            unitPool = heroes;
        }
        for(unit in unitPool) {
            var dx = unit.x - x;
            var dy = unit.y - y;
            if(dx * dx + dy * dy < range * range) {
                units.push(unit);
            }
        }
        return units;
    }

    public function get_importantMonsters():Int {
        var importantMonsterCount:Int = 0;
        for(lane in lanes) {
            for(monster in lane.monsterGroup)
            {
                if(monster.important && !monster.dead) {
                    importantMonsterCount++;
                }
            }
        }
        return importantMonsterCount;
    }

}
    