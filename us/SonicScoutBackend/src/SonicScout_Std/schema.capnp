#EDITABLE FILE FOR CHANGING APP OVER THE SEASONS

@0xff041fa19d4b5a6f;

# This section is used by capnproto-java only
using Java = import "/capnp/java.capnp";
$Java.package("com.example.squirrelscout.data.capnp");
$Java.outerClassname("Schema");

#2024 
struct RawMatchData {
  # Example: fieldName @numberInOrder : dataType
  # generic data 
  teamNumber @0 :Int16; #max team number limit is appox. 32000, 2^15
  teamName @1 :Text;
  matchNumber @2 :Int16;
  scouterName @3 :Text;
  allianceColor @4 :RobotPosition;

  # game specific | auto 
  startingPosition @5 :SPosition; #left, middle, right. Hide later
  wingNote1 @6 : Bool; #Will remove, add preplace coral
  wingNote2 @7 : Bool; #Will remove, add preplace coral
  wingNote3 @8 : Bool; #Will remove, add preplace coral
  centerNote1 @9 : Bool; #Will remove
  centerNote2 @10 : Bool; #Will remove
  centerNote3 @11 : Bool; #Will remove
  centerNote4 @12 : Bool; #Will remove
  centerNote5 @13 : Bool; #Will remove
  autoAmpScore @14 : Int16; #Will remove
  autoAmpMiss @15 : Int16; #Will remove
  autoSpeakerScore @16 : Int16; #Will remove
  autoSpeakerMiss @17 : Int16; #Will remove
  autoLeave @18 : Bool; 
  

  # game specific  teleop
  teleSpeakerScore @19 : Int16; #Will remove
  teleSpeakerMiss @20 : Int16; #Will remove
  teleAmpScore @21 : Int16; #Will remove
  teleAmpMiss @22 : Int16; #Will remove
  distance @23 : Text; #Will remove
  teleBreakdown @24: TBreakdown; #Will remove
  endgameClimb @25 : EClimb; #Will remove
  endgameTrap @26 : Bool;  #Will remove

  #Auto 2025
  preplacedCoral @27 : Bool; 
  autoCoralL4Score @28 : Int16;
  autoCoralL3Score @29 : Int16;
  autoCoralL2Score @30 : Int16;
  autoCoralL1Score @31 : Int16;
  autoProcessorScore @32 : Int16;
  autoProcessorMiss @33 : Int16;
  autoNetScore @34 : Int16;
  autoNetMiss @35 : Int16;
  autoCoralL4Miss @36 : Int16;
  autoCoralL3Miss @37 : Int16;
  autoCoralL2Miss @38 : Int16; 
  autoCoralL1Miss @39 : Int16;
  autoStartingPosition @40 : SPosition2025; 
  #Add dropdown for type of game piece pickup

  #Teleop/Endgame 2025
  teleOpCoralL4Score @41 : Int16;
  teleOpCoralL3Score @42 : Int16;
  teleOpCoralL2Score @43 : Int16;
  teleOpCoralL1Score @44 : Int16;
  teleOpProcessorScore @45 : Int16;
  teleOpProcessorMiss @46 : Int16;
  teleOpNetScore @47 : Int16;
  teleOpNetMiss @48 : Int16;
  robotPhoto @49 : Text;
  groundPickUp @50 : Bool;
  teleOpBreakdown @51 : TBreakdown2025;
  teleOpClimb @52 : EClimb2025;
  #TBA prematch and results sync
  teamNumber32 @53 :Int32; #teamNumber32 bc there will be 9 and a half digits available to enter. Should be good for next 10+ years
  
  
  


}

#Enum fields for "dropdown" methods which are categorical but not numerical
enum SPosition{
  ampSide @0; 
  center @1; 
  sourceSide @2; 
}

#Enum fields for "dropdown" methods which are categorical but not numerical
enum SPosition2025{
   left @0; 
  middle @1; 
  right @2; 
}

enum TBreakdown{
  none @0;
  tipped @1;
  mechanicalFailure @2;
  incapacitated @3;
  noteStuck @4;
}


enum TBreakdown2025{
  none @0;
  tipped @1;
  mechanicalFailure @2;
  incapacitated @3;
  gamePieceStuck @4;
}

enum EClimb{
  success @0;
  failed @1;
  didNotAttempt @2;
  harmony @3; 
  parked @4;
}


enum EClimb2025{
  success @0;
  failed @1;
  didNotAttempt @2;
  deepCage @3; 
  parked @4;
  shallowCage @5; 
}

enum RobotPosition {
  red1 @0;
  red2 @1;
  red3 @2;
  blue1 @3;
  blue2 @4;
  blue3 @5; 
}

struct MatchAndPosition {
  match @0 :Int16;
  position @1 :RobotPosition;
}

struct MaybeError {
  success @0: Bool;
  messageIfError @1 :Text;
}
