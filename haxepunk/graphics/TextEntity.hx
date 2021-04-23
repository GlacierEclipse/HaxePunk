package haxepunk.graphics;

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
        textBitmap = new BitmapText(initText);
        textBitmap.size = size;

        graphic = textBitmap;
    }

}