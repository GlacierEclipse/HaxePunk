package haxepunk.math;

class MinMaxValue
{
    public var minValue:Float;
    public var maxValue:Float;
    public var currentValue:Float;
    public var rate:Float;

    public function new(minVal:Float, maxVal:Float, currentVal:Float, rate:Float) 
    {
        minValue = minVal;
        maxValue = maxVal;
        currentValue = currentVal;
        this.rate = rate;
    }

    public function initToMin() 
    {
        currentValue = minValue;
    }
    
    public function initToMax() 
    {
        currentValue = maxValue;
    }

    public function clamp() 
    {
        currentValue = MathUtil.clamp(currentValue , minValue, maxValue);
    }
}