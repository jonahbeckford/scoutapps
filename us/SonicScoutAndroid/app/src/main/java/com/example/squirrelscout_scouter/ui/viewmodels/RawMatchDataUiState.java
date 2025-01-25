package com.example.squirrelscout_scouter.ui.viewmodels;

import org.immutables.value.Value;

/**
 * The UI state for raw match data obtained during a scouting session.
 *
 * It can be made immutable (a requirement for Android UI state) and
 * has the good Java citizen behaviors like proper equals/hashCode (with
 * the immutable) and can be converted to/from Capn' Proto (which is
 * part of the "data" layer model object).
 */
@Value.Immutable
@Value.Modifiable
public interface RawMatchDataUiState {

    String scoutName();

    String positionScouting();

    int matchScouting();

    int robotScouting();

    //auto
    String startingPosition();
    boolean wingNote1();
    boolean wingNote2();
    boolean wingNote3();
    boolean centerNote1();
    boolean centerNote2();
    boolean centerNote3();
    boolean centerNote4();
    boolean centerNote5();
    int autoAmpScore();
    int autoAmpMiss();
    int autoSpeakerScore();
    int autoSpeakerMiss();
    boolean autoLeave();
    boolean preplacedCoral();
    int autoCoralL4Score();
    int autoCoralL3Score();
    int autoCoralL2Score();
    int autoCoralL1Score();
    int autoProcessorScore();
    int autoProcessorMiss();
    int autoNetScore();
    int autoNetMiss();
    int autoCoralL4Miss();
    int autoCoralL3Miss();
    int autoCoralL2Miss();
    int autoCoralL1Miss();


    //teleop
    int teleSpeakerScore();
    int teleSpeakerMiss();
    int teleAmpScore();
    int teleAmpMiss();
    String teleRange();
    String teleBreakdown();
    String endgameClimb();
    boolean endgameTrap();
    String pickUpAbility();
}
