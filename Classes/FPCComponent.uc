class FPCComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;
var bool isFPCActive;
var vector oldOffset;
var float oldCurrentZoomDistance;
var float oldDesiredZoomDistance;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	if(PCOwner != gMe.Controller)
		return;

	if( keyState == KS_Down )
	{
		//myMut.WorldInfo.Game.Broadcast(myMut, "newKey=" $ newKey);
		if(newKey == 'P' || newKey == 'XboxTypeS_RightThumbStick')
		{
			SwitchFPC();
		}
	}
}

function SwitchFPC()
{
	isFPCActive=!isFPCActive;
	if(!isFPCActive)
	{
		ResetCameraZoom(gMe.Controller);
	}
	ModifyAllCameraZoom();
}

function ModifyAllCameraZoom()
{
	local GGMutatorComponent componentItr;

	foreach GGGameInfo(class'WorldInfo'.static.GetWorldInfo().Game).mMutatorComponents[ gMe.mCachedSlotNr ].MutatorComponents( componentItr )
	{
		componentItr.ModifyCameraZoom(gMe);
	}
}

function vector GetDesiredCamLocation(GGGoat goat)
{
	local vector loc;

	goat.Mesh.GetSocketWorldLocationAndRotation('hairSocket', loc);
	if(IsZero(loc))
	{
		loc=goat.Mesh.GetBoneLocation('Head');
		if(IsZero(loc))
		{
			loc=goat.Location;
		}
	}

	return loc;
}

event TickMutatorComponent( float deltaTime )
{
	local vector newOffset;

	super.TickMutatorComponent(deltaTime);

	if(gMe.Controller != none && isFPCActive)
	{
		newOffset=GetDesiredCamLocation(gMe)-gMe.Location;
		if(newOffset != gMe.mCameraLookAtOffset)
		{
			gMe.mCameraLookAtOffset=newOffset;
			//myMut.WorldInfo.Game.Broadcast(myMut, "newOffset=" $ newOffset);
			//myMut.WorldInfo.Game.Broadcast(myMut, "head=" $ newOffset);
		}
	}
}

function ResetCameraZoom( Controller C )
{
	local GGCameraModeOrbital orbitalCamera;
	local GGGoat goat;

	super.ResetCameraZoom(C);

	orbitalCamera = GGCameraModeOrbital( GGCamera( PlayerController( C ).PlayerCamera ).mCameraModes[ CM_ORBIT ] );
	goat = GGGoat(C.Pawn);
	if(goat != none)
	{
		goat.mCameraLookAtOffset=oldOffset;
		goat.SwitchMaterial(false);
	}
	orbitalCamera.mUseCameraBounce=orbitalCamera.default.mUseCameraBounce;
	orbitalCamera.mSupportsZoom=orbitalCamera.default.mSupportsZoom;
}

function ModifyCameraZoom( GGGoat goat )
{
	local GGCameraModeOrbital orbitalCamera;

	super.ModifyCameraZoom(goat);

	if(!isFPCActive || goat == none || goat.Controller == none)
		return;

	orbitalCamera = GGCameraModeOrbital( GGCamera( PlayerController( goat.Controller ).PlayerCamera ).mCameraModes[ CM_ORBIT ] );
	oldOffset=goat.mCameraLookAtOffset;
	goat.mCameraLookAtOffset=GetDesiredCamLocation(goat)-goat.Location;
	orbitalCamera.mUseCameraBounce=false;
	orbitalCamera.mSupportsZoom=false;
	orbitalCamera.mCurrentZoomDistance=0;
	orbitalCamera.mDesiredZoomDistance=0;
	orbitalCamera.mMinZoomDistance=0;
	orbitalCamera.mMaxZoomDistance=0;
}

defaultproperties
{

}