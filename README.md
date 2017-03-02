# flixelighting
A HaxeFlixel library designed to make real-time lighting easy to include in games

## Features

Currently this library allows you to:

- Easily use real-time normal map based lighting calculations in your game
- Add up to 8 modifiable lights
- Update the lighting calculations on the fly

## Upcoming

- Dynamic shadows
- Improved spotlights
- Possibly some environment mapping?

## Getting started

1. Download the directory as a .zip, and include the "flixelighting" subfolder at the source of your HaxeFlixel project (The same level as your "assets", "source", "export" folders!)
2. The following is a basic implementation within a flixel.FlxState:

```haxe
//HaxeFlixel imports
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

//Importing the flixelighting classes
import flixelighting.FlxLight;
import flixelighting.FlxNormalMap;
import flixelighting.FlxLighting;

class MyState extends FlxState
{
	//Creating a global FlxLighting object so it can be accessed in the update method
	private var myLighting:FlxLighting;

	override public function create():Void
	{
		//Creating and adding a sprite to the scene (we need something for the normal map to affect!)
		var mySprite:FlxSprite = new FlxSprite(0, 0, "my/path/to/my/image");
		add(mySprite);

		//Setting up the FlxLighting object (this does all of the lighting calculations)
		myLighting = new FlxLighting();
		//Setting a custom ambient light color and intensity
		myLighting.setAmbient(0x181d3a, 1.0);

		//Creating an FlxLight object to illuminate the scene with
		var myLight = new FlxLight(250, 130, 0.04, 1.0, 0xec9523);

		//Creating a FlxNormalMap that holds a normal map bitmap corresponding to the previously created sprite
		var myNormalMap:FlxNormalMap = new FlxNormalMap(0, 0, "my/path/to/my/normal/map");

		//Adding the FlxLight object to the FlxLighting object
		myLighting.addLight(myLight);

		//Adding the FlxNormalMap object to the FlxLighting object
		//Note: only one FlxNormalMap can be added. Calling this method again will override the previous FlxNormalMap
		myLighting.addNormalMap(myNormalMap);

		//Getting the filter from the FlxLighting object and adding it to the list of camera filters
		FlxG.camera.setFilters([myLighting.getFilter()]);
	}

	override public function update(elapsed:Float):Void
	{
		//If you update any lights or the normal map, call this function to update the lighting calculations!
		myLighting.update();

		super.update(elapsed);
	}
}
```

## Some useful functions

1. You can set the attenuation of a light source by calling its "setAttenuation" method
		```haxe
		myLight.setAttenuation(constantValue, linearValue, quadraticValue);
		```
2. You can convert a FlxLight object into a spotlight by calling the "makeSpotlight" method
		```haxe
		myLight.makeSpotlight(mySpotlightWidth, myTargetX, myTargetY);
		```
3. You can combine normal maps using the FlxNormalMap static "composite" method
		```haxe
		var myComposite:FlxNormalMap = FlxNormalMap.composite(myWidth, myHeight, [array, of, flxNormalMaps]);
		```
