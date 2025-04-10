package haxepunk.graphics.atlas;

import haxepunk.utils.BlendMode;
import haxepunk.graphics.atlas.AtlasData;
import haxepunk.graphics.shader.Shader;
import haxepunk.math.Rectangle;
import haxepunk.utils.Color;

class Atlas
{
	/**
	 * The width of this atlas
	 */
	public var width(get, never):Int;
	function get_width():Int return _data.width;

	/**
	 * The height of this atlas
	 */
	public var height(get, never):Int;
	function get_height():Int return _data.height;

	function new(?source:AtlasDataType)
	{
		_data = source;
	}

	/**
	 * Loads an image and returns the full image as a region
	 * @param	source	The image to use
	 * @return	An AtlasRegion containing the whole image
	 */
	public static function loadImageAsRegion(source:AtlasDataType):AtlasRegion
	{
		var data:AtlasData = source;
		return data.createRegion(new Rectangle(0, 0, data.width, data.height));
	}

	/**
	 * Prepares tile data for rendering
	 * @param  	rect   	The source rectangle to draw
	 * @param	x		The x-axis location to draw the tile
	 * @param	y		The y-axis location to draw the tile
	 * @param	scaleX	The scale value for the x-axis
	 * @param	scaleY	The scale value for the y-axis
	 * @param	angle	An angle to rotate the tile
	 * @param	red		A red tint value
	 * @param	green	A green tint value
	 * @param	blue	A blue tint value
	 * @param	alpha	The tile's opacity
	 */
	public inline function prepareTile(rect:Rectangle, x:Float, y:Float,
		scaleX:Float, scaleY:Float, angle:Float,
		color:Color, alpha:Float, maskColor:Color, maskAlpha:Float,
		shader:Shader, smooth:Bool, blend:BlendMode, ?clipRect:Rectangle)
	{
		_data.prepareTile(rect, x, y, scaleX, scaleY, angle, color, alpha, maskColor, maskAlpha, shader, smooth, blend, clipRect);
	}

	/**
	 * How many Atlases are active.
	 */
	// public static var count(get, never):Int;
	// static inline function get_count():Int return _atlases.length;

	var _data:AtlasData;
}
