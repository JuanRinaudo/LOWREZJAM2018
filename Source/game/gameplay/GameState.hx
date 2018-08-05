package game.gameplay;

import kha.Color;
import kha.Image;
import kha.Assets;
import kha.input.KeyCode;
import kha.math.Vector2;
import kha.math.Vector2i;
import kext.Application;
import kext.AppState;
import kext.g2basics.Camera2D;
import kext.g2basics.BasicTileset;

import game.data.Unit;
import game.data.Hero;
import game.data.Monster;
import game.data.TileData;

class GameState extends AppState {

    private var camera:Camera2D;
    private var mainLayer:Layer;
    private var backgroundLayer:Layer;
    private var foregroundLayer:Layer;

    private var map:TileData;

    private var tileCursor:Vector2i;

    private var backgroundTileset:BasicTileset;
    private var foregroundTileset:BasicTileset;

    private var upgradeMenu:UpgradeMenu;
    private var upgradeOpen:Bool;

    private var heroes:Array<Hero>;
    private var monsters:Array<Monster>;

    public function new() {
        super();

        camera = new Camera2D(0, 0);
        mainLayer = camera.defaultLayer;
        backgroundLayer = camera.createLayer(0);
        foregroundLayer = camera.createLayer(10);

        tileCursor = new Vector2i(0, 0);

        setupData();
        setupTilesets();
        setupUnits();
        
        upgradeMenu = new UpgradeMenu();
    }

    private function setupData() {
        map = new TileData(Data.game.mapSizeX, Data.game.mapSizeY, 16, 16);
    }

    private function setupUnits() {
        heroes = [];
        monsters = [];
        createHero(1, 1, Data.game.heroes[0]);
    }

    private function createHero(x:Int, y:Int, unitData:UnitData) {
        var hero:Hero = new Hero(x, y, new Unit(unitData), map);
        heroes.push(hero);
        camera.add(hero);
    }

    private function createMonster(x:Int, y:Int, unitData:UnitData) {
        var monster:Monster = new Monster(x, y, new Unit(unitData), map);
        monsters.push(monster);
        camera.add(monster);
    }

    private function setupTilesets() {
        backgroundTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        backgroundTileset.setupTiledata(map.width, map.height, map.tileWidth, map.tileHeight, 0);

        foregroundTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        foregroundTileset.setupTiledata(map.width, map.height, map.tileWidth, map.tileHeight, -1);
        var tile:UInt = 0;
        for(i in 0...map.width) {
            if(i == 0) { tile = 5; }
            else if(i == map.width - 1) { tile = 7; }
            else { tile = 6; }
            foregroundTileset.data[i] = tile;
            map.tileWalkable[i] = false;
        }
        for(i in 1...map.height) {
            foregroundTileset.data[i * map.width] = 10;
            map.tileWalkable[i * map.width] = false;
            foregroundTileset.data[i * map.width + map.width - 1] = 9;
            map.tileWalkable[i * map.width + map.width - 1] = false;
        }
        // for(i in 0...10) {
        //     var index = Math.floor(Math.random() * map.width * map.height);
        //     foregroundTileset.data[index] = 4;
        //     map.tileWalkable[index] = false;
        // }

        backgroundLayer.add(backgroundTileset);
        foregroundLayer.add(foregroundTileset);
    }
    
	override public function update(delta:Float) {
        handleMapScrolling();
        calculateTileCursor();
        checkMouseClick();
        
        if(upgradeOpen) {
            upgradeMenu.update(delta);
        }
        
        camera.update(delta);
    }

    private function handleMapScrolling() {
        //Keyboard scrolling
        if(Application.keyboard.keyPressed(KeyCode.W)) {
            map.offset.y = Math.round(map.offset.y + 1);
        } else if(Application.keyboard.keyPressed(KeyCode.S)) {
            map.offset.y = Math.round(map.offset.y - 1);
        }
        if(Application.keyboard.keyPressed(KeyCode.A)) {
            map.offset.x = Math.round(map.offset.x + 1);
        } else if(Application.keyboard.keyPressed(KeyCode.D)) {
            map.offset.x = Math.round(map.offset.x - 1);
        }

        //Mouse scrolling
        if(Application.mouse.buttonDown(1)) {
            map.offset = map.offset.add(Application.mouse.posDelta.mult(-Data.game.mouseSensibility));
        }

        //Sprite scrolling
        map.offset.x = kext.math.MathExt.clamp(map.offset.x, -1 - (map.width - 4), 1);
        map.offset.y = kext.math.MathExt.clamp(map.offset.y, -1 - (map.height - 4), 1);
        camera.transform.x = map.offset.x * map.tileWidth;
        camera.transform.y = map.offset.y * map.tileHeight;
    }

    private function calculateTileCursor() {
        tileCursor.x = Math.floor((Application.mouse.position.x) / map.tileWidth - map.offset.x);
        tileCursor.y = Math.floor((Application.mouse.position.y) / map.tileHeight - map.offset.y);
    }

    private function checkMouseClick() {
        if(Application.mouse.buttonPressed(0)) {
            if(map.checkTileWalkable(tileCursor.x, tileCursor.y)) {
                createMonster(tileCursor.x, tileCursor.y, Data.game.monsters[0]);
            } else if(map.checkTileUnit(tileCursor.x, tileCursor.y, UnitType.MONSTER)) {
                openUpgradeMenu(map.getUnitInTile(tileCursor.x, tileCursor.y));
            }
        }
    }

    private function openUpgradeMenu(unit:Unit) {
        upgradeMenu.setUnit(unit);
        upgradeOpen = true;
    }

	private var clearColor:Color = Color.fromString("#FF000000");
	override public function render(backbuffer:Image) {
        beginAndClear2D(backbuffer, clearColor);

        camera.render(backbuffer);

        renderTileCursor(backbuffer);

        // backbuffer.g2.transformation = kha.math.FastMatrix3.identity();
        // for(i in 0...4) {
        //     for(j in 0...4) {
        //         backbuffer.g2.color = j % 2 == 0 ?
        //             (i % 2 == 0 ? Color.fromFloats(1, 0, 0, 0.2) : Color.fromFloats(0, 1, 0, 0.2)) :
        //             (i % 2 == 0 ? Color.fromFloats(0, 1, 0, 0.2) : Color.fromFloats(1, 0, 0, 0.2));
        //         backbuffer.g2.fillRect(i * map.tileWidth, j * map.tileHeight, map.tileWidth, map.tileHeight);
        //     }
        // }

        if(upgradeOpen) {
            upgradeMenu.render(backbuffer);
        }

        end2D(backbuffer);
    }

    private function renderTileCursor(backbuffer:Image) {
        backbuffer.g2.transformation = kha.math.FastMatrix3.identity();
        backbuffer.g2.transformation = backbuffer.g2.transformation.multmat(kha.math.FastMatrix3.translation(
            (tileCursor.x + map.offset.x) * map.tileWidth,
            (tileCursor.y + map.offset.y) * map.tileHeight
        ));
        backbuffer.g2.color = map.checkTileWalkable(tileCursor.x, tileCursor.y) ? Color.Green : Color.Red;
        backbuffer.g2.drawRect(0, 0, map.tileWidth, map.tileHeight, 2);
    }

}