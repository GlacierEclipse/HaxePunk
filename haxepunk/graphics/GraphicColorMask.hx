package haxepunk.graphics;

import haxepunk.graphics.shader.TextureShader;
import haxepunk.tweens.misc.MultiVarTween;
import haxepunk.utils.Color;
import haxepunk.Tween.TweenType;


enum GraphicTypes
{
    Image; 
    Spritemap;
}

// A tweenable color mask that can be used for hit/pick up effects. 
class GraphicColorMask 
{
    private var alphaTween:MultiVarTween;
    private var entity:Entity;
    private var graphic:Graphic;

    public function new(entity:Entity) 
    {
        alphaTween = new MultiVarTween(TweenType.Persist);
        

        this.entity = entity;

        entity.addTween(alphaTween, false);
    }

    public function initAndAddGraphic(graphicType:GraphicTypes, sourcePath:String) 
    {
        if(graphicType == GraphicTypes.Image)
            graphic = new Image(sourcePath, cast(entity.graphic, Image).clipRect);
        else if(graphicType == GraphicTypes.Spritemap)
            graphic = new Spritemap(sourcePath, cast(entity.graphic, Spritemap).width, cast(entity.graphic, Spritemap).height);

        graphic.shader = TextureShader.defaultColorizedShader;
        entity.addGraphic(graphic);
        alphaTween.tween(graphic, {alpha: 0.0}, 1.0);

        graphic.alpha = 0.0;
    }

    public function startMask(duration:Float, color:Color = 0xFF0000)
    {
        graphic.color = color;
        if(duration != alphaTween.tweenDuration)
            alphaTween.initTween(duration);
        alphaTween.start();
    }

    public function update() 
    {
        
    }

    
}