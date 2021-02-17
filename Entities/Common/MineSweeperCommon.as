

#include "CustomMap.as";

void HandleReveal(CBlob@ this, Vec2f pos)
{
	
	CMap@ map = getMap();
	int offset = posToOffset(pos / map.tilesize);
	int tileid = map.getTile(pos).type;
	pos = Vec2f(Maths::Floor(pos.x / map.tilesize), Maths::Floor(pos.y / map.tilesize)) * map.tilesize + Vec2f(map.tilesize / 2, map.tilesize / 2);
	if(tileid == CMap::block)
	{
		u8 nearmines = getNearbyMines(map, pos);
		if(nearmines == 0)
		{
			map.server_SetTile(pos, CMap::clear);
			CRules@ rules = getRules();
			CRevealCascade@ reveal;
			rules.get("revealcascade", @reveal);
			if(reveal !is null)
			{
				reveal.positions.insertLast(pos);
				reveal.blobs.insertLast(this);
			}
			//RevealArea(pos, map);
		}
		else
			map.server_SetTile(pos, 4 + nearmines);
		if(this !is null)
		{
			CPlayer@ player = this.getPlayer();
			if(player !is null)
			{
				player.setScore(player.getScore() + 5);
			}
		}
	}
	else if( tileid == CMap::mine)
	{
		map.server_SetTile(pos, CMap::tripped);
		if(this !is null)
		{
			this.server_Die();
			CPlayer@ player = this.getPlayer();
			if(player !is null)
			{
				player.setScore(player.getScore() - 25);
			}
		}
		else
		{
			print("Server tried to reveal a mine :V");
		}
	}
}

void HandleFlag(CBlob@ this, Vec2f pos)
{
	CMap@ map = getMap();
	int offset = posToOffset(pos / map.tilesize);
	int tileid = map.getTile(pos).type;
	if(tileid == CMap::block || tileid == CMap::mine)
	{
		map.server_SetTile(pos, tileid + 2);
	}
	else if(tileid == CMap::flag_block || tileid == CMap::flag_mine)
	{
		map.server_SetTile(pos, tileid - 2);
	}
}

u8 getNearbyMines(CMap@ map, Vec2f pos, int range = 1)
{
	u8 output = 0;
	
	pos = Vec2f(Maths::Floor(pos.x / map.tilesize), Maths::Floor(pos.y / map.tilesize)) * map.tilesize + Vec2f(map.tilesize / 2, map.tilesize / 2);
	
	for(int x = pos.x - range * map.tilesize; x <= pos.x + range * map.tilesize; x += map.tilesize)
	{
		for(int y = pos.y - range * map.tilesize; y <= pos.y + range * map.tilesize; y += map.tilesize)
		{
			Vec2f currpos(x, y);
			//if(pos == currpos)
				//break;
			int offset = posToOffset(currpos / map.tilesize);
			int tileid = map.getTile(offset).type;
			if(tileid == CMap::mine || tileid == CMap::tripped || tileid == CMap::flag_mine)
				output++;
		}
	}
	//Left and right
	/*if(map.getTile(offset - 1).type == CMap::mine || map.getTile(offset - 1).type == CMap::tripped)
		output++;
	if(map.getTile(offset + 1).type == CMap::mine || map.getTile(offset + 1).type == CMap::tripped)
		output++;
	//Blocks Above
	if(map.getTile((offset - map.tilemapwidth) - 1).type == CMap::mine || map.getTile((offset - map.tilemapwidth) - 1).type == CMap::tripped)
		output++;
	if(map.getTile((offset - map.tilemapwidth)).type == CMap::mine || map.getTile((offset - map.tilemapwidth)).type == CMap::tripped)
		output++;
	if(map.getTile((offset - map.tilemapwidth) + 1).type == CMap::mine || map.getTile((offset - map.tilemapwidth) + 1).type == CMap::tripped)
		output++;
	//Blocks below
	if(map.getTile((offset + map.tilemapwidth) - 1).type == CMap::mine || map.getTile((offset - map.tilemapwidth) - 1).type == CMap::tripped)
		output++;
	if(map.getTile((offset + map.tilemapwidth)).type == CMap::mine)
		output++;
	if(map.getTile((offset + map.tilemapwidth) + 1).type == CMap::mine)
		output++;
		
	//Exact same check but for flagged mines
	//Left and right
	if(map.getTile(offset - 1).type == CMap::flag_mine && offsetOverflowCheck(offset, offset - 1, map))
		output++;
	if(map.getTile(offset + 1).type == CMap::flag_mine && offsetOverflowCheck(offset, offset + 1, map))
		output++;
	//Blocks Above
	if(map.getTile((offset - map.tilemapwidth) - 1).type == CMap::flag_mine && offsetOverflowCheck(offset, (offset - map.tilemapwidth) - 1, map))
		output++;
	if(map.getTile((offset - map.tilemapwidth)).type == CMap::flag_mine && offsetOverflowCheck(offset, (offset - map.tilemapwidth), map))
		output++;
	if(map.getTile((offset - map.tilemapwidth) + 1).type == CMap::flag_mine && offsetOverflowCheck(offset, (offset - map.tilemapwidth) + 1, map))
		output++;
	//Blocks below
	if(map.getTile((offset + map.tilemapwidth) - 1).type == CMap::flag_mine && offsetOverflowCheck(offset, (offset + map.tilemapwidth) - 1, map))
		output++;
	if(map.getTile((offset + map.tilemapwidth)).type == CMap::flag_mine && offsetOverflowCheck(offset, (offset + map.tilemapwidth), map))
		output++;
	if(map.getTile((offset + map.tilemapwidth) + 1).type == CMap::flag_mine && offsetOverflowCheck(offset, (offset + map.tilemapwidth) + 1, map))
		output++;
		*/
	return output;
}

u8 getNearbyFlags(CMap@ map, Vec2f pos, int range = 1)
{
	u8 output = 0;
	
	pos = Vec2f(Maths::Floor(pos.x / map.tilesize), Maths::Floor(pos.y / map.tilesize)) * map.tilesize + Vec2f(map.tilesize / 2, map.tilesize / 2);
	
	for(int x = pos.x - range * map.tilesize; x <= pos.x + range * map.tilesize; x += map.tilesize)
	{
		for(int y = pos.y - range * map.tilesize; y <= pos.y + range * map.tilesize; y += map.tilesize)
		{
			Vec2f currpos(x, y);
			//if(pos == currpos)
				//break;
			int offset = posToOffset(currpos / map.tilesize);
			int tileid = map.getTile(offset).type;
			if(tileid == CMap::flag_block || tileid == CMap::flag_mine || tileid == CMap::tripped)
				output++;
		}
	}
	return output;
}

int posToOffset(Vec2f pos)
{
	CMap@ map = getMap();
	int x = Maths::Floor(pos.x);
	int y = Maths::Floor(pos.y);
	return x + y * map.tilemapwidth;
}

void RevealArea(Vec2f pos, CMap@ map, int range = 1, CBlob@ blob = null)
{
	float tilesize = map.tilesize;
	
	pos = Vec2f(Maths::Floor(pos.x / map.tilesize), Maths::Floor(pos.y / map.tilesize)) * map.tilesize + Vec2f(map.tilesize / 2, map.tilesize / 2);
	
	for(int x = pos.x - range * tilesize; x <= pos.x + range * tilesize; x += tilesize)
	{
		for(int y = pos.y - range * tilesize; y <= pos.y + range * tilesize; y += tilesize)
		{
			Vec2f currpos(x, y);
			//if(pos == currpos)
				//break;
			int offset = posToOffset(currpos / tilesize);
			int tileid = map.getTile(offset).type;
			if(tileid == CMap::block)
				HandleReveal(blob, currpos);
		}
	}
	//Left and right
	/*if(map.getTile(offset - 1).type == CMap::block && offsetOverflowCheck(offset, offset - 1, map))
		HandleReveal(null, Vec2f(pos.x - tilesize, pos.y));
	if(map.getTile(offset + 1).type == CMap::block && offsetOverflowCheck(offset, offset + 1, map))
		HandleReveal(null, Vec2f(pos.x + tilesize, pos.y));
	//Blocks Above
	if(map.getTile((offset - map.tilemapwidth) - 1).type == CMap::block && offsetOverflowCheck(offset, (offset - map.tilemapwidth) - 1, map))
		HandleReveal(null, Vec2f(pos.x - tilesize, pos.y - tilesize));
	if(map.getTile((offset - map.tilemapwidth)).type == CMap::block && offsetOverflowCheck(offset, (offset - map.tilemapwidth), map))
		HandleReveal(null, Vec2f(pos.x, pos.y - tilesize));
	if(map.getTile((offset - map.tilemapwidth) + 1).type == CMap::block && offsetOverflowCheck(offset, (offset - map.tilemapwidth) + 1, map))
		HandleReveal(null, Vec2f(pos.x + tilesize, pos.y - tilesize));
	//Blocks below
	if(map.getTile((offset + map.tilemapwidth) - 1).type == CMap::block && offsetOverflowCheck(offset, (offset + map.tilemapwidth) - 1, map))
		HandleReveal(null, Vec2f(pos.x - tilesize, pos.y + tilesize));
	if(map.getTile((offset + map.tilemapwidth)).type == CMap::block && offsetOverflowCheck(offset, (offset + map.tilemapwidth), map))
		HandleReveal(null, Vec2f(pos.x, pos.y + tilesize));
	if(map.getTile((offset + map.tilemapwidth) + 1).type == CMap::block  && offsetOverflowCheck(offset, (offset + map.tilemapwidth) + 1, map))
		HandleReveal(null, Vec2f(pos.x + tilesize, pos.y + tilesize));*/
}

bool offsetOverflowCheck(int base, int offset, CMap@ map)
{
	bool output = true;
	/*if(base % map.tilemapwidth != offset % map.tilemapwidth))
	{
		output = false;
	}*/ //i give up, ill just add a border around the map lel
	return output;
}

class CRevealCascade
{
	array<Vec2f> positions;
	array<CBlob@> blobs;
	CRevealCascade()
	{
		positions = array<Vec2f>();
	}
	
	void Reveal()
	{
		CMap@ map = getMap();
		int startlength = positions.length(); //length might change cause can add more positions as this runs i dunno
		for (int i = 0; i < startlength; i++)
		{
			RevealArea(positions[0], map, 1, blobs[0]);
			positions.removeAt(0);
			blobs.removeAt(0);
		}
	}
}






