package haxepunk.graphics.shader;

class ColorShader extends Shader
{
	static var VERTEX_SHADER =
"// HaxePunk color vertex shader
#ifdef GL_ES
precision mediump float;
#endif

attribute vec4 aPosition;
attribute vec4 aColor;
attribute vec4 aMaskColor;
varying vec4 vColor;
varying vec4 vMaskColor;
uniform mat4 uMatrix;

void main(void) {
	vColor = vec4(aColor.bgr * aColor.a, aColor.a);
	vMaskColor = vec4(aMaskColor.bgr * aMaskColor.a, aMaskColor.a);
	gl_Position = uMatrix * aPosition;
}";

	static var FRAGMENT_SHADER =
"// HaxePunk color fragment shader
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 vColor;
varying vec4 vMaskColor;

void main(void) {
	gl_FragColor = mix(vColor, vMaskColor, vColor.a * vMaskColor.a);
}";

	public function new(?fragment:String)
	{
		super(VERTEX_SHADER, fragment == null ? FRAGMENT_SHADER : fragment);
		position.name = "aPosition";
		color.name = "aColor";
		maskColor.name = "aMaskColor";
	}

	public static var defaultShader(get, null):ColorShader;
	static inline function get_defaultShader():ColorShader
	{
		if (defaultShader == null) defaultShader = new ColorShader();
		return defaultShader;
	}
}
