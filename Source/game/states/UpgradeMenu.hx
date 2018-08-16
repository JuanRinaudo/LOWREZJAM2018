package game.states;

import kha.Assets;
import kha.Image;
import kha.Color;
import kext.AppState;
import kext.Application;
import kext.g2basics.BasicSprite;
import kext.g2basics.Text;
import kext.ExtAssets;
import kext.g2basics.Alignment;

import game.data.*;

class UpgradeMenu extends AppState {

    public var open:Bool;

    private var unit:Unit;

    private var monsterName:Text;

    private var killStart:Bool;

    private var killSprite:BasicSprite;
    private var killConfirm:BasicSprite;

    private var healthSprite:BasicSprite;
    private var damageSprite:BasicSprite;
    private var defenseSprite:BasicSprite;
    private var speedSprite:BasicSprite;

    private var upgradedColor:Color;
    private var upgradeCanBuyColor:Color;
    private var upgradeUnavalableColor:Color;

    public function new() {
        super();

        upgradedColor = Color.fromString(Data.ui.upgradedColor);
        upgradeCanBuyColor = Color.fromString(Data.ui.upgradeCanBuyColor);
        upgradeUnavalableColor = Color.fromString(Data.ui.upgradeUnavalableColor);

        monsterName = new Text(0, Data.ui.nameY, Application.width, Data.ui.fontSize);
        monsterName.fontSize = Data.ui.fontSize;
        monsterName.horizontalAlign = HorizontalAlign.MIDDLE;
        monsterName.verticalAlign = VerticalAlign.TOP;

        killSprite = BasicSprite.fromFrame(Data.ui.killSpritePos.x, Data.ui.killSpritePos.y, ExtAssets.frames.UI_Kill_1);
        killConfirm = BasicSprite.fromFrame(Data.ui.killSpritePos.x, Data.ui.killSpritePos.y, ExtAssets.frames.UI_Kill_2);

        healthSprite = BasicSprite.fromFrame(3, Data.ui.healthY, ExtAssets.frames.UI_Health);
        defenseSprite = BasicSprite.fromFrame(3, Data.ui.defenseY, ExtAssets.frames.UI_Defense);
        damageSprite = BasicSprite.fromFrame(3, Data.ui.damageY, ExtAssets.frames.UI_Damage);
        speedSprite = BasicSprite.fromFrame(3, Data.ui.speedY, ExtAssets.frames.UI_Speed);
    }

    public function setUnit(unit:Unit) {
        killStart = false;
        
        this.unit = unit;

        refreshName();
    }

    override public function update(delta:Float) {
        if(unit.dead) {
            open = false;
        }

        if(Application.mouse.buttonPressed(0)) {
            checkStatIncrease();

            if(Data.ui.killRectangle.pointInside(Application.mouse.position)) {
                if(killStart) {
                    unit.kill();
                    open = false;
                } else {
                    killStart = true;
                }
            } else if(!Data.ui.upgradeRectangle.pointInside(Application.mouse.position)) {
                open = false;
            }
        }
    }

    private function checkStatIncrease() {
        if(unit.canUpgrade) {
            if(checkScreenClick(Data.ui.healthY, Data.ui.statBoxHeight) && unit.healthLevel < unit.data.healthMaxLevel) {
                unit.healthLevel++;
                Application.audio.playSound(Assets.sounds.Upgrade, .3);
                Player.souls -= unit.data.upgradeCost;
                UnitManager.tryEvolveMonster(unit);
            } else if(checkScreenClick(Data.ui.defenseY, Data.ui.statBoxHeight) && unit.defenseLevel < unit.data.defenseMaxLevel) {
                unit.defenseLevel++;
                Application.audio.playSound(Assets.sounds.Upgrade, .3);
                Player.souls -= unit.data.upgradeCost;
                UnitManager.tryEvolveMonster(unit);
            } else if(checkScreenClick(Data.ui.damageY, Data.ui.statBoxHeight) && unit.damageLevel < unit.data.damageMaxLevel) {
                unit.damageLevel++;
                Application.audio.playSound(Assets.sounds.Upgrade, .3);
                Player.souls -= unit.data.upgradeCost;
                UnitManager.tryEvolveMonster(unit);
            } else if(checkScreenClick(Data.ui.speedY, Data.ui.statBoxHeight) && unit.speedLevel < unit.data.speedMaxLevel) {
                unit.speedLevel++;
                Application.audio.playSound(Assets.sounds.Upgrade, .3);
                Player.souls -= unit.data.upgradeCost;
                UnitManager.tryEvolveMonster(unit);
            }
        }
        refreshName();
    }

    private function refreshName() {
        monsterName.text = unit.data.name;
    }

    private function checkScreenClick(startY:Int, height:Int):Bool {
        return Application.mouse.y > startY && Application.mouse.y < startY + height;
    }

    override public function render(backbuffer:Image) {
        backbuffer.g2.transformation = kha.math.FastMatrix3.identity();
        backbuffer.g2.color = Color.fromString(Data.ui.killRectangleColor);
        backbuffer.g2.fillRect(Data.ui.killRectangle.x, Data.ui.killRectangle.y, Data.ui.killRectangle.width, Data.ui.killRectangle.height);

        backbuffer.g2.color = Color.fromString(Data.ui.upgradeBackgroundColor);
        backbuffer.g2.fillRect(Data.ui.upgradeRectangle.x, Data.ui.upgradeRectangle.y, Data.ui.upgradeRectangle.width, Data.ui.upgradeRectangle.height);

        if(killStart) {
            killConfirm.render(backbuffer);
        } else {
            killSprite.render(backbuffer);
        }

        monsterName.render(backbuffer);

        healthSprite.render(backbuffer);
        renderBars(backbuffer, 13, Data.ui.healthY, unit.data.healthMaxLevel, unit.healthLevel);
        defenseSprite.render(backbuffer);
        renderBars(backbuffer, 13, Data.ui.defenseY, unit.data.defenseMaxLevel, unit.defenseLevel);
        damageSprite.render(backbuffer);
        renderBars(backbuffer, 13, Data.ui.damageY, unit.data.damageMaxLevel, unit.damageLevel);
        speedSprite.render(backbuffer);
        renderBars(backbuffer, 13, Data.ui.speedY, unit.data.speedMaxLevel, unit.speedLevel);
    }

    private function renderBars(backbuffer:Image, x:Float, y:Float, max:Int, value:Int) {
        for(i in 0...max) {
            backbuffer.g2.color = (i < value ?
                upgradedColor :
                unit.canUpgrade ? upgradeCanBuyColor : upgradeUnavalableColor);
            backbuffer.g2.fillRect(x + i * 3, y, 2, Data.ui.statBoxHeight);
        }
    }

}