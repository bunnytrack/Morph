class Morph expands Mutator;

var bool bInitialised;

function PreBeginPlay() {
	if (bInitialised) {
		return;
	}

	Level.Game.BaseMutator.AddMutator(self);
	bInitialised = true;
}

function Mutate(string MutateString, PlayerPawn Sender) {
	local string   Command, Action, param1, param2, param3;
	local Pawn     P;
	local TBossBot Bot;

	if (Sender.bAdmin) {

		// Split mutate string into action/parameter variables.
		SplitMutateString(MutateString, Command, Action, param1, param2, param3);

		if (Command ~= "morph") {

			// If Action is p, param1 must be a player name.
			if (
				Action ~= "p" &&
				param1 != ""  &&
				param2 != ""
			) {
				P = GetPlayerByName(param1);

				// Match found; morph them.
				if (P != none) {
					Morph(P, param2, param3);
				} else {
					Sender.ClientMessage("No player name matches found for \"" $ param1 $ "\".");
				}

			} else {
				P = GetPawn(Sender);

				if (P != none) {
					Morph(P, Action, param1);
				}
			}

		} else if (
			Command ~= "cheat" && // Run a cheat command on a player.
			Action != ""       && // Player name.
			param1 != ""          // The cheat command.
		) {
			P = GetPlayerByName(Action);

			if (P != none) {
				GiveCheat(PlayerPawn(P), param1);
			}
		}

		else if (!Sender.PlayerReplicationInfo.bIsSpectator && Command ~= "tele") {
			InstantTeleport(Sender);
		}

		// Make other players do stuff (taunt, speech, etc.)
		else if (Command ~= "puppet") {

			// Targetting a specific player.
			if (Action ~= "p") {

				// Try and get the specified player.
				P = GetPlayerByName(param1);

				// No matches, so stop here.
				if (P == none) {
					Sender.ClientMessage("Unable to find a player matching \"" $ param1 $ "\"");
					return;
				}

				// "Shift" variables along, as we're targetting a player.
				Action = param2;
				param1 = param3;
			}

			// If it's a say/speech command, parse it from MutateString as any
			// space-separated params get split up by SplitMutateString().
			switch (Action) {
				case "say":
				case "speech":
					param1 = Right(MutateString, Len(MutateString) - InStr(MutateString, Action $ " ") - Len(Action $ " "));
				break;

				default:
				break;
			}

			Puppet(Sender, PlayerPawn(P), Action, param1);
		}

		// Modify light properties of a player.
		else if (Command ~= "light") {
			// Targetting a specific player.
			if (Action ~= "p") {

				// Try and get the specified player.
				P = GetPlayerByName(param1);

				// No matches, so stop here.
				if (P == none) {
					Sender.ClientMessage("Unable to find a player matching \"" $ param1 $ "\"");
					return;
				}

				// "Shift" variables along, as we're targetting a player.
				Action = param2;
				param1 = param3;
			} else {
				P = Sender;
			}

			Illuminate(PlayerPawn(P), Action, param1);
		}

		// Spawn a mini robot.
		else if (Command ~= "helper") {

			// No action/params - just spawn the robot.
			if (Action == "") {

				// Spawn; set owner and tag (tag not currently used).
				Bot = Spawn(class'Botpack.TBossBot', Sender, 'BotBitch', Sender.Location + 72 * Vector(Sender.Rotation) + vect(0, 0, 1) * 15);

				// Set team and name.
				Bot.PlayerReplicationInfo.Team       = Sender.PlayerReplicationInfo.Team;
				Bot.PlayerReplicationInfo.PlayerName = Sender.PlayerReplicationInfo.PlayerName $ "'s Bitch";

				// Shrink it.
				Morph(Bot, "shrink");

				// Make it follow.
				Bot.SetOrders('Follow', Sender);

			}

			// Follow a specified player.
			else if (Action ~= "follow" && param1 != "") {
				P = GetPlayerByName(param1);

				if (P != none) {
					foreach AllActors(class'TBossBot', Bot, 'BotBitch') {
						Bot.PlayerReplicationInfo.Team       = P.PlayerReplicationInfo.Team;
						Bot.PlayerReplicationInfo.PlayerName = P.PlayerReplicationInfo.PlayerName $ "'s Bitch";
						Bot.SetOrders('Follow', P);
					}
				}
			}
		}
	}

	if (NextMutator != none) {
		NextMutator.Mutate(MutateString, Sender);
	}
}

// to-do: player only (not spec)
function InstantTeleport(PlayerPawn P) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;

	if (Level.NetMode != NM_Client) {
		if (Pawn(P.ViewTarget) == None) {
			GetAxes(P.ViewRotation, X, Y, Z);

			StartTrace = P.Location + P.EyeHeight * vect(0, 0, 1);
			EndTrace   = StartTrace + X * 10000;

			Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

			if (HitLocation != vect(0, 0, 0)) {
				P.PlaySound(Sound'UnrealShare.Generic.RespawnSound');
				SpawnTeleportEffectStart(P, HitLocation);

				P.SetLocation(HitLocation + HitNormal * 5);
				SpawnTeleportEffectDest(P);
			}
		}
	}
}

function SpawnTeleportEffectStart(PlayerPawn P, vector Dest) {
	local actor e;

	e = Spawn(class'TranslocOutEffect',,, P.Location, P.Rotation);

	e.Mesh         = P.Mesh;
	e.Animframe    = P.Animframe;
	e.Animsequence = P.Animsequence;
	e.Velocity     = 900 * Normal(Dest - P.Location);
	e.LightRadius  = 12;

	if (P.PlayerReplicationInfo.Team == 1) {
		e.Texture  = Texture'Botpack.Translocator.Tranglowb';
	} else {
		e.LightHue = 0;
	}
}

/**
 * Spawn custom teleport effect at teleport destination
 */
function SpawnTeleportEffectDest(PlayerPawn P) {
	local PawnTeleportEffect PTE;

	PTE = Spawn(class'PawnTeleportEffect',,, P.Location - P.CollisionHeight / 2 * vect(0, 0, 1));

	if (P.PlayerReplicationInfo.Team == 1) {
		PTE.Skin     = Texture'UnrealShare.DispExpl.dseb_A00';
		PTE.Texture  = Texture'UnrealShare.DispExpl.dseb_A00';
	} else {
		PTE.LightHue = 0;
	}
}

function Illuminate(PlayerPawn P, optional string Param1, optional string Param2) {
	switch (Param1) {
		// Disable lighting on this player.
		case "off":
			P.LightType = LT_None;
		break;

		default:
			// Always set these lighting properties.
			P.LightType        = LT_Steady;
			P.LightEffect      = LE_NonIncidence;
			P.LightBrightness  = 96;
			P.LightRadius      = 32;
			P.LightPeriod      = 32;
			P.LightCone        = 128;
			P.VolumeBrightness = 64;

			// No parameters set - just light the player with normal lighting.
			if (Param1 == "") {
				P.LightSaturation = 255;
			}

			// Bring saturation down to 0 to make the colour more vivid.
			else {
				P.LightSaturation = 0;

				// Check Param1 again to set the chosen colour.
				switch (Param1) {
					case "hue":
						if (int(Param2) >= 0 && int(Param2) <= 255) {
							P.LightHue = int(Param2);
						}
					break;

					case "brightness":
						P.LightBrightness = int(Param2);
					break;

					case "saturation":
						P.LightSaturation = int(Param2);
					break;

					case "red":
						P.LightHue = 0;
					break;

					case "orange":
						P.LightHue = 20;
					break;

					case "yellow":
						P.LightHue = 35;
					break;

					case "green":
						P.LightHue = 80;
					break;

					case "blue":
						P.LightHue = 160;
					break;

					case "purple":
						P.LightHue = 200;
					break;

					case "pink":
						P.LightHue = 235;
					break;

					default:
					break;
				}
			}
		break;
	}
}

/**
 * Make players do things: jump, say, taunt, feign death, etc.
 */
function Puppet(PlayerPawn Sender, optional PlayerPawn ThePuppet, optional string Command, optional string Action) {
	local PlayerPawn P;
	local int SpeechType, SpeechIndex, SpeechCallsign, ShakeDuration;
	local Inventory Inv;

	switch (Command) {
		case "jumpz":
			if (ThePuppet != none) {
				if (Action == "") {
					Sender.ClientMessage("Missing parameter for JumpZ or \"reset\"");
				} else if (Action == "reset") {
					ThePuppet.JumpZ = 325;
				} else {
					Sender.ClientMessage("Setting " $ ThePuppet.PlayerReplicationInfo.PlayerName $ "'s JumpZ to " $ int(Action));
					ThePuppet.JumpZ = int(Action);
				}
			}
		break;

		case "allammo":
			if (ThePuppet != none) {
				for (Inv = ThePuppet.Inventory; Inv != none; Inv = Inv.Inventory) {
					if (Ammo(Inv) != none) {
						Ammo(Inv).AmmoAmount = 999;
						Ammo(Inv).MaxAmmo    = 999;
					}
				}
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					for (Inv = P.Inventory; Inv != none; Inv = Inv.Inventory) {
						if (Ammo(Inv) != none) {
							Ammo(Inv).AmmoAmount = 999;
							Ammo(Inv).MaxAmmo    = 999;
						}
					}
				}
			}
		break;

		case "f5":
			if (ThePuppet != none && Action != "") {
				P = PlayerPawn(GetPlayerByName(Action));

				if (P != none) {
					ThePuppet.ViewTarget = P;
					ThePuppet.ViewTarget.BecomeViewTarget();
					ThePuppet.bBehindView = true;
				}
			} else {
				Sender.ClientMessage("Missing player name.");
			}
		break;

		case "shake":
			// Action may be specified as the shake duration.
			// Default to 1 second if unset.
			if (Action != "" && int(Action) > 0) {
				ShakeDuration = int(Action);
			} else {
				ShakeDuration = 1;
			}

			if (ThePuppet != none) {
				ThePuppet.ShakeView(ShakeDuration, 5000, 5000);
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.ShakeView(ShakeDuration, 5000, 5000);
				}
			}
		break;

		case "suicide":
			if (ThePuppet != none) {
				ThePuppet.Suicide();
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.Suicide();
				}
			}
		break;

		case "fire":
			if (ThePuppet != none) {
				ThePuppet.Fire();
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.Fire();
				}
			}
		break;

		case "altfire":
			if (ThePuppet != none) {
				ThePuppet.AltFire();
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.AltFire();
				}
			}
		break;

		case "jump":
			if (ThePuppet != none) {
				ThePuppet.DoJump();
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.DoJump();
				}
			}
		break;

		case "say":
			if (ThePuppet != none) {
				ThePuppet.PlayChatting();
				ThePuppet.Say(Action);
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.PlayChatting();
					P.Say(Action);
				}
			}
		break;

		case "taunt":
			if (ThePuppet != none) {
				ThePuppet.ConsoleCommand("taunt " $ Action);
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.ConsoleCommand("taunt " $ Action);
				}
			}
		break;

		case "speech":
			GetSpeech(Action, SpeechType, SpeechIndex, SpeechCallsign);

			if (ThePuppet != none) {
				ThePuppet.Speech(SpeechType, SpeechIndex, SpeechCallsign);
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.Speech(SpeechType, SpeechIndex, SpeechCallsign);
				}
			}
		break;

		case "death":
			if (ThePuppet != none) {
				ThePuppet.FeignDeath();
			} else {
				foreach AllActors(class'PlayerPawn', P) {
					P.FeignDeath();
				}
			}
		break;

		default:
			Sender.ClientMessage("Unrecognised command \"" $ Command $ "\"");
		break;
	}
}

/**
 * Convert a speech command string into integers.
 * e.g. string "0 2 0" -> int 0, int 2, int 0
 */
function GetSpeech(
	string Command,  // Speech command, e.g. 0 2 0
	out int Type,    // Taunt, order, etc.
	out int Index,   // Which taunt, order, etc.
	out int Callsign // Not sure what this does.
) {
	local int i;

	// Find the string position of the first space, then assign
	// whatever's to the left of it as the first number.
	// Repeat this for each speech parameter.

	// Firstly, safeguard against bad parameters (e.g. "0" or "0 0").
	// If there are no spaces, the while loop will crash the game.
	if (InStr(Command, " ") == -1) return;

	// Get the speech type.
	while (Mid(Command, i, 1) != " ") {
		i++;
	}

	Type = int(Left(Command, i));

	// Remove first speech param from the string.
	Command = Mid(Command, i + 1);

	// Safeguard again.
	if (InStr(Command, " ") == -1) return;

	// Reset string position.
	i = 0;

	// Set the speech index.
	while (Mid(Command, i, 1) != " ") {
		i++;
	}

	Index   = int(Left(Command, i));
	Command = Mid(Command, i + 1);

	// Finally set the speech callsign.
	// Whatever's left of the Command string is the last param.
	Callsign = int(Command);
}


/**
 * --------------------------------------------------------------------
 * Morph a Pawn.
 * --------------------------------------------------------------------
 * "Morph" actions include:
 *   - increasing/decreasing size/collision
 *   - changing mesh/skin
 * --------------------------------------------------------------------
 */
function Morph(Pawn P, string MorphAction, optional string param2) {
	local class<actor> NewClass;
	local bool         bSuccess;
	local float        ScaleFactor;

	bSuccess = true;

	switch (MorphAction) {
		// Reset player/weapon drawscale.
		// to-do: reset skin/textures
		case "reset":
			P.Drawscale = P.default.Drawscale;
			P.SetCollisionSize(P.default.CollisionRadius, P.default.CollisionHeight);
			P.Weapon.ThirdPersonScale = P.Weapon.default.ThirdPersonScale;
		break;

		// Increase/decrease the size of the pawn.
		case "grow":
		case "shrink":
			// param2 is blank; just increase/decrease the size.
			if (param2 == "") {
				if (MorphAction == "grow") {
					ScaleFactor = 1.5;
				} else {
					ScaleFactor = 0.5;
				}
			}

			// Scale factor specified; use this instead.
			else {
				ScaleFactor = float(param2);
			}

			// Adjust pawn size.
			P.Drawscale = P.Drawscale * ScaleFactor;
			P.SetCollisionSize(P.CollisionRadius * ScaleFactor, P.CollisionHeight * ScaleFactor);

			// Adjust weapon if possible.
			if (P.Weapon != none) {
				P.Weapon.ThirdPersonScale = P.Weapon.ThirdPersonScale * ScaleFactor;
			}

		break;

		case "cow":
		case "nali":
		case "skaarj":
			if (param2 == "") {
				param2 = string(P.PlayerReplicationInfo.Team);
			}

			switch (MorphAction) {
				case "cow":
					P.Mesh = Mesh(DynamicLoadObject("EpicCustomModels.TCowMesh", class'mesh'));

					switch (Rand(2)) {
						// War Cow
						case 0:
							P.MultiSkins[1] = Texture(DynamicLoadObject("TCowMeshSkins.WarCow", class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TCowMeshSkins.WarCowFace", class'texture'));
						break;

						// Atomic Cow
						case 1:
							P.MultiSkins[1] = Texture(DynamicLoadObject("TCowMeshSkins.AtomicCow", class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TCowMeshSkins.AtomicCowFace", class'texture'));
						break;
					}

					P.MultiSkins[2] = Texture(DynamicLoadObject("TCowMeshSkins.T_cow_" $ param2, class'texture'));

				break;

				case "nali":
					P.Mesh = Mesh(DynamicLoadObject("EpicCustomModels.TNaliMesh", class'mesh'));

					switch (Rand(2)) {
						// Ouboudah
						case 0:
							P.MultiSkins[0] = Texture(DynamicLoadObject("TNaliMeshSkins.T_Nali_" $ param2, class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TNaliMeshSkins.Nali-Face", class'texture'));
						break;

						// Priest
						case 1:
							P.MultiSkins[0] = Texture(DynamicLoadObject("TNaliMeshSkins.Priest", class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TNaliMeshSkins.Priest-Face", class'texture'));
						break;
					}

				break;

				case "skaarj":
					P.Mesh = Mesh(DynamicLoadObject("EpicCustomModels.TSkM", class'mesh'));

					switch (Rand(3)) {
						// Arena Warrior
						case 0:
							P.MultiSkins[1] = Texture(DynamicLoadObject("TSkMSkins.Warr2Berserker", class'texture'));
							P.MultiSkins[2] = Texture(DynamicLoadObject("TSkMSkins.warr3T_" $ param2, class'texture'));
							P.MultiSkins[3] = Texture(DynamicLoadObject("TSkMSkins.warr4T_" $ param2, class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TSkMSkins.warr5Berserker", class'texture'));
						break;

						// Pit Fighter
						case 1:
							P.MultiSkins[1] = Texture(DynamicLoadObject("TSkMSkins.PitF2Skrilax", class'texture'));
							P.MultiSkins[2] = Texture(DynamicLoadObject("TSkMSkins.PitF3T_" $ param2, class'texture'));
							P.MultiSkins[3] = Texture(DynamicLoadObject("TSkMSkins.PitF4T_" $ param2, class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TSkMSkins.PitF5Skrilax", class'texture'));
						break;

						// Cyborg Trooper
						case 2:
							P.MultiSkins[1] = Texture(DynamicLoadObject("TSkMSkins.MekS2Firewall", class'texture'));
							P.MultiSkins[2] = Texture(DynamicLoadObject("TSkMSkins.MekS3T_" $ param2, class'texture'));
							P.MultiSkins[3] = Texture(DynamicLoadObject("TSkMSkins.MekS4T_" $ param2, class'texture'));
							P.PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject("TSkMSkins.MekS5Firewall", class'texture'));
						break;
					}
				break;
			}

		break;

		default:
			NewClass = class<actor>(DynamicLoadObject(MorphAction, class'Class'));

			if (NewClass != none) {
				P.AnimSequence  = NewClass.Default.AnimSequence;
				P.Mesh          = NewClass.Default.Mesh;
				P.MultiSkins[0] = NewClass.Default.Skin;
			} else {
				bSuccess = false;
			}

		break;
	}

	if (bSuccess) {
		Spawn(class'UnrealShare.ParticleBurst',,, P.Location);
	}
}

/**
 * --------------------------------------------------------------------
 * Emulate a cheat command on a given player.
 * --------------------------------------------------------------------
 * Cheat functions are copied from PlayerPawn.uc instead of invoking
 * them via P.God(), P.Ghost(), etc. as they would fail bAdmin check.
 * --------------------------------------------------------------------
 */
function GiveCheat(PlayerPawn P, string Cheat) {
	switch (Cheat) {
		case "god":
			if (P.ReducedDamageType == 'All') {
				P.ReducedDamageType = '';
				P.ClientMessage("God mode off");
				return;
			}

			P.ReducedDamageType = 'All';
			P.ClientMessage("God Mode on");
		break;

		case "fly":
			P.bCollideWorld  = true;
			P.UnderWaterTime = P.Default.UnderWaterTime;
			P.SetCollision(true, true, true);
			P.GotoState('CheatFlying');
			P.ClientMessage("You feel much lighter");
		break;

		case "ghost":
			P.bCollideWorld  = false;
			P.UnderWaterTime = -1;
			P.SetCollision(false, false, false);
			P.GotoState('CheatFlying');
			P.ClientMessage("You feel ethereal");
		break;

		case "walk":
			P.SetPhysics(PHYS_Walking);
			P.PlayWaiting();
			P.SetCollision(true, true, true);

			P.bCollideWorld  = true;
			P.BaseEyeHeight  = P.Default.BaseEyeHeight;
			P.UnderWaterTime = P.Default.UnderWaterTime;
			P.EyeHeight      = P.BaseEyeHeight;
			P.Acceleration   = vect(0, 0, 0);
			P.Velocity       = vect(0, 0, 0);

			if (P.Region.Zone.bWaterZone && P.PlayerRestartState == 'PlayerWalking') {
				if (P.HeadRegion.Zone.bWaterZone) {
					P.PainTime = P.UnderWaterTime;
				}

				P.SetPhysics(PHYS_Swimming);
				P.GotoState('PlayerSwimming');

			} else {
				P.GotoState('PlayerWalking');
			}
		break;

		default:
		break;
	}
}

/**
 * --------------------------------------------------------------------
 * Returns the Pawn currently targeted by Sender's crosshair.
 * --------------------------------------------------------------------
 */
function Pawn GetPawn(PlayerPawn Sender) {
	local Actor  HitActor;
	local Pawn   HitPawn;
	local vector X, Y, Z, HitLocation, HitNormal, EndTrace, StartTrace;

	GetAxes(Sender.ViewRotation, X, Y, Z);

	StartTrace = Sender.Location + Sender.EyeHeight * vect(0, 0, 1);
	EndTrace   = StartTrace + X * 10000;
	HitActor   = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	HitPawn    = Pawn(HitActor);

	return HitPawn;
}

/**
 * --------------------------------------------------------------------
 * Returns a Pawn matching a given search string.
 * --------------------------------------------------------------------
 */
function Pawn GetPlayerByName(string SearchString) {
	local PlayerPawn PP;

	// First, check for exact matches.
	foreach AllActors(class'PlayerPawn', PP) {
		if (PP.PlayerReplicationInfo.PlayerName == SearchString) {
			return PP;
		}
	}

	// No exact matches found, so check for partial matches.
	foreach AllActors(class'PlayerPawn', PP) {
		if (InStr(Caps(PP.PlayerReplicationInfo.PlayerName), Caps(SearchString)) != -1) {
			return PP;
		}
	}

	// No matches.
	return none;
}

/**
 * --------------------------------------------------------------------
 * Splits a space-separated mutate string into parameters.
 * --------------------------------------------------------------------
 */
function SplitMutateString(
	string mString,
	out string action,
	out string param1,
	out string param2,
	out string param3,
	out string param4
) {
	if (InStr(mString, " ") != -1) {
		action = Left(mString, InStr(mString, " "));
		param1 = Right(mString, Len(mString) - InStr(mString, " ") - 1);

		if (InStr(param1, " ") != -1) {
			param2 = Right(param1, Len(param1) - InStr(param1, " ") - 1);
			param1 = Left(param1, InStr(param1, " "));

			if (InStr(param2, " ") != -1) {
				param3 = Right(param2, Len(param2) - InStr(param2, " ") - 1);
				param2 = Left(param2, InStr(param2, " "));

				if (InStr(param3, " ") != -1) {
					param4 = Right(param3, Len(param3) - InStr(param3, " ") - 1);
					param3 = Left(param3, InStr(param3, " "));
				}
			}
		}
	} else {
		action = mString;
	}
}