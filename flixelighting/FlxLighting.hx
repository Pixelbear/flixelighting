package flixelighting;

import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import flixel.util.FlxColor;

typedef LightRef =
{
	@optional var identifier:Int;
	@optional var light:FlxLight;
}

/**
 * Class for the creation of a Lighting object that handles the interfacing with the embedded lighting fragment shader
 * @author George Baron
 */
class FlxLighting extends Shader
{
	
	@fragment var fragment = "
	
	//Lights
	uniform mat4 light0;
	uniform mat4 light1;
	uniform mat4 light2;
	uniform mat4 light3;
	uniform mat4 light4;
	uniform mat4 light5;
	uniform mat4 light6;
	uniform mat4 light7;

	//Ambient
	uniform vec3 ambient;
	uniform float ambientIntensity;
	
	//Normal map
	uniform sampler2D normalMap;
	
	//Resolution
	uniform vec2 resolution;

	vec2 genTexCoords()
	{
		vec2 RESCALE = ${Shader.uTextureSize} / ${Shader.uObjectSize};
		return ${Shader.vTexCoord} * RESCALE;
	}
	
	vec3 calcLight(mat4 light, vec3 N)
	{
		if (light[0].w == 0.0)
			return vec3(0.0);
		
		//Distance calculations
		vec3 deltaPos = vec3((light[0].xy - gl_FragCoord.xy) / resolution, light[0].z);
		vec3 lightDir = normalize(deltaPos);
		float lambert = clamp(dot(N, lightDir), 0.0, 1.0);
		
		//Attenuation (aka light falloff)
		float d = sqrt(dot(deltaPos, deltaPos));
		float att = 1.0 / (light[2].x + (light[2].y * d) + (light[2].z * pow(d, 2)));
		
		//TODO: blur edges of spotlights
		if (light[3].z > 0.0)
		{
			float fragAngle = degrees(acos(dot(-lightDir, normalize(vec3((light[3].xy - gl_FragCoord.xy) / resolution, 0.0)))));
			
			if (fragAngle > light[3].z)
				att = 0.0;
		}
		
		//Finalising light colour
		return light[1].rgb * lambert * att * light[0].w;
	}

	void main()
	{
		vec4 original = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
		vec4 normal = texture2D(normalMap, genTexCoords());
		
		if (normal.rgb == vec3(0.0))
		{
			gl_FragColor = original;
			return;
		}
		
		//Flipping the y component
		normal.g = 1.0 - normal.g;
		
		//Normalising and fitting normals to range [0...1]
		vec3 N = normalize(normal.rgb * 2.0 - 1.0);
		
		//Combining all of the lights
		float denom = ceil(light0[0].w) + ceil(light1[0].w) + ceil(light2[0].w) + ceil(light3[0].w)
				    + ceil(light4[0].w) + ceil(light5[0].w) + ceil(light6[0].w) + ceil(light7[0].w);
		
		vec3 av = calcLight(light0, N)
				+ calcLight(light1, N)
				+ calcLight(light2, N)
				+ calcLight(light3, N)
				+ calcLight(light4, N)
				+ calcLight(light5, N)
				+ calcLight(light6, N)
				+ calcLight(light7, N);
		
		av /= denom;
		
		vec3 composite = original.rgb * (ambient * ambientIntensity) + clamp(av, 0, 1);
		
		gl_FragColor = vec4(composite, 1.0);
	}
	
	";
	
	private var lights:Array<LightRef>;
	private var u_ambient:Array<Float>;
	private var u_ambientIntensity:Float;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		super();
		
		u_ambient = [0.0, 0.0, 0.0, 1.0];
		u_ambientIntensity = 0.25;
		
		updateUniforms();
		
		lights = [for (i in 0...8) { identifier: i, light: null }];
	}
	
	/**
	 * Mutator method for setting the color and intensity of the ambient light
	 * @param	Color	The color of the ambient light
	 * @param	Intensity	The intensity of the ambient light
	 */
	public function setAmbient(Color:Int = FlxColor.BLACK, ?Intensity:Float = 1.0):Void
	{
		var c:FlxColor = FlxColor.fromInt(Color);
		u_ambient = [c.redFloat, c.greenFloat, c.blueFloat];
		u_ambientIntensity = Intensity;
		
		updateUniforms();
	}
	
	private function updateUniforms():Void
	{
		this.ambient = u_ambient;
		this.ambientIntensity = u_ambientIntensity;
	}
	
	/**
	 * Method for adding a normal map to the lighting calculations
	 * NOTE: A normal map MUST be added for the lighting to function
	 * @param	normalMap	The normal map to be used in calculations
	 */
	public function addNormalMap(normalMap:FlxNormalMap):Void
	{
		this.resolution = [normalMap.data.width, normalMap.data.height];
		this.normalMap = normalMap.data;
	}
	
	/**
	 * Method for adding a light to the lighting calculations
	 * NOTE: A max of 8 lights can be added!
	 * @param	light	The light to be used in calculations
	 */
	public function addLight(light:FlxLight):Void
	{
		for (i in 0...lights.length)
		{
			if (lights[i].light == null)
			{
				lights[i].light = light;
				passInto(lights[i].identifier, light);
				break;
			}
			else if (i == lights.length - 1)
				trace("Error: You can only add a maximum of 8 lights to the scene!");
		}
	}
	
	/**
	 * Method for removing a light from the lighting calculations
	 * @param	light	The light to be removed from the lighting calculations
	 */
	public function removeLight(light:FlxLight):Void
	{
		for (i in 0...lights.length)
		{
			if (lights[i].light == light)
			{
				lights[i].light = null;
				passInto(lights[i].identifier, new FlxLight(0.0, 0.0, 0.0, 0.0));
				break;
			}
		}
	}
	
	/**
	 * Method used to recalculate the lighting
	 */
	public function update():Void
	{
		for (i in 0...lights.length)
		{
			if (lights[i].light != null)
				passInto(lights[i].identifier, lights[i].light);
		}
	}
	
	/**
	 * Returns a ShaderFilter object to be added to a camera's list of filters
	 * @return	A ShaderFilter object to be added to a camera's list of filters
	 */
	public function getFilter():ShaderFilter
	{
		return new ShaderFilter(this);
	}
	
	private function passInto(identifier:Int, l:FlxLight):Void
	{
		switch (identifier)
		{
			case 0: this.light0 = l.getMatrix();
			case 1: this.light1 = l.getMatrix();
			case 2: this.light2 = l.getMatrix();
			case 3: this.light3 = l.getMatrix();
			case 4: this.light4 = l.getMatrix();
			case 5: this.light5 = l.getMatrix();
			case 6: this.light6 = l.getMatrix();
			case 7: this.light7 = l.getMatrix();
		}
	}
	
}