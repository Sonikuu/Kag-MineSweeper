// generates from a KAGGen config
// fileName is "" on client!

#include "LoaderUtilities.as";
#include "CustomMap.as";
#include "MineSweeperCommon.as";

bool loadMap(CMap@ _map, const string& in filename)
{
	CMap@ map = _map;

	if (!getNet().isServer() || filename == "")
	{
		CMap::SetupMap(map, 0, 0);
		//SetupBackgrounds(map);
		return true;
	}

	Random@ map_random = Random(map.getMapSeed());

	Noise@ map_noise = Noise(map_random.Next());

	Noise@ material_noise = Noise(map_random.Next());

	//read in our config stuff -----------------------------

	ConfigFile cfg = ConfigFile(filename);

	//boring vars
	s32 width = cfg.read_s32("m_width", m_width);
	s32 height = cfg.read_s32("m_height", m_height);

	s32 difficulty = cfg.read_s32("difficulty", 10);
	
	bool playerscale = cfg.read_bool("playerscale", true);
	//Does map scale with player count?
	
	s32 borderbuffer = cfg.read_s32("borderbuffer", 0);
	//How thick is the clear area inside the border
	
	s32 uselessratio = cfg.read_s32("uselessratio", 0);
	//How many nonmine tiles become useless
	
	if(playerscale)
	{
		int tilespace = width * height;

		//I dunno what im doing hope it works tho
		float hratio = float(height) / float(width);
		float wratio = float(width) / float(height);

		tilespace *= getPlayerCount() + 1;
		width = Maths::Sqrt(tilespace) * wratio;
		height = Maths::Sqrt(tilespace) * hratio;
	}

	CMap::SetupMap(map, width, height);


	for (int x = 0; x < width; ++x)
	{
		for (int y = 0; y < height; ++y)
		{
			int offset = x + y * width;
			if(x == 0 || y == 0 || x == width - 1 || y == height - 1)
			{
				map.SetTile(offset, CMap::border);
			}
			else if(map_random.NextRanged(100) < difficulty)
			{
				map.SetTile(offset, CMap::mine);
			}
			else if(map_random.NextRanged(100) < uselessratio)
			{
				map.SetTile(offset, CMap::useless);
			}
			else
			{
				map.SetTile(offset, CMap::block);
			}
			
			if((x > 0 && y > 0 && x < width - 1 && y < height - 1) && 
					(x <= borderbuffer ||
					y <= borderbuffer ||
					x >= width - (borderbuffer + 1) ||
					y >= height - (borderbuffer + 1)))
			{
				map.SetTile(offset, CMap::block);
			}
		}
	}
	
	Vec2f spawnpoint((map_random.NextRanged(width - 6) + 3) * map.tilesize, (map_random.NextRanged(height - 6) + 3) * map.tilesize);
	
	
	for(int x = spawnpoint.x - 2 * map.tilesize; x <= spawnpoint.x + 2 * map.tilesize; x += map.tilesize)
	{
		for(int y = spawnpoint.y - 2 * map.tilesize; y <= spawnpoint.y + 2 * map.tilesize; y += map.tilesize)
		{
			Vec2f currpos(x, y);

			int offset = posToOffset(currpos / map.tilesize);

			map.SetTile(offset, CMap::block);
		}
	}
	
	/*if(borderbuffer > 0)
	{
		for (int x = 0; x < width; ++x)
		{
			for (int y = 0; y < height; ++y)
			{
				if((x > 0 && y > 0 && x < width - 1 && y < height - 1) && 
					(x <= borderbuffer ||
					y <= borderbuffer ||
					x >= width - (borderbuffer + 1) ||
					y >= height - (borderbuffer + 1)))
				{
					HandleReveal(null, Vec2f(width, height));
				}
			}
		}
	}*/
	
	HandleReveal(null, spawnpoint);
	
	map.AddMarker(spawnpoint, "spawnpoint");
	return true;
}

void SetupMap(CMap@ map, int width, int height)
{
	map.CreateTileMap(width, height, 8.0f, "Sprites/world.png");
}

void SetupBackgrounds(CMap@ map)
{
	// sky

	map.CreateSky(SColor(255, 255, 255, 255));
	map.topBorder = map.bottomBorder = map.rightBorder = map.leftBorder = true;
	map.SetBorderFadeWidth(0);
	map.legacyTileVariations = false;
	//map.legacyTileEffects = false;
	//map.legacyTileDestroy = false;
	//map.legacyTileMinimap = false;

	SetScreenFlash(255, 0, 0, 0);
	
	SetupBlocks(map);
}

void SetupBlocks(CMap@ map)
{

}

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("GENERATING Sweeper MAP " + fileName);

	return loadMap(map, fileName);
}
