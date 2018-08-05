package game.gameplay;

import kha.Image;
import kha.Color;
import kext.AppState;
import kext.Application;
import kext.g2basics.BasicSprite;
import kext.g2basics.Text;
import kext.ExtAssets;

import game.data.Unit;

class UpgradeMenu extends AppState {

    private var unit:Unit;

    private var monsterSprite:BasicSprite;
    private var monsterName:Text;

    private var healthSprite:BasicSprite;
    private var damageSprite:BasicSprite;
    private var defenseSprite:BasicSprite;
    private var speedSprite:BasicSprite;

    public function new() {
        super();
    }

    public function setUnit(unit:Unit) {
        this.unit = unit;

        monsterSprite = BasicSprite.fromFrame(12, 0, ExtAssets.frames.get(unit.spriteName));
        monsterSprite.transform.originY -= (24 - monsterSprite.box.y * 0.5);

        monsterName = new Text(24, 2, 36, 12, unit.name);
        monsterName.fontSize = 12;

        healthSprite = BasicSprite.fromFrame(7, 30, ExtAssets.frames.UI_Health);
        damageSprite = BasicSprite.fromFrame(7, 39, ExtAssets.frames.UI_Damage);
        defenseSprite = BasicSprite.fromFrame(7, 48, ExtAssets.frames.UI_Defense);
        speedSprite = BasicSprite.fromFrame(7, 57, ExtAssets.frames.UI_Speed);
    }

    override public function update(delta:Float) {

    }

    override public function render(backbuffer:Image) {
        backbuffer.g2.transformation = kha.math.FastMatrix3.identity();
        backbuffer.g2.color = Color.fromString("#FF73B1B5");
        backbuffer.g2.fillRect(0, 0, 24, 24);
        backbuffer.g2.color = Color.fromString("#FF808080");
        backbuffer.g2.fillRect(24, 0, 48, 24);
        backbuffer.g2.color = Color.fromString("#FFDAB2FF");
        backbuffer.g2.fillRect(0, 24, 64, 48);

        monsterSprite.render(backbuffer);
        monsterName.render(backbuffer);

        healthSprite.render(backbuffer);
        renderBars(backbuffer, 13, 26, unit.healthMaxMultiplier, unit.healthMultiplier);
        defenseSprite.render(backbuffer);
        renderBars(backbuffer, 13, 35, unit.defenseMaxMultiplier, unit.defenseMultiplier);
        damageSprite.render(backbuffer);
        renderBars(backbuffer, 13, 44, unit.damageMaxMultiplier, unit.damageMultiplier);
        speedSprite.render(backbuffer);
        renderBars(backbuffer, 13, 53, unit.speedMaxMultiplier, unit.speedMultiplier);
    }

    private function renderBars(backbuffer:Image, x:Float, y:Float, max:Int, value:Float) {
        var valueIndex:Int = Math.floor((value - 1) * 10);
        for(i in 0...max) {
            backbuffer.g2.color = i < valueIndex ? Color.Red : Color.White;
            backbuffer.g2.fillRect(x + i * 3, y, 2, 8);
        }
    }

}