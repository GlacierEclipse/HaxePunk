package haxepunk.graphics.ui;

import haxepunk.math.MathUtil;
import haxepunk.math.Rectangle;

class UIBar extends Entity
{
    public var image:Image;
    public var imageFilled:Image;
    public var barWidth:Int;
    public var barHeight:Int;
    private var clipRect:Rectangle;

    // 0 - 100
    public var fill:Float;

    // The filled image should appear right below the empty one.
    public function new(srcString:String, barWidth:Int, barHeight:Int) 
    {
        super(0,0);
        this.barWidth = barWidth;
        this.barHeight = barHeight;
        
        clipRect = new Rectangle(0, 0, barWidth, barHeight);
        image = new Image(srcString, clipRect);
        clipRect = new Rectangle(0, barHeight, barWidth, barHeight);
        imageFilled = new Image(srcString, clipRect);
        graphic = image;
        addGraphic(imageFilled);
        
    }

    override function update() 
    {
        super.update();
        var clipWidth:Int = Std.int(MathUtil.scaleClamp(fill, 0, 100, 0, barWidth));
        clipRect.setTo(0, 0, clipWidth, barHeight);
    }
}