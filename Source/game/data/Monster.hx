package game.data;

import kha.Image;
import kha.math.Vector2;
import kha.math.Vector2i;
import kext.Basic;
import kext.ExtAssets;
import kext.g2basics.BasicSprite;
import de.polygonal.ds.ArrayedQueue;

import game.data.Unit.UnitType;

@:structInit
class Monster extends Basic {
    public var unit:Unit;
    public var sprite:BasicSprite;

    public function new(x:Int, y:Int, unit:Unit, map:TileData) {
        super();

        this.unit = unit;
        unit.init(map, UnitType.MONSTER);

        sprite = BasicSprite.fromFrame(0, 0, ExtAssets.frames.get(unit.spriteName));
        sprite.transform.originY -= (map.tileHeight - sprite.box.y * 0.5);

        setPosition(new Vector2i(x, y));
    }

    override public function update(delta:Float) {
        unit.update(delta);

        if(!unit.dead) {
            if(unit.target == null) {
                tryGetTarget();
            }

            if(unit.target != null) {
                unit.tryAttack();
            }
        }
    }

    private function tryGetTarget() {
        var posibilities:Array<Unit> = [];
        tryAddTileTarget(posibilities, unit.position.x - 1, unit.position.y);
        tryAddTileTarget(posibilities, unit.position.x + 1, unit.position.y);
        tryAddTileTarget(posibilities, unit.position.x, unit.position.y - 1);
        tryAddTileTarget(posibilities, unit.position.x, unit.position.y + 1);

        if(posibilities.length > 0) {
            var index:Int = Math.floor(Math.random() * posibilities.length);
            unit.target = posibilities[index];
        }
    }

    private function tryAddTileTarget(posibilities:Array<Unit>, x:Int, y:Int) {
        if(unit.map.checkTileUnit(x, y, UnitType.HERO) && !unit.map.getUnitInTile(x, y).dead) {
            posibilities.push(unit.map.getUnitInTile(x, y));
        }
    }

    private function setPosition(vec:Vector2i) {
        unit.position = vec;
        sprite.transform.x = unit.position.x * unit.map.tileWidth + unit.map.tileWidth * 0.5;
        sprite.transform.y = unit.position.y * unit.map.tileHeight;
    }

    override public function render(backbuffer:Image) {
        sprite.color.R = unit.dead ? 1 : 1;
        sprite.color.G = unit.dead ? 0.2 : 1;
        sprite.color.B = unit.dead ? 0.2 : 1;
        sprite.color.A = unit.dead ? unit.getRespawnAlpha() : 1;
        sprite.render(backbuffer);
        backbuffer.g2.pushTransformation(sprite.transform.getMatrix().multmat(backbuffer.g2.transformation));
        backbuffer.g2.color = kha.Color.Red;
        backbuffer.g2.fillRect(0, 0, unit.map.tileWidth * unit.getHealthPercentage(), 1);
        backbuffer.g2.popTransformation();
    }

}