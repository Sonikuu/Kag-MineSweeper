
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */



void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	//change this in your mod
}

/*TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	int output = oldTileType;
	if(oldTileType >= 1 && oldTileType <= 14)
	{
		output = XORRandom(14);
	}
	return output;
}*/