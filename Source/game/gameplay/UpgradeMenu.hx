package game.gameplay;

import kha.Image;
import kha.Color;
import kext.AppState;
import kext.Application;
import kext.g2basics.BasicSprite;
import kext.g2basics.Text;
import kext.ExtAssets;
import kext.g2basics.Alignment;

import game.data.Unit;
import game.data.UnitManager;

class UpgradeMenu extends AppState {

    public var open:Bool;

    private var unit:Unit;

    private var spriteName:String;
    private var monsterSprite:BasicSprite;
    private var monsterName:Text;

    private var backSprite:BasicSprite;

    private var healthSprite:BasicSprite;
    private var damageSprite:BasicSprite;
    private var defenseSprite:BasicSprite;
    private var speedSprite:BasicSprite;

    public function new() {
        super();
    }

    public function setUnit(unit:Unit) {
        this.unit = unit;

        monsterName = new Text(25, -1, 36, 12);
        monsterName.fontSize = 12;
        monsterName.horizontalAlign = HorizontalAlign.LEFT;
        monsterName.verticalAlign = VerticalAlign.TOP;

        tryRefreshSprite();

        backSprite = BasicSprite.fromFrame(4, 4, ExtAssets.frames.UI_Back);

        healthSprite = BasicSprite.fromFrame(7, 29, ExtAssets.frames.UI_Health);
        damageSprite = BasicSprite.fromFrame(7, 39, ExtAssets.frames.UI_Damage);
        defenseSprite = BasicSprite.fromFrame(7, 49, ExtAssets.frames.UI_Defense);
        speedSprite = BasicSprite.fromFrame(7, 59, ExtAssets.frames.UI_Speed);
    }

    override public function update(delta:Float) {
        if(Application.mouse.buttonPressed(0)) {
            checkStatIncrease();            

            if(Application.mouse.position.x < 8 && Application.mouse.position.y < 8) {
                open = false;
                monsterSprite = null;
            }
        }
    }

    private function checkStatIncrease() {
        if(checkScreenClick(25, 8) && unit.healthLevel < unit.data.healthMaxLevel) {
            unit.healthLevel++;
            UnitManager.tryEvolveMonster(unit);
        } else if(checkScreenClick(35, 8) && unit.damageLevel < unit.data.damageMaxLevel) {
            unit.damageLevel++;
            UnitManager.tryEvolveMonster(unit);
        } else if(checkScreenClick(45, 8) && unit.defenseLevel < unit.data.defenseMaxLevel) {
            unit.defenseLevel++;
            UnitManager.tryEvolveMonster(unit);
        } else if(checkScreenClick(55, 8) && unit.speedLevel < unit.data.speedMaxLevel) {
            unit.speedLevel++;
            UnitManager.tryEvolveMonster(unit);
        }
        tryRefreshSprite();
    }

    private function tryRefreshSprite() {
        if(monsterSprite == null || unit.data.spriteName != spriteName) {
            spriteName = unit.data.spriteName;
            monsterSprite = BasicSprite.fromFrame(12, 0, ExtAssets.frames.get(unit.data.spriteName));
            monsterSprite.transform.originY -= (24 - monsterSprite.box.y * 0.5);
            monsterName.text = unit.data.name;
        }
    }

    private function checkScreenClick(startY:Int, height:Int):Bool {
        return Application.mouse.y > startY && Application.mouse.y < startY + height;
    }

    override public function render(backbuffer:Image) {
        backbuffer.g2.transformation = kha.math.FastMatrix3.identity();
        backbuffer.g2.color = Color.fromString("#FFA0A0A0");
        backbuffer.g2.fillRect(0, 0, 24, 24);
        backbuffer.g2.color = Color.fromString("#FF404040");
        backbuffer.g2.fillRect(24, 0, 48, 24);
        backbuffer.g2.color = Color.fromString("#FFD6E1FF");
        backbuffer.g2.fillRect(0, 24, 64, 48);

        monsterSprite.render(backbuffer);
        monsterName.render(backbuffer);

        backSprite.render(backbuffer);

        healthSprite.render(backbuffer);
        renderBars(backbuffer, 13, 25, unit.data.healthMaxLevel, unit.healthLevel);
        defenseSprite.render(backbuffer);
        renderBars(backbuffer, 13, 35, unit.data.damageMaxLevel, unit.damageLevel);
        damageSprite.render(backbuffer);
        renderBars(backbuffer, 13, 45, unit.data.defenseMaxLevel, unit.defenseLevel);
        speedSprite.render(backbuffer);
        renderBars(backbuffer, 13, 55, unit.data.speedMaxLevel, unit.speedLevel);
    }

    private function renderBars(backbuffer:Image, x:Float, y:Float, max:Int, value:Int) {
        for(i in 0...max) {
            backbuffer.g2.color = i < value ? Color.Red : Color.White;
            backbuffer.g2.fillRect(x + i * 3, y, 2, 8);
        }
    }

}