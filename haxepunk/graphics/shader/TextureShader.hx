package haxepunk.graphics.shader;

import haxepunk.assets.AssetLoader;

class TextureShader extends Shader
{
	static var VERTEX_SHADER =
"// HaxePunk texture vertex shader
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;
varying vec2 vTexCoord;
varying vec4 vColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	vTexCoord = aTexCoord;
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"// HaxePunk texture fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;
varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void) {
	vec4 color = texture2D(uImage0, vTexCoord);
	if (color.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor = color * vColor;
	}
}";

static var VERTEX_SHADER_COLORIZE =
"// HaxePunk texture vertex shader
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;
attribute float aMaskAlpha;

varying vec2 vTexCoord;
varying vec4 vColor;
varying float vMaskAlpha;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	vTexCoord = aTexCoord;
	vMaskAlpha = aMaskAlpha;
	gl_Position = uMatrix * aPosition;
}";

static var FRAGMENT_SHADER_COLORIZE =
"// HaxePunk texture fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;
varying vec2 vTexCoord;
varying float vMaskAlpha;

uniform sampler2D uImage0;

void main(void) {
	vec4 color = texture2D(uImage0, vTexCoord);
	if (color.a == 0.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor = mix(color * vColor, vColor, vMaskAlpha);
	}
}";

public static var defaultMaskAlphaAttribName:String = "aMaskAlpha";

	#if (lime || nme)
	/**
	 * Create a custom shader from a text asset.
	 */
	public static inline function fromAsset(name:String):TextureShader
	{
		return new TextureShader(null, AssetLoader.getText(name));
	}
	#end

	public function new(?vertex:String, ?fragment:String)
	{
		super(vertex == null ? VERTEX_SHADER : vertex, fragment == null ? FRAGMENT_SHADER : fragment);
		position.name = "aPosition";
		texCoord.name = "aTexCoord";
		color.name = "aColor";
		maskAlpha.name = "aMaskAlpha";
	}

	public static var defaultShader(get, null):TextureShader;
	static inline function get_defaultShader():TextureShader
	{
		//if (defaultShader == null) defaultShader = new TextureShader();
		//return defaultShader;

		if (defaultShader == null) 
			defaultShader = new TextureShader(VERTEX_SHADER_COLORIZE, FRAGMENT_SHADER_COLORIZE);
		return defaultShader;
	}

	public static var defaultColorizedShader(get, null):TextureShader;
	static inline function get_defaultColorizedShader():TextureShader
	{
		if (defaultColorizedShader == null) 
			defaultColorizedShader = new TextureShader(VERTEX_SHADER_COLORIZE, FRAGMENT_SHADER_COLORIZE);
		return defaultColorizedShader;
	}
}
