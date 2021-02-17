
int time;
bool displaytext = true;

void onInit( CRules@ this )
{
	time = 0;
}

void onTick(CRules@ this)
{
	CControls@ cont = getControls();
	if(cont !is null)
	{
		if(cont.isKeyJustPressed(KEY_F1))
		{
			if(displaytext)
				displaytext = false;
			else
				displaytext = true;
		}
			
		if(displaytext)
		{
			const int endTime3 = getTicksASecond() * 40;
			time++;
			if(time > endTime3)
				time = 0;
		}
	}
}

void onRender( CRules@ this )
{
	
    const int endTime1 = getTicksASecond() * 4;
	const int endTime2 = getTicksASecond() * 20;
	const int endTime3 = getTicksASecond() * 40;

	bool draw = false;
	Vec2f ul, lr;
	string text = "";

	ul = Vec2f( 30, 3*getScreenHeight()/4 );
	
	if(displaytext)
	{
		if (time < endTime1) {
			text = "Welcome to Minesweeper!";
			
			Vec2f size;
			GUI::GetTextDimensions(text, size);
			lr = ul + size;
			draw = true;
		}
		else if (time < endTime2) {
			text =  "How to Play:\n\n"+
					" *Numbers indicate how many mines are in the 8 spaces around that tile\n"+
					" *Use this to figure out where a mine is\n"+
					" *Right click to flag a tile as mine\n"+
					" *Left click to clear it\n"+
					" *Trying to clear a mine will kill you\n";
			Vec2f size;
			GUI::GetTextDimensions(text, size);
			lr = ul + size;
			lr.y -= 32.0f;
			draw = true;
		}
		else if (time < endTime3) {
			text =  "How to Play (continued):\n\n"+
					" *[ WASD ] to move around\n"+
					" *[ LMB ] clear space\n"+
					" *[ RMB ] flag tile\n"+
					" *[ F ] place marker\n"+
					" *[ SCROLL ] zoom in/out\n"+
					"\n (these keys apply by default only)\n"+
					"\n              Have Fun!\n"+
					"\n[ F1 ] Toggle this help text\n";
			Vec2f size;
			GUI::GetTextDimensions(text, size);
			lr = ul + size;
			lr.y -= 48.0f;
			draw = true;
		}
	}
	
	if(draw)
	{
		f32 wave = Maths::Sin(getGameTime() / 10.0f) * 2.0f;
		ul.y += wave;
		lr.y += wave;
		GUI::DrawButtonPressed( ul - Vec2f(10,10), lr + Vec2f(10,10) );
		GUI::DrawText( text, ul, SColor(0xffffffff) );
	}
}
