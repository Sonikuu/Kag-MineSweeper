
#include "EmotesCommon.as"
#include "MineSweeperCommon.as"
#include "HumanCommon.as"

int useClickTime = 0;
f32 zoom = 1.0f;
const f32 ZOOM_SPEED = 0.1f;

void onInit( CBlob@ this )
{
	this.Tag("player");	 
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8,8));
	this.addCommandID("click");
	this.addCommandID("flag");
	this.addCommandID("mark");
}

void onTick( CBlob@ this )
{				
	Move( this );

	// my player stuff

	if (this.isMyPlayer())	
	{
		PlayerControls( this );
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f marker = blob.get_Vec2f("marker");
	CControls@ controls = getControls();
	CCamera@ camera = getCamera();
	if(marker != Vec2f_zero && controls !is null && camera !is null)
	{
		Vec2f scrhalf(getScreenWidth() / 2.0, getScreenHeight() / 2.0);
		float opacity = Maths::Min((marker - controls.getMouseWorldPos()).Length() / 64.0, 1.0);
		Vec2f pos = ((marker + Vec2f(8, 8) - (camera.getPosition())) * camera.targetDistance * 2) + scrhalf;
		
		
		GUI::DrawIcon("SweeperMarker.png", 0, Vec2f(16, 16), pos - Vec2f(16, 16), 1, SColor(255 * opacity, 255, 255, 255));
	}
	
	//incorrect tile locator
	if(blob is getLocalPlayerBlob())
	{
		Vec2f tileloc = blob.get_Vec2f("tileloc");
		if(tileloc != Vec2f_zero && (tileloc - blob.getPosition()).Length() > 32)
		{
			
			float rotation = -((tileloc - blob.getPosition()).Angle() * 3.14159) / 180.0;
			GUI::DrawArrow(blob.getPosition(), blob.getPosition() + Vec2f(Maths::Cos(rotation), Maths::Sin(rotation)) * 16, SColor(255, 255, 100, 100));
		}
	}
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{	
	if (player !is null && player.isMyPlayer()) // setup camera to follow
	{
		CCamera@ camera = getCamera();
		camera.mousecamstyle = 1; // follow
		camera.targetDistance = 1.0f; // zoom factor
		camera.posLag = 5; // lag/smoothen the movement of the camera

		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 0, Vec2f(8,8));
	}
}

void Move( CBlob@ this )
{
	const bool up = this.isKeyPressed( key_up );
	const bool down = this.isKeyPressed( key_down );
	const bool left = this.isKeyPressed( key_left);
	const bool right = this.isKeyPressed( key_right );	
	// move

	Vec2f moveVel;

	if (up)	{
		moveVel.y -= Human::walkSpeed;
	} 
	else if (down)	{
		moveVel.y += Human::walkSpeed;
	} 
	
	if (left)	{
		moveVel.x -= Human::walkSpeed;
	} 
	else if (right)	{
		moveVel.x += Human::walkSpeed;
	} 
	this.setAngleDegrees(-(this.getAimPos() - this.getPosition()).Angle());

	this.setVelocity(moveVel + this.getVelocity());
}



void PlayerControls( CBlob@ this )
{
	CHUD@ hud = getHUD();

	if (this.isKeyJustPressed(key_use))
	{
		this.ClearMenus();
		this.ShowInteractButtons();
		useClickTime = getGameTime();
	}
	else if (this.isKeyJustReleased(key_use))
	{
		bool tapped = (getGameTime() - useClickTime) < 10; 
		this.ClickClosestInteractButton( tapped ? this.getPosition() : this.getAimPos(), this.getRadius()*2 );
		this.ClearButtons();
	}	

	// click action1 to click buttons

	if (hud.hasButtons() && this.isKeyJustPressed(key_action1) && !this.ClickClosestInteractButton( this.getAimPos(), this.getRadius()*3 ))
	{
	}

	// click grid menus

    if (hud.hasButtons())
    {
        if (this.isKeyJustPressed(key_action1))
        {
		    CGridMenu @gmenu;
		    CGridButton @gbutton;
		    this.ClickGridMenu(0, gmenu, gbutton); 
	    }	
	}
	else	//otherwise standard click actions
	{
		if(this.isKeyJustPressed( key_action1 ))
		{
			CBitStream params;
			params.write_Vec2f(this.getAimPos());
			this.SendCommandOnlyServer(this.getCommandID("click"), params);
		}
		if(this.isKeyJustPressed( key_action2 ))
		{
			CBitStream params;
			params.write_Vec2f(this.getAimPos());
			this.SendCommandOnlyServer(this.getCommandID("flag"), params);
		}
		if(this.isKeyJustPressed( key_inventory ))
		{
			CBitStream params;
			params.write_Vec2f(this.getAimPos());
			this.SendCommandOnlyServer(this.getCommandID("mark"), params);
		}
	}

	// zoom
	
	CCamera@ camera = getCamera();
	CControls@ controls = getControls();
	if (controls !is null)
	{
		const int key_zoomout = 0x100;
		const int key_zoomin = 0xFF;

		if (zoom == 2.0f)	
		{
			if (controls.isKeyJustPressed(key_zoomout)){
	  			zoom = 1.0f;
	  		}
			else if (camera.targetDistance < zoom)
				camera.targetDistance += ZOOM_SPEED;		
		}
		else if (zoom == 1.0f)	
		{
			if (controls.isKeyJustPressed(key_zoomout)){
	  			zoom = 0.5f;
	  		}
	  		else if (controls.isKeyJustPressed(key_zoomin)){
	  			zoom = 2.0f;
	  		} 
	  		else if (camera.targetDistance < zoom)
				camera.targetDistance += ZOOM_SPEED;	
			else if (camera.targetDistance > zoom)
				camera.targetDistance -= ZOOM_SPEED;	
		}
		else if (zoom == 0.5f)
		{
			if (controls.isKeyJustPressed(key_zoomin)){
	  			zoom = 1.0f;
	  		} 
			else if (camera.targetDistance > zoom)	
				camera.targetDistance -= ZOOM_SPEED;
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (this.getCommandID("click") == cmd)
	{
		Vec2f clickpos = params.read_Vec2f();
		HandleReveal(this, clickpos);
	}
	else if (this.getCommandID("flag") == cmd)
	{
		Vec2f clickpos = params.read_Vec2f();
		HandleFlag(this, clickpos);
	}
	else if (this.getCommandID("mark") == cmd)
	{
		Vec2f clickpos = params.read_Vec2f();
		if((clickpos - this.get_Vec2f("marker")).Length() > 32 || this.get_Vec2f("marker") == Vec2f_zero)
		{
			this.set_Vec2f("marker", clickpos - Vec2f(8, 8));
		}
		else
		{
			this.set_Vec2f("marker", Vec2f_zero);
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}
