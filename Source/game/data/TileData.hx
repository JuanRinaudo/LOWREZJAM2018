package game.data;

import kha.math.Vector2;

import game.data.Unit.UnitType;

@:structInit
class TileData {

    public var offset:Vector2;

    public var tileWalkable:Array<Bool>;
    public var tileUnits:Array<Unit>;
	
    public var width:Int;
    public var height:Int; 
    public var tileWidth:UInt;
    public var tileHeight:UInt; 

    public function new(width:Int, height:Int, tileWidth:UInt, tileHeight:UInt) {
        offset = new Vector2(0, 0);

        tileWalkable = [for(i in 0...width) { for(j in 0...height) { true; }}];
        tileUnits = [for(i in 0...width) { for(j in 0...height) { null; }}];

        this.width = width;
        this.height = height;
        this.tileWidth = tileWidth;
        this.tileHeight = tileHeight;
    }

    public function checkTileWalkable(tx:Int, ty:Int) {
        return tx >= 0 && tx < width && ty >= 0 && ty < height &&
            tileWalkable[ty * width + tx] &&
            (tileUnits[ty * width + tx] == null || (tileUnits[ty * width + tx] != null && tileUnits[ty * width + tx].dead));
    }

    public function checkTileUnit(tx:Int, ty:Int, type:UnitType) {
        return tx >= 0 && tx < width && ty >= 0 && ty < height &&
            tileUnits[ty * width + tx] != null && tileUnits[ty * width + tx].type == type;
    }

    public function getUnitInTile(tx:Int, ty:Int) {
        if(tx >= 0 && tx < width && ty >= 0 && ty < height) {
            return tileUnits[ty * width + tx];
        } else {
            return null;
        }
    }

}
    