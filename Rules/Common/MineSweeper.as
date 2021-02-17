#include "Default/DefaultGUI.as"
#include "Default/DefaultLoaders.as"
#include "CustomMap.as"
#include "MineSweeperCommon.as"

void onInit(CRules@ this)
{
	RegisterFileExtensionScript( "WaterPNGMap.as", "png" );
    particles_gravity.y = 0.0f; 
    sv_gravity = 0;    
    v_camera_ints = false;
    sv_visiblity_scale = 2.0f;

	s_effects = false;
}

void onTick(CRules@ this)
{
	//check map stats
	CMap@ map = getMap();
	if(getGameTime() % 90 == 0)
	{
		int minecount = 0;
		int flagcount = 0;
		int tilecount = 0;
		int tripcount = 0;
		
		for (int x = 0; x < map.tilemapwidth; ++x)
		{
			for (int y = 0; y < map.tilemapheight; ++y)
			{
				int offset = x + y * map.tilemapwidth;
				int tileid = map.getTile(offset).type;
				switch(tileid)
				{
					case CMap::block:
						tilecount++;
					break;
					case CMap::mine:
						tilecount++;
						minecount++;
					break;
					case CMap::flag_block:
						tilecount++;
						flagcount++;
					break;
					case CMap::flag_mine:
						tilecount++;
						flagcount++;
						minecount++;
					break;
					case CMap::tripped:
						tripcount++;
					break;
				}
			}
		}
		this.set_u32("minecount", minecount);
		this.set_u32("flagcount", flagcount);
		this.set_u32("tilecount", tilecount);
		this.set_u32("tripcount", tripcount);
		if(getGameTime() > 300 && tilecount == minecount && !this.isGameOver())
		{
			CPlayer@ winner = null;
			int winpoints = -1000000; // :V
			for(int i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				if(player.getScore() > winpoints)
				{
					winpoints = player.getScore();
					@winner = @player;
				}
			}
			if(winner !is null)
				this.SetGlobalMessage( "Map completed in " + formatInt(getGameTime() / getTicksASecond(), "") + " seconds!\nHighest score is " + winner.getUsername() + " with " + formatInt(winner.getScore(), "") + " points!");
			else
				this.SetGlobalMessage( "Map completed in " + formatInt(getGameTime() / getTicksASecond(), "") + " seconds!");
			if(winner is getLocalPlayer())
				Sound::Play("FanfareWin.ogg");
			else
				Sound::Play("FanfareLose.ogg");
			this.SetCurrentState(GAME_OVER);
		}
		if(flagcount > minecount) //too many flags D:
		{
			array<Vec2f> invalidtiles();
			for (int x = 0; x < map.tilemapwidth; ++x)
			{
				for (int y = 0; y < map.tilemapheight; ++y)
				{
					int offset = x + y * map.tilemapwidth;
					int tileid = map.getTile(offset).type;
					if(tileid >= CMap::clear_1 && tileid <= CMap::clear) //checking for floor tiles
					{
						u8 minec = getNearbyFlags(map, (Vec2f(x, y) * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2));
						if(minec > tileid - 4 || (tileid == CMap::clear && minec > 1))
						{
							invalidtiles.push_back((Vec2f(x, y) * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2));
						}
					}
				}
			}
			
			for(int i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				CBlob@ blob = player.getBlob();
				if(blob !is null)
				{
					Vec2f blobpos = blob.getPosition();
					float closest = 1000;
					Vec2f closestvec = Vec2f_zero;
					for (int j = 0; j < invalidtiles.length(); j++)
					{
						float thislength = (blobpos - invalidtiles[j]).Length();
						if(thislength < closest)
						{
							closestvec = invalidtiles[j];
							closest = thislength;
						}
					}
					blob.set_Vec2f("tileloc", closestvec);
					//print("Set a tileloc");
				}
			}
		}
		else
		{
			for(int i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ player = getPlayer(i);
				CBlob@ blob = player.getBlob();
				if(blob !is null)
				{
					blob.set_Vec2f("tileloc", Vec2f_zero);
				}
			}
		}
	}
	if(this.isGameOver() && getGameTime() % 3 == 0 && getNet().isServer())
	{
		CBlob@ bomb = server_CreateBlob("bomb", 0, Vec2f(XORRandom(map.tilesize * map.tilemapwidth), XORRandom(map.tilesize * map.tilemapheight)));
		bomb.set_s32("bomb_timer", 0);
	}
}

void onRestart(CRules@ this)
{
	for(int i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		player.setScore(0);
	}
}

void onRender(CRules@ this)
{
	int scrw = getScreenWidth();
	GUI::SetFont("menu");
	int minecount = this.get_u32("minecount");
	int flagcount = this.get_u32("flagcount");
	int tilecount = this.get_u32("tilecount");
	int tripcount = this.get_u32("tripcount");
	GUI::DrawText("Total Mines: " + formatInt(minecount, ""), Vec2f(scrw - 200, 20), SColor(255, 255, 255, 255));
	GUI::DrawText("Flags Placed: " + formatInt(flagcount, ""), Vec2f(scrw - 200, 60), minecount >= flagcount ? SColor(255, 255, 255, 255) : SColor(255, 255, 100, 100));
	GUI::DrawText("Tiles Left: " + formatInt(tilecount, ""), Vec2f(scrw - 200, 100), SColor(255, 255, 255, 255));
	GUI::DrawText("Tripped Mines: " + formatInt(tripcount, ""), Vec2f(scrw - 200, 140), SColor(255, 255, 255, 255));
	GUI::DrawText("Time: " + formatInt(getGameTime() / getTicksASecond(), ""), Vec2f(scrw - 200, 180), SColor(255, 255, 255, 255));
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(0);
}

void onBlobDie(CRules@ this, CBlob@ blob)
{	//DefaultScoreboard but with the scoresetting trimmed out
	if (blob !is null)
	{
		CPlayer@ killer = blob.getPlayerOfRecentDamage();
		CPlayer@ victim = blob.getPlayer();

		if (victim !is null)
		{
			victim.setDeaths(victim.getDeaths() + 1);

			if (killer !is null)
			{
				if (killer.getTeamNum() != blob.getTeamNum())
				{
					killer.setKills(killer.getKills() + 1);
				}
			}

		}
	}
}