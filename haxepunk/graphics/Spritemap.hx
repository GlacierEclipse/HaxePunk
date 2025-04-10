package haxepunk.graphics;

import haxe.ds.Either;
import haxepunk.HXP;
import haxepunk.Graphic;
import haxepunk.Signal;
import haxepunk.ds.Maybe;
import haxepunk.graphics.atlas.TileAtlas;
import haxepunk.math.Random;
import haxepunk.math.Rectangle;

@:allow(haxepunk.graphics.Spritemap)
class Animation
{
	public var onComplete:Signal0 = new Signal0();
	public var name:String;

	var frames:Array<Int>;
	var frameRate:Float;
	var frameCount:Int;
	var loop:Bool;
	var parent:Spritemap;

	function new(parent:Spritemap, frames:Array<Int>, frameRate:Float, loop:Bool, name:String="")
	{
		this.name = name;
		this.frames = frames;
		this.frameRate = (frameRate == 0 ? HXP.assignedFrameRate : frameRate);
		this.frameCount = this.frames.length;
		this.loop = loop;
		this.name = name;
	}

	public function play(reset:Bool = false, reverse:Bool = false)
	{
		parent.playAnimation(this, reset, reverse);
	}

	public inline function getFirstFrame(reverse:Bool):Int
	{
		return reverse ? 0 : this.frameCount - 1;
	}

	public inline function getLastFrame(reverse:Bool):Int
	{
		return reverse ? this.frameCount - 1 : 0;
	}
}

/**
 * Performance-optimized animated Image. Can have multiple animations,
 * which draw frames from the provided source image to the screen.
 */
class Spritemap extends Image
{
	/**
	 * If the animation has stopped.
	 */
	public var complete:Bool = true;

	/**
	 * Callback function for animation end.
	 */
	public var onAnimationComplete:Signal1<Animation> = new Signal1();

	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float = 1;

	/**
	 * If the animation is played in reverse.
	 */
	public var reverse:Bool = false;

	/**
	 * The currently playing animation.
	 */
	public var currentAnimation(default, null):Maybe<Animation>;

	/**
	 * The amount of frames in the Spritemap.
	 */
	public var frameCount(get, null):Int;
	private function get_frameCount():Int return _frameCount;

	/**
	 * Columns in the Spritemap.
	 */
	public var columns(get, null):Int;
	private function get_columns():Int return _columns;

	/**
	 * Rows in the Spritemap.
	 */
	public var rows(get, null):Int;
	private function get_rows():Int return _rows;

	/**
	 * The source image.
	 */
	public var sourceSpriteImage(get, null):TileType;
	private function get_sourceSpriteImage():TileType return _sourceSpriteImage;

	/**
	 * Constructor.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(source:TileType, frameWidth:Int = 0, frameHeight:Int = 0, frameSpacingX:Int = 0, frameSpacingY:Int = 0)
	{
		_anims = new Map();

		super();

		_atlas = source;

		if (frameWidth > _atlas.width || frameHeight > _atlas.height)
		{
			throw "Frame width and height can't be bigger than the source image dimension.";
		}

		_atlas.prepare(
			frameWidth == 0 ? Std.int(_atlas.width) : frameWidth,
			frameHeight == 0 ? Std.int(_atlas.height) : frameHeight,
			frameSpacingX,
			frameSpacingY,
			0,
			0
		);

		_columns = Math.ceil(_atlas.width / frameWidth);
		_rows = Math.ceil(_atlas.height / frameHeight);
		_frameCount = _columns * _rows;
		frame = 0;
		active = true;
		_sourceImage = cast source;
	}

	/** @private Updates the animation. */
	@:dox(hide)
	override public function update()
	{
		currentAnimation.may(function(anim) {
			var original = currentAnimation;
			if (complete) return;

			_timer += HXP.elapsed * anim.frameRate * rate;
			if (_timer < 1) return;

			while (_timer >= 1)
			{
				_timer--;
				_index += reverse ? -1 : 1;

				if (_index < 0 || _index >= anim.frameCount)
				{
					if (anim.loop)
					{
						_index = anim.getLastFrame(reverse);
						anim.onComplete.invoke();
						onAnimationComplete.invoke(anim);
					}
					else
					{
						_index = anim.getFirstFrame(reverse);
						anim.onComplete.invoke();
						complete = true;
						onAnimationComplete.invoke(anim);
						break;
					}
				}
			}
			if (!complete && currentAnimation == original) frame = Std.int(anim.frames[_index]);
		});
	}

	/**
	 * Add an Animation.
	 * @param	name		Name of the animation.
	 * @param	frames		Array of frame indices to animate through.
	 * @param	frameRate	Animation speed (in frames per second, 0 defaults to assigned frame rate)
	 * @param	loop		If the animation should loop
	 * @return	A new Anim object for the animation.
	 */
	public function add(name:String, frames:Array<Int>, frameRate:Float = 0, loop:Bool = true):Animation
	{
		if (_anims.exists(name))
		{
			throw "Cannot have multiple animations with the same name";
		}

		// make sure frames are valid
		var anim = new Animation(this, frames, frameRate, loop, name);
		_anims.set(name, anim);
		return anim;
	}

	/**
	 * Check if Animation Exists with passed in name.
	 * @param	name		Name of the animation.
	 * @return	Has Animation or Not
	 */
	public function exists(name:String):Bool
	{
		return _anims.exists(name);
	}

	/**
	 * Removes Existing Animation.
	 * @param	name		Name of the animation.
	 * @return	if Animation Has Been Removed
	 */
	public function remove(name:String):Bool
	{
		if (!_anims.exists(name))
		{
			return false;
		}
		_anims.remove(name);
		return true;
	}

	/**
	 * Plays an animation previous defined by add().
	 * @param	name		Name of the animation to play.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 * @param	reverse		If the animation should be played backward.
	 * @return	Anim object representing the played animation.
	 */
	public function play(name:String = "", reset:Bool = false, reverse:Bool = false):Animation
	{
		if (!_anims.exists(name))
		{
			stop(reset);
			return null;
		}

		return playAnimation(_anims.get(name), reset, reverse);
	}

	/**
	 * Plays a new ad hoc animation.
	 * @param	frames		Array of frame indices to animate through.
	 * @param	frameRate	Animation speed (in frames per second, 0 defaults to assigned frame rate)
	 * @param	loop		If the animation should loop
	 * @param	reset		When the supplied frames are currently playing, should the animation be force-restarted
	 * @param	reverse		If the animation should be played backward.
	 * @return	Anim object representing the played animation.
	 */
	public function playFrames(frames:Array<Int>, frameRate:Float = 0, loop:Bool = true, reset:Bool = false, reverse:Bool = false):Animation
	{
		if (frames == null || frames.length == 0)
		{
			stop(reset);
			return null;
		}

		return playAnimation(new Animation(this, frames, frameRate, loop), reset, reverse);
	}

	/**
	 * Plays or restarts the supplied Animation.
	 * @param	animation	The Animation object to play
	 * @param	reset		When the supplied animation is currently playing, should it be force-restarted
	 * @param	reverse		If the animation should be played backward.
	 * @return	Animation object representing the played animation.
	 */
	public function playAnimation(anim:Animation, reset:Bool = false, reverse:Bool = false): Animation
	{
		reset = reset || (currentAnimation != anim);
		currentAnimation = anim;
		this.reverse = reverse;
		if (reset) restart();

		return anim;
	}

	/**
	 * Resets the animation to play from the beginning.
	 */
	public function restart()
	{
		_timer = 0;
		currentAnimation.may(function(anim) {
			_index = anim.getLastFrame(reverse);
			frame = anim.frames[_index];
		});
		complete = false;
	}

	/**
	 * Immediately stops the currently playing animation.
	 * @param	reset		If true, resets the animation to the first frame.
	 */
	public function stop(reset:Bool = false)
	{
		if (reset)
		{
			frame = _index = currentAnimation.map(function(a) return a.getLastFrame(reverse), 0);
		}

		currentAnimation = null;
		complete = true;
	}

	/**
	 * Assigns the Spritemap to a random frame.
	 */
	public function randFrame()
	{
		frame = Random.randInt(_atlas.tileCount);
	}

	/**
	 * Sets the frame to the frame index of an animation.
	 * @param	name	Animation to draw the frame frame.
	 * @param	index	Index of the frame of the animation to set to.
	 */
	public function setAnimFrame(name:String, index:Int)
	{
		if (_anims.exists(name))
		{
			var anim = _anims.get(name);
			index = Std.int(Math.abs(index)) % anim.frameCount;
			frame = anim.frames[index];
		}
	}

	/**
	 * Gets the frame index based on the column and row of the source image.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 * @return	Frame index.
	 */
	public inline function getFrameColRow(column:Int = 0, row:Int = 0):Int
	{
		return (row % _rows) * _columns + (column % _columns);
	}

	/**
	 * Sets the current display frame based on the column and row of the source image.
	 * When you set the frame, any animations playing will be stopped to force the frame.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 */
	public function setFrameColRow(column:Int = 0, row:Int = 0)
	{
		currentAnimation = null;
		var frameFromPos:Int = getFrameColRow(column, row);
		if (frameFromPos == frame) return;
		set_frame(frameFromPos);
	}

	/**
	 * Sets the current frame index.
	 */
	public var frame(default, set):Int = -1;
	function set_frame(value:Int):Int
	{
		value = Std.int(Math.abs(value)) % _atlas.tileCount;
		if (frame != value)
		{
			_region = _atlas.getRegion(value);
			_sourceRect.width = _region.width;
			_sourceRect.height = _region.height;
		}
		return frame = value;
	}

	/**
	 * Current index of the playing animation.
	 */
	public var index(get, set):Int;
	function get_index():Int return currentAnimation.exists() ? _index : 0;
	function set_index(value:Int):Int
	{
		return currentAnimation.map(function(anim) {
			value %= anim.frameCount;
			if (_index == value) return _index;
			frame = anim.frames[value];
			return _index = value;
		}, 0);
	}

	// Spritemap information.
	var _anims:Map<String, Animation>;
	var _index:Int;
	var _timer:Float = 0;
	var _atlas:TileAtlas;
	var _columns:Int;
	var _rows:Int;
	var _frameCount:Int;
	var _sourceSpriteImage:TileType;
}
