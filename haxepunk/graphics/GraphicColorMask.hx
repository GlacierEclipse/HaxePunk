package haxepunk.graphics;

import haxepunk.tweens.misc.NumTween;
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
    private var alphaTween:NumTween;
    private var entity:Entity;
    private var maskAlpha:Float;
    //private var graphic:Graphic;

    public function new(entity:Entity) 
    {
        alphaTween = new NumTween(TweenType.Persist);
        

        this.entity = entity;

        

        entity.addTween(alphaTween, false);
    }

    public function startMask(duration:Float, color:Color = 0xFF0000)
    {
        entity.graphic.maskColor = color;
        if(duration != alphaTween.tweenDuration)
            alphaTween.tween(1.0, 0.0, duration);
        alphaTween.start();
    }

    public function startMaskOnce(duration:Float, color:Color = 0xFF0000)
    {
        if(alphaTween.active)
            return;
        entity.graphic.maskColor = color;
        if(duration != alphaTween.tweenDuration)
            alphaTween.tween(1.0, 0.0, duration);
        alphaTween.start();
    }

    public function update() 
    {
        entity.graphic.maskAlpha = alphaTween.value;
    }

    
}