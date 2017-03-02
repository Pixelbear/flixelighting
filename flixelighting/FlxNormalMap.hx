package flixelighting;

import flixel.FlxG;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.geom.Point;

/**
 * Class for the creation of a normal map object to be passed into a Lighting object
 * @author George Baron
 */
class FlxNormalMap
{
	
	/**
	 * The x-position of the normal map
	 */
	public var x:Float;
	/**
	 * The y-position of the normal map
	 */
	public var y:Float;
	/**
	 * The raw bitmap data of the normal map
	 */
	public var data:BitmapData;
	/**
	 * The raw bitmap data of the alpha mask
	 */
	public var alphaMask:BitmapData;
	
	/**
	 * Constructor
	 * @param	X	The x-position of the normal map
	 * @param	Y	The y-position of the normal map
	 * @param	PathToData	The path to the image you want to use as the normal map
	 * @param	PathToAlphaMask	The path to the image you want to use as the alpha mask
	 */
	public function new(?X:Float=0, ?Y:Float=0, ?PathToData:Dynamic, ?PathToAlphaMask:Dynamic) 
	{
		if (PathToData != null)
			data = Assets.getBitmapData(PathToData);
		if (PathToAlphaMask != null)
			alphaMask = Assets.getBitmapData(PathToAlphaMask);
		
		x = X;
		y = Y;
	}
	
	/**
	 * Accessor method for the normal map's position
	 * @return The position of the normal map
	 */
	public function getPosition():FlxPoint
	{
		return new FlxPoint(x, y);
	}
	
	/**
	 * Helper method for combining multiple normal maps into one normal map
	 * @param	Width	The width of the new normal map
	 * @param	Height	The height of the new normal map
	 * @param	maps	An array of normal maps to be layered on top of each other, with the first element being the bottom layer
	 * @return
	 */
	public static function composite(?Width:Int, ?Height:Int, maps:Array<FlxNormalMap>):FlxNormalMap
	{
		Width = Width == null ? FlxG.width : Width;
		Height = Height == null ? FlxG.height : Height;
		
		var composite:BitmapData = new BitmapData(Width, Height, false, FlxColor.BLACK);
		
		//Loop through bitmapdata and copy pixels to the composite
		for (i in 0...maps.length)
		{
			if (maps[i].data != null)
				composite.copyPixels(maps[i].data, maps[i].data.rect, new Point(maps[i].x, maps[i].y), maps[i].alphaMask, new Point(0, 0), true);
		}
		
		var n:FlxNormalMap = new FlxNormalMap(0, 0);
		n.data = composite;
		
		return n;
	}
	
}