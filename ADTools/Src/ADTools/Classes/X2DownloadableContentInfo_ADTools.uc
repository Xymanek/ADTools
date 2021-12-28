class X2DownloadableContentInfo_ADTools extends X2DownloadableContentInfo;

delegate AD_TestDelegateTemplate();

exec function ForceRefreshGamepads()
{
    `ONLINEEVENTMGR.EnumGamepads_PC();
}

exec function AD_TestForceFeedback ()
{
	local ForceFeedbackWaveform Waveform;
	local WaveformSample Sample;
	local PlayerController PC;
	
	Sample.LeftAmplitude = 100;
	Sample.RightAmplitude = 100;

	Sample.LeftFunction = WF_LinearIncreasing;
	Sample.RightFunction = WF_LinearIncreasing;

	Sample.Duration = 2;

	Waveform = new class'ForceFeedbackWaveform';
	Waveform.Samples.AddItem(Sample);
	Waveform.bIsLooping = false;

	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
	PC.ForceFeedbackManager.PlayForceFeedbackWaveform(Waveform, none);
}

exec function AD_TestFindObject (string ObjectName)
{
	local Object o;

	o = FindObject(ObjectName, class'Object');
	GenericDumpObject(ObjectName, o, GetFuncName());
}

exec function AD_TestDLO (string ObjectName)
{
	local Object o;

	o = DynamicLoadObject(ObjectName, class'Object');
	GenericDumpObject(ObjectName, o, GetFuncName());
}

exec function AD_TestRGA (string ObjectName)
{
	local Object o;

	o = `CONTENT.RequestGameArchetype(ObjectName);
	GenericDumpObject(ObjectName, o, GetFuncName());
}


private function GenericDumpObject (string ObjectName, Object o, name LogCat)
{
	`log("===================",, LogCat);
	`log(`showvar(ObjectName),, LogCat);
	`log(`showvar(o != none),, LogCat);

	if (o != none)
	{
		`log(`showvar(o.Class.Name),, LogCat);
		`log(`showvar(PathName(o)),, LogCat);
		`log(`showvar(PathName(o.Outer)),, LogCat);
	}

	`log("===================",, LogCat);
}

exec function AD_GetClassByName (name ClassName)
{
	GenericDumpObject(string(ClassName), class'XComEngine'.static.GetClassByName(ClassName), GetFuncName());
}

exec function AD_GetClassDefaultObjectByName (name ClassName)
{
	GenericDumpObject(string(ClassName), class'XComEngine'.static.GetClassDefaultObjectByName(ClassName), GetFuncName());
}

exec function AD_PauseGC ()
{
	class'XComEngine'.static.PauseGC();

	`log("=========================== GC PAUSED ===========================",, 'AD_PauseGC');
}

exec function AD_UnpauseGC ()
{
	class'XComEngine'.static.UnpauseGC();

	`log("=========================== GC UNPAUSED ===========================",, 'AD_PauseGC');
}

exec function AD_DoesPackageExist (string Package)
{
	`log(Package @ string(XComEngine(class'XComEngine'.static.GetEngine()).DoesPackageExist(Package)),, GetFuncName());
}

exec function AD_GetClassDefaultObjects (name SearchClassName)
{
	local class SearchClass;
	local array<Object> arr;
	local Object o;

	`log("=======================================================" @ SearchClassName,, GetFuncName());

	SearchClass = class'XComEngine'.static.GetClassByName(SearchClassName);
	arr = class'XComEngine'.static.GetClassDefaultObjects(SearchClass);

	foreach arr(o)
	{
		`log(string(o.Class.Name) @ PathName(o),, GetFuncName());
	}

	`log("=======================================================",, GetFuncName());
}

exec function AD_DumpDLCBundles ()
{
	local DownloadableContentEnumerator DLCEnum;
	local OnlineContent Item;

	DLCEnum = class'Engine'.static.GetEngine().GetDLCEnumerator();

	`log("======================================================= BEGIN",, GetFuncName());

	foreach DLCEnum.DLCBundles(Item)
	{
		`log("=============",, GetFuncName());

		`log(`showvar(Item.ContentType),, GetFuncName());
		`log(`showvar(Item.FriendlyName),, GetFuncName());
		`log(`showvar(Item.Filename),, GetFuncName());
		`log(`showvar(Item.ContentPath),, GetFuncName());
		`log(`showvar(Item.bIsCorrupt),, GetFuncName());
		`log(`showvar(Item.ContentPackages.Length),, GetFuncName());
		`log(`showvar(Item.ContentFiles.Length),, GetFuncName());
		
		`log("=============",, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_DumpInstalledDLC ()
{
	local DownloadableContentManager DLCManager;
	local string Item;

	DLCManager = class'Engine'.static.GetEngine().GetDLCManager();

	`log("======================================================= BEGIN",, GetFuncName());

	foreach DLCManager.InstalledDLC(Item)
	{
		`log(Item,, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_DumpRequiredArchetypes ()
{
	local string s;

	`log("======================================================= BEGIN",, GetFuncName());

	foreach `CONTENT.RequiredArchetypes(s)
	{
		`log(s,, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_DumpMapContent ()
{
	local Object o;

	`log("======================================================= BEGIN",, GetFuncName());

	foreach `CONTENT.MapContent(o)
	{
		//GenericDumpObject(PathName(o), o, GetFuncName());
		`log(PathName(o),, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_DumpReferencer (string ObjectName)
{
	local ObjectReferencer Ref;
	local Object o;

	`log("======================================================= BEGIN",, GetFuncName());
	`log(ObjectName,, GetFuncName());

	Ref = ObjectReferencer(FindObject(ObjectName, class'ObjectReferencer'));

	foreach Ref.ReferencedObjects(o)
	{
		`log(PathName(o),, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_SpawnStaticMeshAtCamera (string ObjectPath)
{
	local DynamicSMActor_Spawnable Actor;
	local rotator CameraRotation;
	local vector CameraLocation;
	local StaticMesh Mesh;
	local WorldInfo World;

	Mesh = StaticMesh(DynamicLoadObject(ObjectPath, class'StaticMesh'));
	if (Mesh == none)
	{
		`log("Failed to load mesh" @ ObjectPath,, GetFuncName());
		return;
	}

	World = class'WorldInfo'.static.GetWorldInfo();

	World.GetALocalPlayerController().GetPlayerViewPoint(CameraLocation, CameraRotation);

	Actor = World.Spawn(class'DynamicSMActor_Spawnable');
	Actor.SetStaticMesh(Mesh);
	Actor.SetLocation(CameraLocation);

	`log(PathName(Actor) @ Actor.Location,, GetFuncName());
}

//exec function AD_TestConfigReading ()
//{
//	local Package p;
//
//	//p = Package'ADTools';
//	//p = new(None, 'ADTools_T', 0) class'Package' (Package'ADTools');
//	//p = new class'Package';
//	//p = new(none) class'Package';
//	//p = new(none, "ADTools_T") class'Package';
//	p = new(none, "ADTools_T") class'Package' (Package'ADTools');
//
//	GenericDumpObject("", p, 'AD_TestConfigReading');
//}

exec function AD_ListFramesWithObject (int ObjectID)
{
	local XComGameState_BaseObject StateObject;
	local XComGameStateContext Context;
	local XComGameState Frame;

	`log("======================================================= BEGIN",, GetFuncName());
	`log(`showvar(ObjectID),, GetFuncName());

	StateObject = `XCOMHISTORY.GetGameStateForObjectID(ObjectID);
	
	if (StateObject == none)
	{
		`log("Object not found",, GetFuncName());
	}
	else
	{
		while (StateObject != none)
		{
			Frame = StateObject.GetParentGameState();
			Context = Frame.GetContext();

			`log(Frame.HistoryIndex @ Context.Class.Name @ Context.SummaryString(),, GetFuncName());

			StateObject = StateObject.GetPreviousVersion();
		}
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_ListGameStateObjectsWithBaseClass (name ClassName)
{
	local XComGameState_BaseObject StateObject;
	local XComGameStateHistory History;
	local object IterItem;
	local class TheClass;

	`log("======================================================= BEGIN",, GetFuncName());
	`log(ClassName,, GetFuncName());

	TheClass = class'XComEngine'.static.GetClassByName(ClassName);
	
	if (TheClass == none)
	{
		`log("Failed to find the class" ,, GetFuncName());
		return;
	}

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(TheClass, IterItem)
	{
		StateObject = XComGameState_BaseObject(IterItem);
		`log(StateObject.ObjectID @ IterItem.Class.Name @ StateObject.GetMyTemplateName(),, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_DumpCampaignSettings ()
{
	local XComGameState_CampaignSettings CampaignSettings;
	
	`log("======================================================= BEGIN",, GetFuncName());

	CampaignSettings = XComGameState_CampaignSettings(class'XComGameStateHistory'.static.GetGameStateHistory().GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings', true));

	`log(`showvar(CampaignSettings.StartTime),, GetFuncName());
	`log(`showvar(CampaignSettings.GameIndex),, GetFuncName());
	`log(`showvar(CampaignSettings.DifficultySetting),, GetFuncName());
	`log(`showvar(CampaignSettings.LowestDifficultySetting),, GetFuncName());
	`log(`showvar(CampaignSettings.bIronmanEnabled),, GetFuncName());
	`log(`showvar(CampaignSettings.bTutorialEnabled),, GetFuncName());
	`log(`showvar(CampaignSettings.bXPackNarrativeEnabled),, GetFuncName());
	`log(`showvar(CampaignSettings.bIntegratedDLCEnabled),, GetFuncName());
	`log(`showvar(CampaignSettings.bSuppressFirstTimeNarrative),, GetFuncName());
	`log(`showvar(CampaignSettings.bCheatStart),, GetFuncName());
	`log(`showvar(CampaignSettings.bSkipFirstTactical),, GetFuncName());
	`log(`showvar(CampaignSettings.BizAnalyticsCampaignID),, GetFuncName());
	`log(`showvar(CampaignSettings.TLEInstalled),, GetFuncName());
	`log(`showvar(CampaignSettings.TacticalDifficulty),, GetFuncName());
	`log(`showvar(CampaignSettings.StrategyDifficulty),, GetFuncName());
	`log(`showvar(CampaignSettings.GameLength),, GetFuncName());

	`log("======================================================= END",, GetFuncName());
}

exec function AD_IterateCampaignSettings ()
{
	local XComGameState_CampaignSettings CampaignSettings;
	local XComGameStateHistory History;

	`log("======================================================= BEGIN",, GetFuncName());

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_CampaignSettings', CampaignSettings)
	{
		`log(`showvar(CampaignSettings.ObjectID) @ PathName(CampaignSettings),, GetFuncName());
	}

	`log("======================================================= END",, GetFuncName());
}

exec function AD_TestBasicSaveObject ()
{
	local AD_TestObj TestObj;
	local bool Success;

	TestObj = new class'AD_TestObj';
	TestObj.strTest = "bla bla bla bla 10";
	TestObj.iTest = 2;

	Success = class'Engine'.static.BasicSaveObject(TestObj, class'Engine'.static.GetEnvironmentVariable("USERPROFILE") $ "\\AdTestObj.bin", false, 1);
	`log(`showvar(Success),, GetFuncName());
}

exec function AD_TestBasicLoadObject ()
{
	local AD_TestObj TestObj;
	local bool Success;

	TestObj = new class'AD_TestObj';
	
	Success = class'Engine'.static.BasicLoadObject(TestObj, class'Engine'.static.GetEnvironmentVariable("USERPROFILE") $ "\\AdTestObj.bin", false, 1);

	`log(`showvar(Success),, GetFuncName());
	`log(`showvar(TestObj.strTest),, GetFuncName());
	`log(`showvar(TestObj.iTest),, GetFuncName());
}

exec function AD_GetEnvironmentVariable (string VariableName)
{
	`log(class'Engine'.static.GetEnvironmentVariable(VariableName),, GetFuncName());
}

exec function AD_DumpSpawnDistributionLists ()
{
	local XComTacticalMissionManager MissionManager;
	local SpawnDistributionListEntry CurrentEntry;
	local SpawnDistributionList CurrentList;

	local array<string> LineElements;
	local string Line;

	`log("=========================== BEGIN",, GetFuncName());

	MissionManager = `TACTICALMISSIONMGR;

	// Headers

	LineElements.AddItem("ListID");
	LineElements.AddItem("CharacterTemplate");
	LineElements.AddItem("MinForceLevel");
	LineElements.AddItem("MaxForceLevel");
	LineElements.AddItem("MaxCharactersPerGroup");
	LineElements.AddItem("SpawnWeight");
			
	JoinArray(LineElements, Line, ",");
	`log(Line,, GetFuncName());

	// Entries

	foreach MissionManager.SpawnDistributionLists(CurrentList)
	{
		foreach CurrentList.SpawnDistribution(CurrentEntry)
		{
			LineElements.Length = 0;

			LineElements.AddItem(string(CurrentList.ListID));
			LineElements.AddItem(string(CurrentEntry.Template));
			LineElements.AddItem(string(CurrentEntry.MinForceLevel));
			LineElements.AddItem(string(CurrentEntry.MaxForceLevel));
			LineElements.AddItem(string(CurrentEntry.MaxCharactersPerGroup));
			LineElements.AddItem(string(CurrentEntry.SpawnWeight));
			
			JoinArray(LineElements, Line, ",");
			`log(Line,, GetFuncName());
		}
	}

	`log("=========================== END",, GetFuncName());
}
