package game.data;

import kha.Image;
import kext.Basic;

class GameDirector extends Basic {

    private var map:GameMap;

    private var lastLane:Int = -1;
    private var spawnTimer:Float = 0;

    private var currentLevel:Int;

    public function new(map:GameMap) {
        super();

        this.map = map;
    }

    override public function update(delta:Float) {
        if(spawnTimer <= 0) {
            currentLevel = getCurrentSpawnLevel();
            var lane:Int = getRandomLane();
            if(lane != -1) {
                map.createHero(-1, lane, getHeroToSpawn());
            }
            spawnTimer = Data.game.heroSpawnTimeByLevel[currentLevel];
            if(currentLevel == Data.game.heroSpawnTimeByLevel.length - 1) {
                spawnTimer = Math.max(spawnTimer - Player.time * Data.game.maxHeroSpawnTimeDivisor, Data.game.minHeroSpawnTimer);
            }
        } else {
            spawnTimer -= delta;
        }
    }

    private function getRandomLane():Int {
        var lane:Int = -1;
        var posibleLanes:Array<Int> = [];
        for(i in 0...map.availableLanes.length) {
            if(map.availableLanes[i]) {
                posibleLanes.push(i);
            }
        }
        var index:Int = Math.floor(Math.random() * posibleLanes.length);
        if(index == lastLane) {
            index++;
        }
        lastLane = index;
        return posibleLanes[index % posibleLanes.length];
    }

    private function getHeroToSpawn():UnitData {
        var spawnLevel:Int = getChancedLevel(currentLevel);
        return getRandomHeroFromLevel(spawnLevel);
    }

    private function getCurrentSpawnLevel() {
        var maxPerSouls:Int = 0;
        while(maxPerSouls + 1 < Data.game.heroMaxLevelPerSouls.length && Player.totalSouls > Data.game.heroMaxLevelPerSouls[maxPerSouls + 1]) {
            maxPerSouls++;
        }
        var maxPerTime:Int = 0;
        while(maxPerTime + 1 < Data.game.heroMaxLevelPerTime.length && Player.time > Data.game.heroMaxLevelPerTime[maxPerTime + 1]) {
            maxPerTime++;
        }
        return Math.floor(Math.min(maxPerSouls, maxPerTime));
    }

    private function getRandomHeroFromLevel(level:Int) {
        var heroes:Array<UnitData> = UnitManager.heroByLevel.get(level);
        var index:Int = Math.floor(Math.random() * heroes.length);
        return heroes[index];
    }

    private function getChancedLevel(level:Int) {
        var sum:Float = 0;
        for(chance in Data.game.heroSpawnChances) {
            sum += chance;
        }
        var random = Math.random() * sum;
        var i = 0;
        while(random > Data.game.heroSpawnChances[i]) {
            random -= Data.game.heroSpawnChances[i];
            i++;
        }
        return Math.floor(Math.max(level - i, 0));
    }

    override public function render(backbuffer:Image) {

    }

}