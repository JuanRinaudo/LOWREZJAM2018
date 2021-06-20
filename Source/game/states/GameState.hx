package game.states;

import kha.Color;
import kha.Image;
import kha.Assets;
import kha.input.KeyCode;
import kha.math.Vector2;
import kha.math.Vector2i;
import kext.Application;
import kext.AppState;
import kext.ExtAssets;
import kext.AudioInstance;
import kext.g2basics.Text;
import kext.g2basics.Alignment;
import kext.g2basics.Camera2D;
import kext.g2basics.BasicSprite;
import kext.g2basics.BasicTileset;

import game.data.*;
import game.*;
import game.managers.*;

typedef InitialMonster = {x:Int, y:Int, monster:String};

class GameState extends AppState {

    public static var mainCamera:Camera2D;
    public static var mainLayer:CameraLayer;
    public static var backgroundLayer:CameraLayer;
    public static var decorationLayer:CameraLayer;
    public static var foregroundLayer:CameraLayer;
    public static var uiCamera:Camera2D;
    public static var uiLayer:CameraLayer;

    private var map:GameMap;
    private var gameDirector:GameDirector;

    private var tileCursor:Vector2i;
    private var mouseStartPosition:Vector2;

    private var backgroundTileset:BasicTileset;
    private var decorationTileset:BasicTileset;
    private var foregroundTileset:BasicTileset;

    private var upgradeMenu:UpgradeMenu;

    private var unitManager:UnitManager;

    private var soulCount:Text;
    
    private var initialMonster:UnitData;

    private static var music:AudioInstance;

    public function new() {
        super();

        Application.audio.masterVolume = 0;

        Player.init();

        mainCamera = new Camera2D(0, 0);
        mainLayer = mainCamera.defaultLayer;
        backgroundLayer = mainCamera.createLayer(0);
        decorationLayer = mainCamera.createLayer(5);
        mainCamera.moveLayer(mainLayer, 25);
        foregroundLayer = mainCamera.createLayer(50);

        uiCamera = new Camera2D(0, 0);
        uiCamera.transform.scaleX = uiCamera.transform.scaleY = Math.min(Application.width / 64, Application.height / 64);
        uiLayer = uiCamera.defaultLayer;

        tileCursor = new Vector2i(0, 0);
        mouseStartPosition = new Vector2(0, 0);

        if(music == null) {
            music = Application.audio.playSound(kha.Assets.sounds.Music, 1, true);
        }

        setupMap();
        setupTilesets();
        setupManagers();
        setupUpgradeMenu();
        setupInitialMonsters();
        setupGameDirector();
        setupUI();

        initialMonster = UnitManager.monsters.get(Data.game.spawnMonster);
    }

    private function setupMap() {
        map = new GameMap(Data.game.mapSizeX, Data.game.mapSizeY, 16, 16);
    }

    private function setupTilesets() {
        backgroundTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        backgroundTileset.setupTiledata(map.width, map.height, map.tileWidth, map.tileHeight, Data.game.tileSetFloor);

        decorationTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        decorationTileset.setupTiledata(map.width, map.height, map.tileWidth, map.tileHeight, -1);
        for(i in 0...map.width) {
            for(j in 0...map.height) {
                if(Math.random() < Data.game.tileSetDecorationChance) {
                    decorationTileset.data[j * map.width + i] = 
                        Math.floor(Math.random() * (Data.game.tileSetDecorationMax - Data.game.tileSetDecorationMin) + Data.game.tileSetDecorationMin);
                }
            }
        }

        foregroundTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        foregroundTileset.setupTiledata(map.width, map.height, map.tileWidth, map.tileHeight, -1);
        var tile:UInt = 0;
        for(i in 0...map.width) {
            for(j in 0...map.height) {
                if(!Data.game.lanesAvailable[j]) {
                    foregroundTileset.data[j * map.width + i] = 4;
                }
            }
        }

        backgroundLayer.add(backgroundTileset);
        decorationLayer.add(decorationTileset);
        foregroundLayer.add(foregroundTileset);
    }

    private function setupManagers() {
        var monsters:Dynamic = Data.game.monsters;
        UnitManager.addMonsters(monsters);
        var heroes:Dynamic = Data.game.heroes;
        UnitManager.addHeroes(heroes);
        var powers:Dynamic = Data.game.powers;
        PowerManager.addPowers(powers);
    }

    private function setupUpgradeMenu() {
        upgradeMenu = new UpgradeMenu();
    }

    private function setupInitialMonsters() {
        for(monster in Data.game.mapInitialMonsters) {
            var x:Int = (monster.x < 0) ? map.width + monster.x : monster.x;
            var y:Int = (monster.y < 0) ? map.height + monster.y : monster.y;
            if(x < 0 || x > map.width || y < 0 || y > map.height) { return; }
            map.createMonster(x, y, UnitManager.monsters.get(monster.name));
        }
    }

    private function setupGameDirector() {
        gameDirector = new GameDirector(map);
        foregroundLayer.add(gameDirector);
    }

    private function setupUI() {
        soulCount = new Text(Data.ui.soulTextPos.x, Data.ui.soulTextPos.y, Application.width, Data.ui.fontSize);
        soulCount.fontSize = Data.ui.fontSize;
        soulCount.horizontalAlign = HorizontalAlign.LEFT;
        uiLayer.add(soulCount);
        var soulSprite:BasicSprite = BasicSprite.fromFrame(Data.ui.soulSpritePos.x, Data.ui.soulSpritePos.y, ExtAssets.frames.UI_Souls);
        uiLayer.add(soulSprite);
    }

	override public function update(delta:Float) {
        if(Application.keyboard.keyPressed(KeyCode.M)) {
            Application.audio.masterVolume = Application.audio.masterVolume > 0 ? 0 : 1;
        }
        if(Application.keyboard.keyPressed(KeyCode.Add)) {
            Application.audio.masterVolume = Math.min(Application.audio.masterVolume + .1, 1);
        } else if(Application.keyboard.keyPressed(KeyCode.Subtract)) {
            Application.audio.masterVolume = Math.max(Application.audio.masterVolume - .1, 0);
        }

        checkGameover();

        soulCount.text = Player.soulsInt + "";

        mainCamera.update(delta);
        uiCamera.update(delta);

        Player.totalSouls += Math.max(Player.souls - Player.lastSouls, 0);
        Player.time += delta;

        if(upgradeMenu.open) {
            upgradeMenu.update(delta);
        } else {
            handleCameraScrolling();
            handleCameraZoom();
            calculateTileCursor();
            checkMouseClick();
        }

        Player.lastSouls = Player.souls;
    }

    private function checkGameover() {
        var gameover:Bool = map.importantMonsters == 0;
        if(gameover) {
            Application.changeState(GameOver);
        }
    }

    private function handleCameraScrolling() {
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
        if(Application.mouse.buttonDown(1) || 
            (Application.mouse.buttonDown(0) && Application.mouse.position.sub(mouseStartPosition).length >= Data.game.mouseScrollStartSensibility)) {
            map.offset = map.offset.add(Application.mouse.posDelta.mult(-Data.game.mouseSensibility * mainCamera.transform.scaleX));
        }

        //Sprite scrolling
        map.offset.x = kext.math.MathExt.clamp(map.offset.x, -Data.game.mainCameraExtra - (map.width - 4), Data.game.mainCameraExtra);
        map.offset.y = kext.math.MathExt.clamp(map.offset.y, -Data.game.mainCameraExtra - (map.height - 4), Data.game.mainCameraExtra);
        mainCamera.transform.x = map.offset.x * map.tileWidth;
        mainCamera.transform.y = map.offset.y * map.tileHeight;
    }

    private function handleCameraZoom() {
        if(Math.abs(Application.mouse.mouseWheel) > 0) {
            mainCamera.transform.scaleX -= Application.mouse.mouseWheel;
            mainCamera.transform.scaleY -= Application.mouse.mouseWheel;
        }
    }

    private function calculateTileCursor() {
        tileCursor.x = Math.floor((Application.mouse.position.x - mainCamera.transform.x) / (mainCamera.transform.scaleX * map.tileWidth));
        tileCursor.y = Math.floor((Application.mouse.position.y - mainCamera.transform.y) / (mainCamera.transform.scaleY * map.tileHeight));
    }

    private function checkMouseClick() {
        if(Application.mouse.buttonPressed(0)) {
            mouseStartPosition.x = Application.mouse.x;
            mouseStartPosition.y = Application.mouse.y;
        }
        if(Application.mouse.buttonReleased(0) && Application.mouse.position.sub(mouseStartPosition).length < Data.game.mouseScrollStartSensibility) {
            if(map.checkTileEmpty(tileCursor.x, tileCursor.y) && Player.souls >= initialMonster.createCost) {
                Player.souls -= initialMonster.createCost;
                map.createMonster(tileCursor.x, tileCursor.y, initialMonster);
            } else if(map.checkTileUnitType(tileCursor.x, tileCursor.y, UnitType.MONSTER)) {
                openUpgradeMenu(map.getUnitInTile(tileCursor.x, tileCursor.y));
            }
        }
    }

    private function openUpgradeMenu(unit:Unit) {
        upgradeMenu.setUnit(unit);
        upgradeMenu.open = true;
    }

	private var clearColor:Color = Color.fromString("#FF000000");
	override public function render(backbuffer:Image) {
        beginAndClear2D(backbuffer, clearColor);

        mainCamera.render(backbuffer);
        uiCamera.render(backbuffer);

        renderTileCursor(backbuffer);
        
        if(upgradeMenu.open) {
            upgradeMenu.render(backbuffer);
        }

        end2D(backbuffer);
    }

    private function renderTileCursor(backbuffer:Image) {
        backbuffer.g2.transformation = kha.math.FastMatrix3.identity();
        backbuffer.g2.transformation = mainCamera.transform.getMatrix().multmat(kha.math.FastMatrix3.translation(
            tileCursor.x * map.tileWidth,
            tileCursor.y * map.tileHeight
        ));
        backbuffer.g2.color = map.checkTileEmpty(tileCursor.x, tileCursor.y) ? Color.Green : Color.Red;
        backbuffer.g2.drawRect(0, 0, map.tileWidth, map.tileHeight, 2);
    }

}