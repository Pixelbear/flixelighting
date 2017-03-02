package flixelighting;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.Lib;

private typedef Spotlight =
{
	var width:Float;
	var target:FlxPoint;
}

private typedef Attenuation =
{
	var constant:Float;
	var linear:Float;
	var quadratic:Float;
}

/**
 * Class for the creation of a light object to be passed into a Lighting object
 * @author George Baron
 */
class FlxLight extends FlxSprite
{
	
	/**
	 * The z-position of the light
	 */
	public var z:Float;
	/**
	 * The intensity of the light from 0.0 - 1.0 (Gets clamped between these values otherwise)
	 */
	public var intensity:Float;
	/**
	 * The color of the light
	 */
	public var lightColor:Int;
	
	private var attenuation:Attenuation;
	private var spotlight:Spotlight;
	
	/**
	 * Constructor
	 * @param	X	The x-position of the light
	 * @param	Y	The y-position of the light
	 * @param	Z	The z-position of the light
	 * @param	Intensity	The intensity of the light from 0.0 - 1.0 (Gets clamped between these values otherwise)
	 * @param	Color	The color of the light
	 */
	public function new(?X:Float=0, ?Y:Float=0, ?Z:Float=0, ?Intensity:Float=1, ?Color:Int=FlxColor.WHITE) 
	{
		super(X, Y);
		
		z = Z;
		intensity = Intensity;
		lightColor = Color;
		attenuation = { constant: 0.4, linear: 3.0, quadratic: 20.0 };
		spotlight = { width: 0.0, target: new FlxPoint(0.0, 0.0) };
		
		makeGraphic(10, 10, FlxColor.TRANSPARENT);
	}
	
	/**
	 * Convert the light into a spotlight
	 * @param	Width	The width of the spotlight
	 * @param	TargetX	The target's x-position
	 * @param	TargetY	The target's y-position
	 */
	public function makeSpotlight(Width:Float, TargetX:Float, TargetY:Float):Void
	{
		spotlight.width = Width;
		spotlight.target.set(TargetX, TargetY);
	}
	
	/**
	 * Sets the target of the spotlight (if the light isn't a spotlight, this will do nothing)
	 * @param	TargetX	The target's x-position
	 * @param	TargetY	The target's y-position
	 */
	public function setTarget(TargetX:Float, TargetY:Float):Void
	{
		if (spotlight.width > 0)
			spotlight.target.set(TargetX, TargetY);
	}
	
	/**
	 * Set the attenuation (fall-off) of the light
	 * @param	X	The constant attenuation
	 * @param	Y	The linear attenuation
	 * @param	Z	The quadratic attenuation
	 */
	public function setAttenuation(?Constant:Float = 0.0, ?Linear:Float = 0.0, ?Quadratic:Float = 0.0):Void
	{
		attenuation.constant = Constant;
		attenuation.linear = Linear;
		attenuation.quadratic = Quadratic;
	}
	
	/**
	 * Helper function for the shader that returns all the data for the light packed into a matrix
	 * @return All the data for the light packed into a matrix
	 */
	public function getMatrix():Array<Float>
	{
		var screenSize:FlxPoint = new FlxPoint(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		var c:FlxColor = FlxColor.fromInt(lightColor);
		return [screenSize.x * (x / FlxG.width), screenSize.y * (y / FlxG.height), z, Math.min(1.0, Math.max(0.0, intensity)),
			    c.redFloat, c.greenFloat, c.blueFloat, 1.0,
				attenuation.constant, attenuation.linear, attenuation.quadratic, 0.0,
				screenSize.x * (spotlight.target.x / FlxG.width), screenSize.y * (spotlight.target.y / FlxG.height), spotlight.width, 0.0];
	}
	
}