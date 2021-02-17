// LoaderUtilities.as

#include "DummyCommon.as";
#include "CustomMap.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

/*
TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
}
*/

TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	int output = oldTileType;
	if(oldTileType >= 1 && oldTileType <= 16)
	{
		output = XORRandom(16);
	}
	return output;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	map.SetTileSupport(index, -1);
	map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE |  Tile::BACKGROUND);
	if(tile_new == CMap::border)
		map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	//SFX
	if(tile_new >= 5 && tile_new <= 13)
	{//cleared spaces
		Sound::Play("plonk.ogg", Vec2f(index % map.tilemapwidth, index / map.tilemapwidth) * map.tilesize, 6.0, 0.8 + float(XORRandom(4)) / 10.0);
	}
	else if(tile_new == CMap::flag_block || tile_new == CMap::flag_mine)
	{//flagging a tile
		Sound::Play("throw.ogg", Vec2f(index % map.tilemapwidth, index / map.tilemapwidth) * map.tilesize, 1.0, 0.8 + float(XORRandom(4)) / 10.0);
	}
	else if((tile_new == CMap::block || tile_new == CMap::mine) && (tile_old == CMap::flag_block || tile_old == CMap::flag_mine))
	{//deflagging a tile
		Sound::Play("thud.ogg", Vec2f(index % map.tilemapwidth, index / map.tilemapwidth) * map.tilesize, 1.0, 0.8 + float(XORRandom(4)) / 10.0);
	}
	else if(tile_new == CMap::tripped)
	{//hitting a mine
		Sound::Play("fallbig.ogg", Vec2f(index % map.tilemapwidth, index / map.tilemapwidth) * map.tilesize, 1.0, 0.8 + float(XORRandom(4)) / 10.0);
	}
}









