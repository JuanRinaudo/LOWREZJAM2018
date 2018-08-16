package game.data;

enum PowerType {
    GeneratePerSecond;
    RegenerateHealth;
    TempStatChange;
    HealUnit;
    CreateUnit;
}

typedef GeneratePerSecondValues = {
    public var classToModify:String;
    public var fieldToModify:String;
    public var genenerationAmmount:Float;
}

typedef RegenerateHealthValues = {
    public var target:String;
    public var healAmmount:Float;
}

typedef TempStatChangeValues = {
    public var target:String;
    public var stat:String;
    public var range:Float;
    public var value:Int;
    public var duration:Float;
    public var cooldown:Float;
}

typedef HealUnitValues = {
    public var target:String;
    public var range:Float;
    public var value:Float;
    public var cooldown:Float;
}