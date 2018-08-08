package game.data;

import kha.Image;
import kha.math.Vector2;
import kha.math.Vector2i;
import kext.Basic;
import kext.g2basics.BasicSprite;

import game.data.Unit.UnitType;

@:structInit
class Hero extends Basic {
    public var unit:Unit;

    public var tileQueue:Array<Vector2i>;
    public var tileTrail:Array<Vector2i>;

    private var heroeWalkTimer:Float;

    private var lastDirection:Direction;

    public function new(x:Int, y:Int, unit:Unit, map:TileData) {
        super();

        this.unit = unit;
        unit.init(map, UnitType.HERO);

        unit.createSprite();

        setPosition(new Vector2i(x, y));
        tileQueue = new Array<Vector2i>();
        tileTrail = new Array<Vector2i>();
        tileTrail.push(unit.position);
    }

    override public function update(delta:Float) {
        unit.update(delta);

        if(!unit.dead) {
            if(unit.target == null) {
                tryGetTarget();
            }

            if(unit.target != null) {
                unit.tryAttack();
            } else {
                heroeWalkTimer += delta * unit.speed;
                tryMovement();
            }
        }
    }

    private function tryGetTarget() {
        var posibilities:Array<Unit> = [];
        // tryAddTileTarget(posibilities, unit.position.x - 1, unit.position.y);
        tryAddTileTarget(posibilities, unit.position.x + 1, unit.position.y);
        // tryAddTileTarget(posibilities, unit.position.x, unit.position.y - 1);
        // tryAddTileTarget(posibilities, unit.position.x, unit.position.y + 1);

        if(posibilities.length > 0) {
            var index:Int = Math.floor(Math.random() * posibilities.length);
            unit.target = posibilities[index];
        }
    }

    private function tryAddTileTarget(posibilities:Array<Unit>, x:Int, y:Int) {
        if(unit.map.checkTileUnit(x, y, UnitType.MONSTER) && !unit.map.getUnitInTile(x, y).dead) {
            posibilities.push(unit.map.getUnitInTile(x, y));
        }
    }

    private function tryMovement() {
        if(heroeWalkTimer > Data.game.heroWalkTime) {
            var posibilities:Array<Vector2i> = [];
            // tryAddTilePosiblity(posibilities, unit.position.x - 1, unit.position.y, Direction.RIGHT);
            tryAddTilePosiblity(posibilities, unit.position.x + 1, unit.position.y, Direction.LEFT);
            // tryAddTilePosiblity(posibilities, unit.position.x, unit.position.y - 1, Direction.DOWN);
            // tryAddTilePosiblity(posibilities, unit.position.x, unit.position.y + 1, Direction.UP);

            if(posibilities.length == 0) {
                lastDirection = null;
            } else {
                var index:Int = Math.floor(Math.random() * posibilities.length);
                setPosition(posibilities[index]);
            }

            heroeWalkTimer = 0;
        }
    }

    private function tryAddTilePosiblity(posibilities:Array<Vector2i>, x:Int, y:Int, lastDir:Direction) {
        if(unit.map.checkTileWalkable(x, y) && lastDirection != lastDir) {
            posibilities.push(new Vector2i(x, y));
        }
    }

    private function setPosition(vec:Vector2i) {
        if(unit.position.x < vec.x) { lastDirection = Direction.RIGHT; }
        if(unit.position.x > vec.x) { lastDirection = Direction.LEFT; }
        if(unit.position.y < vec.y) { lastDirection = Direction.DOWN; }
        if(unit.position.y > vec.y) { lastDirection = Direction.UP; }
        unit.position = vec;
        unit.sprite.transform.x = unit.position.x * unit.map.tileWidth + unit.map.tileWidth * 0.5;
        unit.sprite.transform.y = unit.position.y * unit.map.tileHeight;
    }

    override public function render(backbuffer:Image) {
        if(!unit.dead) {
            unit.sprite.render(backbuffer);
		    backbuffer.g2.pushTransformation(unit.sprite.transform.getMatrix().multmat(backbuffer.g2.transformation));
            backbuffer.g2.color = kha.Color.Red;
            backbuffer.g2.fillRect(0, 0, unit.map.tileWidth * unit.getHealthPercentage(), 1);
            backbuffer.g2.popTransformation();
        }
    }

}