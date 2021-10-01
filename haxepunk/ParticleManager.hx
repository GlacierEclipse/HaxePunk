package haxepunk;

import haxepunk.graphics.emitter.ParticleType;
import haxepunk.graphics.emitter.Emitter;
import haxepunk.Entity;
/*
* A global manager that handles the Emitter instance. 
* To actually draw the particles, this class needs to be added manually to the scene.
*/

class ParticleManager extends Entity
{
	public static var particleEmitter(get, null):Emitter;
	private static function get_particleEmitter():Emitter
	{
		if (particleEmitter == null)
			throw "Call initParticleEmitter first";
		return particleEmitter;
	}

    public function new()
    {
        super(0, 0);
        graphic = ParticleManager.particleEmitter;
    }

	public static function initParticleEmitter(assetSource:String, frameWidth:Int, frameHeight:Int):Emitter
	{
		particleEmitter = new Emitter(assetSource, frameWidth, frameHeight);
		particleEmitter.relative = false;
		return particleEmitter;
	}

	public static function addType(type:String, ?frames:Array<Int>) : ParticleType
	{
		if (!particleEmitter.isTypeExists(type))
		{
			return particleEmitter.newType(type, frames);
		}
        return particleEmitter.getType(type);
	}
}
