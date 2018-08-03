package game.gameplay;

import kha.Color;
import kha.Image;
import kha.Assets;
import kha.input.KeyCode;
import kha.math.Vector2;
import kext.Application;
import kext.AppState;
import kext.g2basics.BasicTileset;

import game.data.Unit;

class GameState extends AppState {

    private var mapoffset:Vector2;

    private var unitTileset:Array<Unit>;

    private var backgroundTileset:BasicTileset;
    private var foregroundTileset:BasicTileset;
	
    private var mapWidth:Int;
    private var mapHeight:Int; 
    private static inline var TILE_WIDTH:UInt = 16;
    private static inline var TILE_HEIGHT:UInt = 16; 

    public function new() {
        super();

        mapoffset = new Vector2(0, 0);

        setupData();

        setupTilesets();
    }

    private function setupData() {
        mapWidth = Data.game.mapSizeX;
        mapHeight = Data.game.mapSizeY;
    }

    private function setupTilesets() {
        unitTileset = [for(i in 0...mapWidth) { for(j in 0...mapHeight) { null; }}];

        backgroundTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        backgroundTileset.setupTiledata(mapWidth, mapHeight, TILE_WIDTH, TILE_HEIGHT, 0);

        foregroundTileset = new BasicTileset(0, 0, Assets.images.Tileset_Basic);
        foregroundTileset.setupTiledata(mapWidth, mapHeight, TILE_WIDTH, TILE_HEIGHT, -1);
        var tile:UInt = 0;
        for(i in 0...mapWidth) {
            if(i == 0) { tile = 5; }
            else if(i == mapWidth - 1) { tile = 7; }
            else { tile = 6; }
            foregroundTileset.data[i] = tile;
        }
        for(i in 1...mapHeight) {
            foregroundTileset.data[i * mapWidth] = 10;
            foregroundTileset.data[i * mapWidth + mapWidth - 1] = 9;
        }
    }
    
	override public function update(delta:Float) {
        handleMapScrolling();
    }

    private function handleMapScrolling() {
        //Keyboard scrolling
        if(Application.keyboard.keyPressed(KeyCode.W)) {
            mapoffset.y = Math.round(mapoffset.y + 1);
        } else if(Application.keyboard.keyPressed(KeyCode.S)) {
            mapoffset.y = Math.round(mapoffset.y - 1);
        }
        if(Application.keyboard.keyPressed(KeyCode.A)) {
            mapoffset.x = Math.round(mapoffset.x + 1);
        } else if(Application.keyboard.keyPressed(KeyCode.D)) {
            mapoffset.x = Math.round(mapoffset.x - 1);
        }

        //Mouse scrolling
        if(Application.mouse.buttonDown(1)) {
            mapoffset = mapoffset.add(Application.mouse.posDelta.mult(-Data.game.mouseSensibility));
        }


        //Sprite scrolling
        mapoffset.x = kext.math.MathExt.clamp(mapoffset.x, -1 - (mapWidth - 4), 1);
        mapoffset.y = kext.math.MathExt.clamp(mapoffset.y, -1 - (mapHeight - 4), 1);
        backgroundTileset.transform.x = mapoffset.x * TILE_WIDTH;
        backgroundTileset.transform.y = mapoffset.y * TILE_HEIGHT;
        foregroundTileset.transform.x = mapoffset.x * TILE_WIDTH;
        foregroundTileset.transform.y = mapoffset.y * TILE_HEIGHT;
    }

	private var clearColor:Color = Color.fromString("#FF000000");
	override public function render(backbuffer:Image) {
        beginAndClear2D(backbuffer, clearColor);

        backgroundTileset.render(backbuffer);
        foregroundTileset.render(backbuffer);

        end2D(backbuffer);
    }

}