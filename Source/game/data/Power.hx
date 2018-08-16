package game.data;

import kext.Basic;

import game.data.PowerType;

class Power extends Basic {

    public var data:PowerData;
    public var type:PowerType;

    public var unit:Unit;

    public var pasivePower:Bool;
    public var powerCooldownTimer:Float;
    public var durationTimer:Float;

    public function new(powerData:PowerData, ownerUnit:Unit) {
        super();

        data = powerData;
        unit = ownerUnit;

        type = PowerType.createByName(data.typeName);

        pasivePower = data.values.cooldown == null;
        powerCooldownTimer = 0;
        durationTimer = 0;
    }

    override public function update(delta:Float) {
        if(pasivePower) {
            if(type == PowerType.GeneratePerSecond) {
                var values:GeneratePerSecondValues = data.values;
                var type = Type.resolveClass(values.classToModify);
                var newFieldValue:Dynamic = Reflect.field(type, values.fieldToModify) + values.genenerationAmmount * delta;
                Reflect.setField(type, values.fieldToModify, newFieldValue);
            } else if(type == PowerType.RegenerateHealth) {
                var values:RegenerateHealthValues = data.values;
                var target:Unit = getPowerTarget(values.target);
                if(target != null) {
                    target.heal(values.healAmmount * unit.maxHealth * delta);
                }
            }
        } else {
            powerCooldownTimer = Math.min(powerCooldownTimer + delta, data.values.cooldown);
            if(powerCooldownTimer == data.values.cooldown) {
                powerCooldownTimer = 0;
                if(type == PowerType.HealUnit) {
                    var values:HealUnitValues = data.values;
                    var target:Unit = getPowerTarget(values.target, values.range);
                    target.heal(values.value * unit.maxHealth);
                } else if(type == PowerType.TempStatChange) {
                    var values:TempStatChangeValues = data.values;
                    var target:Unit = getPowerTarget(values.target, values.range);
                    target.changeTempStat(values.stat, values.value, values.duration);
                    durationTimer = values.duration;
                }
            }
        }
    }

    private function getPowerTarget(target:String, range:Float = 0):Unit {
        if(target == "self") {
            return unit;
        } else if(target == "randomAlly") {
            var targetUnits:Array<Unit>;
            if(unit.type == UnitType.HERO) {
                targetUnits = unit.map.getHeroesInRange(unit.x, unit.y, range);
            } else {
                targetUnits = unit.map.getMonstersInRange(unit.x, unit.y, range);
            }
            return targetUnits[Math.floor(Math.random() * targetUnits.length)];
        } else if(target == "randomEnemy") {
            var targetUnits:Array<Unit>;
            if(unit.type == UnitType.HERO) {
                targetUnits = unit.map.getMonstersInRange(unit.x, unit.y, range);
            } else {
                targetUnits = unit.map.getHeroesInRange(unit.x, unit.y, range);
            }
            return targetUnits[Math.floor(Math.random() * targetUnits.length)];
        }
        return null;
    }

}