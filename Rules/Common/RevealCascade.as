#include "MineSweeperCommon.as";

void onInit(CRules@ this)
{
	CRevealCascade reveal();
	this.set("revealcascade", @reveal);
}

void onTick(CRules@ this)
{
	if(getGameTime() % 5 == 0)
	{
		CRevealCascade@ reveal;
		this.get("revealcascade", @reveal);
		if(reveal !is null)
		{
			reveal.Reveal();
		}
	}
}