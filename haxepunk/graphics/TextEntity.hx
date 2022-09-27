package haxepunk.graphics;

import haxepunk.graphics.text.Text;
import haxepunk.graphics.text.BitmapText;

class TextEntity extends Entity
{
    public var initText(default, default):String;
    public var textBitmap:BitmapText;

    public var currentText(default, set):String;
    function set_currentText(value:String):String
    {
        if(textBitmap!=null)
            textBitmap.text = value;
        return currentText = value;
    }

    public function new(x:Float, y:Float, initText:String, size:Int = 12) 
    {
        super(x, y);

        currentText = this.initText = initText;
        

        textBitmap = new BitmapText(initText, 0, 0, 0, 0, {font: "font/04B_03__.ttf.png", format: XNA, extraParams: {glyphBGColor: 0xFF000000}});
        textBitmap.size = size;
        textBitmap.smooth = false;
        graphic = textBitmap;
        graphic.smooth = false;
    }

}