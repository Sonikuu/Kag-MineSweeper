namespace CMap
{
	// tiles
	const SColor color_clear(255, 255, 255, 255);
	const SColor color_block(255, 125, 125, 125);
	const SColor color_mine(255, 0, 0, 0);
	// objects
	const SColor color_border(255, 0, 255, 0);

	enum Blocks 
	{
		block = 1,
		mine = 2,
		flag_block = 3,
		flag_mine = 4,
		clear_1 = 5,
		clear_2 = 6,
		clear_3 = 7,
		clear_4 = 8,
		clear_5 = 9,
		clear_6 = 10,
		clear_7 = 11,
		clear_8 = 12,
		clear = 13,
		border = 14,
		tripped = 15,
		useless = 16
		
	};

	//
	void SetupMap( CMap@ map, int width, int height )
	{
		map.CreateTileMap( width, height, 8.0f, "Sprites/world.png" );
		map.CreateSky(SColor(255, 255, 255, 255));
		map.topBorder = map.bottomBorder = map.rightBorder = map.leftBorder = true;
		map.SetBorderFadeWidth(0);
		map.legacyTileVariations = false;
		map.legacyTileEffects = false;
		map.legacyTileDestroy = false;
		map.legacyTileMinimap = false;
		
		SetScreenFlash(255, 0, 0, 0);
	}  	

	//
	void handlePixel( CMap@ map, SColor pixel, int offset)
	{
		if (pixel == CMap::color_clear) 
		{			
			map.SetTile(offset, CMap::clear );
			map.AddTileFlag( offset, Tile::BACKGROUND );
			map.AddTileFlag( offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
			//map.AddTileFlag( offset, Tile::SOLID );
			//map.SetTile(offset, CMap::grass + random % 3 );

		}		
		else if (pixel == CMap::color_block) 
		{
			map.SetTile(offset, CMap::block );
			map.AddTileFlag( offset, Tile::BACKGROUND );
			map.AddTileFlag( offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
			//map.AddTileFlag( offset, Tile::SOLID );
		}	
		else if (pixel == CMap::color_mine) 
		{
			map.SetTile(offset, CMap::mine );
			map.AddTileFlag( offset, Tile::BACKGROUND );
			map.AddTileFlag( offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
			//map.AddTileFlag( offset, Tile::SOLID );
		}			
		else if (pixel == CMap::color_border) 
		{
			map.SetTile(offset, CMap::border );
			map.AddTileFlag( offset, Tile::BACKGROUND );
			map.AddTileFlag( offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
			map.AddTileFlag( offset, Tile::SOLID );
			map.AddTileFlag( offset, Tile::COLLISION );
		}  
	}
}


