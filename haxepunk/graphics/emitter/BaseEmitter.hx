package haxepunk.graphics.emitter;

import haxepunk.utils.BlendMode;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.utils.Color;
import haxepunk.utils.Ease.EaseFunction;
import haxepunk.math.MathUtil;
import haxepunk.math.Random;
import haxepunk.math.Vector2;

@:generic class BaseEmitter<T:Graphic> extends Graphic
{
	/**
	 * Amount of currently existing particles.
	 */
	public var particleCount(default, null):Int;

	public var scale:Float = 1;

	function new(source:T)
	{
		super();
		_source = source;
		_sourceIsImage = Std.is(_source, Image);
		_types = new Map<String, ParticleType>();
		active = true;
		particleCount = 0;
	}

	override public function render(point:Vector2, camera:Camera)
	{
		var p:Particle = _particle;

		var t:Float,
			pt:Float,
			type:ParticleType,
			td:Float,
			atd:Float,
			std:Float,
			rtd:Float,
			ctd:Float;

		// loop through the particles
		while (p != null)
		{
			// get time scale
			t = p._time / p._duration;
			if (p._firstDraw)
			{
				p._ox = point.x;
				p._oy = point.y;
				p._firstDraw = false;
			}

			// get particle type
			type = p._type;

			_source.smooth = smooth;
			_source.flexibleLayer = flexibleLayer;
			_source.pixelSnapping = pixelSnapping;
			_source.blend = type._blendMode == null ? this.blend : type._blendMode;

			var n:Int = type._trailLength;
			while (n >= 0)
			{
				pt = p._time - (n--) * type._trailDelay;
				t = pt / p._duration;
				if (t < 0 || pt >= p._stopTime) continue;
				td = type._ease != null ? type._ease(t) : t;
				updateParticle(p, td);
				ctd = type._colorEase != null ? type._colorEase(t) : t;
				_source.color = p.color(ctd);
				atd = type._alphaEase != null ? type._alphaEase(t) : t;
				_source.alpha = p.alpha(atd) * Math.pow(type._trailAlpha, n);
				if (_sourceIsImage)
				{
					var _source:Image = cast _source;
					rtd = type._rotationEase != null ? type._rotationEase(t) : t;
					_source.angle = p.angle(rtd);
					std = type._scaleEase != null ? type._scaleEase(t) : t;
					_source.scale = scale * p.scale(std);
				}
				_source.x = p.x(td) - point.x + this.x - originX;
				_source.y = p.y(td) - point.y + this.y - originY;
				_source.render(point, camera);
			}

			// get next particle
			p = p._next;
		}
	}

	function updateParticle(p:Particle, td:Float) {}

	override public function update()
	{
		// quit if there are no particles
		if (_particle == null) return;

		// particle info
		var p:Particle = _particle,
			n:Particle;

		// loop through the particles
		while (p != null)
		{
			p._time += HXP.elapsed; // Update particle time elapsed

			var type = p._type;
			var t = p._time / p._duration;

			if (p._time - (type._trailLength * type._trailDelay) >= p._stopTime)
			{
				if (p._next != null) p._next._prev = p._prev;
				if (p._prev != null) p._prev._next = p._next;
				else _particle = p._next;
				n = p._next;
				p._next = _cache;
				p._prev = null;
				_cache = p;
				p = n;
				particleCount--;
				continue;
			}

			// get next particle
			p = p._next;
		}
	}

	/**
	 * Clears all particles.
	 * @since	2.5.2
	 */
	public function clear()
	{
		// quit if there are no particles
		if (_particle == null)
		{
			return;
		}

		// particle info
		var p:Particle = _particle,
			n:Particle;

		// loop through the particles
		while (p != null)
		{
			// move this particle to the cache
			n = p._next;
			p._next = _cache;
			p._prev = null;
			_cache = p;
			p = n;
			particleCount--;
		}

		_particle = null;
	}

	/**
	 *  Resets originX/Y to 0 since there are no dimensions.
	 */
	override public function centerOrigin():Void
	{
		originX = originY = 0;
	}

	public function getType(name:String):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		return pt;
	}

	public function isTypeExists(name:String):Bool
	{
		var pt:ParticleType = _types.get(name);
		if (pt != null)
			return true;
		return false;
	}

	/**
	 * Creates a new Particle type for this Emitter.
	 * @param	name		Name of the particle type.
	 * @param	frames		Array of frame indices for the particles to animate.
	 * @return	A new ParticleType object.
	 */
	function addType(name:String, ?blendMode:BlendMode):ParticleType
	{
		if (blendMode == null) blendMode = this.blend;
		var pt:ParticleType = _types.get(name);

		if (pt != null)
			throw "Cannot add multiple particle types of the same name";

		pt = new ParticleType(name, blendMode);
		_types.set(name, pt);

		return pt;
	}

	/**
	 * Emits a particle.
	 * @param	name		Particle type to emit.
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @param	angle		Base angle to start from.
	 * @return	The Particle emited.
	 */
	public function emit(name:String, x:Float = 0, y:Float = 0, angle:Float = 0):Particle
	{
		var p:Particle, type:ParticleType = _types.get(name);

		if (type == null)
			throw "Particle type \"" + name + "\" does not exist.";

		if (_cache != null)
		{
			p = _cache;
			_cache = p._next;
		}
		else
		{
			p = new Particle();
		}
		p._next = _particle;
		p._prev = null;
		if (p._next != null) p._next._prev = p;

		p._type = type;
		p._scale = type._scale + type._scaleRange * Random.random;
		p._scaleRange = (type._scaleFinish - p._scale);
		p._time = 0;
		p._duration = type._duration + type._durationRange * Random.random;
		p._stopTime = p._duration;
		p._angle = angle + type._angle + type._angleRange * Random.random;
		p._startAngle = type._startAngle + type._startAngleRange * Random.random;
		p._spanAngle = type._spanAngle + type._spanAngleRange * Random.random;
		var d:Float = type._distance + type._distanceRange * Random.random;
		p._moveX = Math.cos(p._angle * MathUtil.RAD) * d;
		p._moveY = Math.sin(p._angle * MathUtil.RAD) * d;
		p._x = x;
		p._y = y;
		p._gravity = type._gravity + type._gravityRange * Random.random;
		p._firstDraw = true;
		p._ox = p._oy = 0;
		particleCount++;
		return (_particle = p);
	}

	/**
	 * Emits a particle.
	 * @param	name			Particle type to emit.
	 * @param	amount			Amount of particles to emit.
	 * @param	x				X point to emit from.
	 * @param	y				Y point to emit from.
	 * @param	angle			Base angle to start from.
	 * @param	outParticles	Array of particles to push the new emitted ones.
	 * @return	The Particle emited.
	 */
	public function emitAmount(name:String, amount:Int, x:Float = 0, y:Float = 0, angle:Float = 0, ?outParticles:Array<Particle>):Void
	{
		for (i in 0...amount)
		{
			var particle = emit(name, x, y, angle);
			if(outParticles != null)
				outParticles.push(particle);
		}
	}

	/**
	 * Randomly emits the particle inside the specified radius
	 * @param	name		Particle type to emit.
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @param	radius		Radius to emit inside.
	 *
	 * @return The Particle emited.
	 */
	public function emitInCircle(name:String, x:Float, y:Float, radius:Float):Particle
	{
		var angle = Random.random * Math.PI * 2;
		radius *= Random.random;
		return emit(name, x + Math.cos(angle) * radius, y + Math.sin(angle) * radius);
	}

	/**
	 * Randomly emits the particle inside the specified radius
	 * @param	name		Particle type to emit.
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @param	radius		Radius to emit inside.
	 * @param	amount			Amount of particles to emit.
	 * @param	outParticles	Array of particles to push the new emitted ones.
	 *
	 * @return The Particle emited.
	 */
	 public function emitInCircleAmount(name:String, x:Float, y:Float, radius:Float, amount:Int, ?outParticles:Array<Particle>):Void
	{
		for (i in 0...amount)
		{
			var particle = emitInCircle(name, x, y, radius);
			if(outParticles != null)
				outParticles.push(particle);
		}
	}

	/**
	 * Randomly emits the particle inside the specified area
	 * @param	name		Particle type to emit
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @param	width		Width of the area to emit from.
	 * @param	height		height of the area to emit from.
	 *
	 * @return The Particle emited.
	 */
	public function emitInRectangle(name:String, x:Float, y:Float, width:Float, height:Float):Particle
	{
		return emit(name, x + Random.random * width, y + Random.random * height);
	}

	/**
	 * Randomly emits the particle inside the specified area
	 * @param	name			Particle type to emit
	 * @param	x				X point to emit from.
	 * @param	y				Y point to emit from.
	 * @param	width			Width of the area to emit from.
	 * @param	height			height of the area to emit from.
	 * @param	amount			Amount of particles to emit.
	 * @param	outParticles	Array of particles to push the new emitted ones.
	 *
	 * @return The Particle emited.
	 */
	public function emitInRectangleAmount(name:String, x:Float, y:Float, width:Float, height:Float, amount:Int, ?outParticles:Array<Particle>):Void
	{
		for (i in 0...amount)
		{
			var particle = emitInRectangle(name, x, y, width, height);
			if(outParticles != null)
				outParticles.push(particle);
		}
	}

	/**
	 * Defines the motion range for a particle type.
	 * @param	name			The particle type.
	 * @param	angle			Launch Direction.
	 * @param	distance		Distance to travel.
	 * @param	duration		Particle duration.
	 * @param	angleRange		Random amount to add to the particle's direction.
	 * @param	distanceRange	Random amount to add to the particle's distance.
	 * @param	durationRange	Random amount to add to the particle's duration.
	 * @param	ease			Optional ease function.
	 * @param	backwards		If the motion should be played backwards.
	 * @return	This ParticleType object.
	 */
	public function setMotion(name:String, angle:Float, distance:Float, duration:Float, angleRange:Float = 0, distanceRange:Float = 0, durationRange:Float = 0, ?ease:EaseFunction, backwards:Bool = false):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setMotion(angle, distance, duration, angleRange, distanceRange, durationRange, ease, backwards);
	}

	/**
	 * Sets the gravity range for a particle type.
	 * @param	name      		The particle type.
	 * @param	gravity      	Gravity amount to affect to the particle y velocity.
	 * @param	gravityRange	Random amount to add to the particle's gravity.
	 * @return	This ParticleType object.
	 */
	public function setGravity(name:String, ?gravity:Float = 0, ?gravityRange:Float = 0):ParticleType
	{
		return _types.get(name).setGravity(gravity, gravityRange);
	}

	/**
	 * Sets the alpha range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting alpha.
	 * @param	finish		The finish alpha.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setAlpha(name:String, start:Float = 1, finish:Float = 0, ?ease:EaseFunction):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setAlpha(start, finish, ease);
	}

	/**
	 * Sets the scale range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting scale.
	 * @param	finish		The finish scale.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 * @since	2.6.0
	 */
	public function setScale(name:String, start:Float = 1, finish:Float = 0, ?ease:EaseFunction):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setScale(start, finish, ease);
	}

	/**
	 * Defines the rotation range for a particle type.
	 * @param	name	The particle type.
	 * @param	startAngle	Starting angle.
	 * @param	spanAngle	Total amount of degrees to rotate.
	 * @param	startAngleRange	Random amount to add to the particle's starting angle.
	 * @param	spanAngleRange	Random amount to add to the particle's span angle.
	 * @param	ease	Optional easer function.
	 * @since	2.6.0
	 * @return	This ParticleType object.
	 */
	public function setRotation(name:String, startAngle:Float, spanAngle:Float, startAngleRange:Float = 0, spanAngleRange:Float = 0, ?ease:EaseFunction):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setRotation(startAngle, spanAngle, startAngleRange, spanAngleRange, ease);
	}

	/**
	 * Sets the trail of the particle type.
	 * @param	name		The particle type.
	 * @param	length		Number of trailing particles to draw.
	 * @param	delay		Time to delay each trailing particle, in seconds.
	 * @param	alpha		Multiply each successive trail particle's alpha by this amount.
	 * @since	2.6.0
	 * @return	This ParticleType object.
	 */
	public function setTrail(name:String, length:Int = 1, delay:Float = 0.1, alpha:Float=1):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setTrail(length, delay, alpha);
	}

	/**
	 * Sets the color range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting color.
	 * @param	finish		The finish color.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setColor(name:String, start:Color = Color.White, finish:Color = Color.Black, ?ease:EaseFunction):ParticleType
	{
		var pt:ParticleType = _types.get(name);
		if (pt == null) return null;
		return pt.setColor(start, finish, ease);
	}

	// Particle information.
	var _source:T;
	var _sourceIsImage:Bool;
	var _types:Map<String, ParticleType>;
	var _particle:Particle;
	var _cache:Particle;
}
