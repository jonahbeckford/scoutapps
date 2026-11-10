/*Java Page for all the logic behind the Auto Page*/
package com.example.squirrelscout_scouter.match_scouting_pages;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.ComponentActivity;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelStoreOwner;

import com.example.squirrelscout_scouter.MainApplication;
import com.example.squirrelscout_scouter.R;
import com.example.squirrelscout_scouter.ui.viewmodels.ScoutingSessionViewModel;
import com.example.squirrelscout_scouter.util.ScoutSingleton;

public class AutonomousActivity extends ComponentActivity implements View.OnClickListener {

    //Increment/decrement buttons
    Button speakerScoreIncrement, speakerScoreDecrement, speakerMissIncrement, speakerMissDecrement;
    
    Button autoCoralL4ScoreIncrement, autoCoralL4ScoreDecrement, ampMissInrecement, ampMissDecrement;

    Button autoCoralL3ScoreIncrement, autoCoralL3ScoreDecrement;

    Button autoCoralL2ScoreDecrement, autoCoralL2ScoreIncrement;

    Button autoCoralL1ScoreIncrement, autoCoralL1ScoreDecrement;

    Button autoCoralL4MissIncrement, autoCoralL4MissDecrement;

    Button autoCoralL3MissIncrement, autoCoralL3MissDecrement;

    Button autoCoralL2MissIncrement, autoCoralL2MissDecrement;

    Button autoCoralL1MissIncrement, autoCoralL1MissDecrement;

    Button autoProcessorScoreIncrement, autoProcessorMissDecrement;
    Button autoProcessorScoreDecrement, autoProcessorMissIncrement;

    Button autoNetScoreIncrement, autoNetScoreDecrement;

    Button autoNetMissIncrement, autoNetMissDecrement;



    

    TextView speakerScore, speakerMiss, autoCoralL4Score, ampMiss;

    //2025 auto
    CheckBox autoPreplacedCoral;
    TextView autoCoralL4Miss, autoCoralL3Score, autoCoralL3Miss;
    TextView autoCoralL2Score, autoCoralL2Miss, autoCoralL1Score, autoCoralL1Miss;

    TextView autoProcessorScore, autoProcessorMiss, autoNetScore, autoNetMiss;

    //robot position
    Button leftPosition, centerPosition, rightPosition;
    String robotPosition = "";

    //checkboxes
    CheckBox checkBox1, checkBox2, checkBox3, checkBox4, checkBox5, checkBox6, checkBox7, checkBox8, checkBox9, checkBox10, checkBox11;
    boolean wing1 = false;
    boolean wing2 = false;
    boolean wing3 = false;
    boolean center1 = false;
    boolean center2 = false;
    boolean center3 = false;
    boolean center4 = false;
    boolean center5 = false;
    int firstAutoPickup = -1;

    //Leave mobility
    Button yesLeave, noLeave;
    boolean leaveBool;

    //next Button
    Button nextButton;
    TextView info, title;
    View titleCard, firstCard, secondCard, mainCard;
    //Needed object in order to send data for QR code to generate
    private ScoutingSessionViewModel model;

    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
            //Set the xml file relative to this page
            setContentView(R.layout.autonomous_scouting);

            //Set's match number if this is a continuing session
        ScoutSingleton scoutSingleton = ScoutSingleton.getInstance();
        TextView label = (TextView) findViewById(R.id.textView3);
        label.setText("Match #" + scoutSingleton.getMatchNum() + "\n" + scoutSingleton.getRobotNum());

        // view model required
        ViewModelStoreOwner scoutingSessionViewModelStoreOwner = ((MainApplication) getApplication()).getScoutingSessionViewModelStoreOwner();
        model = new ViewModelProvider(scoutingSessionViewModelStoreOwner).get(ScoutingSessionViewModel.class);

        //speaker & amp scoring, Initializing all the variables listed above by connecting them to an
        //an xml object in the relative xml file

        autoCoralL3ScoreDecrement = (Button) findViewById(R.id.autoCoralL3ScoreDecrement);
        autoCoralL3ScoreDecrement.setOnClickListener(this);
        autoCoralL2ScoreIncrement = (Button) findViewById(R.id.autoCoralL2ScoreIncrement);
        autoCoralL2ScoreIncrement.setOnClickListener(this);
        autoCoralL2ScoreDecrement = (Button) findViewById(R.id.autoCoralL2ScoreDecrement);
        autoCoralL2ScoreDecrement.setOnClickListener(this);
        autoCoralL4ScoreIncrement = (Button) findViewById(R.id.autoCoralL4ScoreIncrement);
        autoCoralL4ScoreIncrement.setOnClickListener(this);
        autoCoralL4ScoreDecrement = (Button) findViewById(R.id.autoCoralL4ScoreDecrement);
        autoCoralL4ScoreDecrement.setOnClickListener(this);
        autoCoralL3ScoreIncrement = (Button) findViewById(R.id.autoCoralL3ScoreIncrement);
        autoCoralL3ScoreIncrement.setOnClickListener(this);
        autoCoralL1ScoreIncrement = (Button) findViewById(R.id.autoCoralL1ScoreIncrement);
        autoCoralL1ScoreIncrement.setOnClickListener(this);
        autoCoralL1ScoreDecrement = (Button) findViewById(R.id.autoCoralL1ScoreDecrement);
        autoCoralL1ScoreDecrement.setOnClickListener(this);

        autoCoralL4MissIncrement = (Button) findViewById(R.id.autoCoralL4MissIncrement);
        autoCoralL4MissIncrement.setOnClickListener(this);
        autoCoralL4MissDecrement = (Button) findViewById(R.id.autoCoralL4MissDecrement);
        autoCoralL4MissDecrement.setOnClickListener(this);

        autoCoralL3MissIncrement = (Button) findViewById(R.id.autoCoralL3MissIncrement);
        autoCoralL3MissIncrement.setOnClickListener(this);
        autoCoralL3MissDecrement = (Button) findViewById(R.id.autoCoralL3MissDecrement);
        autoCoralL3MissDecrement.setOnClickListener(this);

        autoCoralL2MissIncrement = (Button) findViewById(R.id.autoCoralL2MissIncrement);
        autoCoralL2MissIncrement.setOnClickListener(this);
        autoCoralL2MissDecrement = (Button) findViewById(R.id.autoCoralL2MissDecrement);
        autoCoralL2MissDecrement.setOnClickListener(this);

        autoCoralL1MissIncrement = (Button) findViewById(R.id.autoCoralL1MissIncrement);
        autoCoralL1MissIncrement.setOnClickListener(this);
        autoCoralL1MissDecrement = (Button) findViewById(R.id.autoCoralL1MissDecrement);
        autoCoralL1MissDecrement.setOnClickListener(this);


        autoProcessorScoreIncrement = (Button) findViewById(R.id.autoProcessorScoreIncrement);
        autoProcessorScoreIncrement.setOnClickListener(this);
        autoProcessorScoreDecrement = (Button) findViewById(R.id.autoProcessorScoreDecrement);
        autoProcessorScoreDecrement.setOnClickListener(this);
        autoProcessorMissIncrement = (Button) findViewById(R.id.autoProcessorMissIncrement);
        autoProcessorMissIncrement.setOnClickListener(this);
        autoProcessorMissDecrement = (Button) findViewById(R.id.autoProcessorMissDecrement);
        autoProcessorMissDecrement.setOnClickListener(this);



        autoNetScoreIncrement = (Button) findViewById(R.id.autoNetScoreIncrement);
        autoNetScoreIncrement.setOnClickListener(this);
        autoNetScoreDecrement = (Button) findViewById(R.id.autoNetScoreDecrement);
        autoNetScoreDecrement.setOnClickListener(this);
        autoNetMissIncrement = (Button) findViewById(R.id.autoNetMissIncrement);
        autoNetMissIncrement.setOnClickListener(this);
        autoNetMissDecrement = (Button) findViewById(R.id.autoNetMissDecrement);
        autoNetMissDecrement.setOnClickListener(this);





        //ampMiss = (TextView) findViewById(R.id.AmpMissedCounter);
        //ampMiss.setOnClickListener(this);

        //robot Position
        leftPosition = (Button) findViewById(R.id.Start_Left);
        leftPosition.setOnClickListener(this);
        centerPosition = (Button) findViewById(R.id.Start_Center);
        centerPosition.setOnClickListener(this);
        rightPosition = (Button) findViewById(R.id.Start_Right);
        rightPosition.setOnClickListener(this);

        //checkboxes
        checkBox1 = (CheckBox) findViewById(R.id.checkBox);
        checkBox1.setOnClickListener(this);
        checkBox2 = (CheckBox) findViewById(R.id.checkBox2);
        checkBox2.setOnClickListener(this);
        checkBox3 = (CheckBox) findViewById(R.id.checkBox3);
        checkBox3.setOnClickListener(this);
        checkBox4 = (CheckBox) findViewById(R.id.checkBox4);
        checkBox4.setOnClickListener(this);
        checkBox5 = (CheckBox) findViewById(R.id.checkBox5);
        checkBox5.setOnClickListener(this);
        checkBox6 = (CheckBox) findViewById(R.id.checkBox6);
        checkBox6.setOnClickListener(this);
        checkBox7 = (CheckBox) findViewById(R.id.checkBox7);
        checkBox7.setOnClickListener(this);
        checkBox8 = (CheckBox) findViewById(R.id.checkBox8);
        checkBox8.setOnClickListener(this);
        checkBox9 = (CheckBox) findViewById(R.id.checkBox9);
        checkBox9.setOnClickListener(this);
        checkBox10 = (CheckBox) findViewById(R.id.checkBox10);
        checkBox10.setOnClickListener(this);
        checkBox11 = (CheckBox) findViewById(R.id.checkBox11);
        checkBox11.setOnClickListener(this);

        //leave auto points
        yesLeave = (Button) findViewById(R.id.LEAVE_YES);
        yesLeave.setOnClickListener(this);
        noLeave = (Button) findViewById(R.id.LEAVE_NO);
        noLeave.setOnClickListener(this);

        //Buttons
        nextButton = (Button) findViewById(R.id.NEXT);
        nextButton.setOnClickListener(this);
        //...
        info = (TextView) findViewById(R.id.textView3);
        titleCard = (View) findViewById(R.id.headerView);
        mainCard = (View) findViewById(R.id.bodyView);
        firstCard = (View) findViewById(R.id.view3);
        secondCard = (View) findViewById(R.id.view4);
        title = (TextView) findViewById(R.id.textView2);

        // 2025 new fields
        autoPreplacedCoral = (CheckBox) findViewById(R.id.checkBox);;
        //autoCoralL3Miss = (TextView) findViewById(R.id.SpeakerScoredCounter);
        //autoCoralL2Miss = autoCoralL1Miss = (TextView) findViewById(R.id.SpeakerScoredCounter);
        //autoProcessorScore = autoProcessorMiss = autoNetScore = autoNetMiss = (TextView) findViewById(R.id.L3Label);

        autoCoralL4Score = (TextView) findViewById(R.id.autoCoralL4Score);
        autoCoralL4Score.setOnClickListener(this);
        autoCoralL4Miss = (TextView) findViewById(R.id.autoCoralL4Miss);
        autoCoralL3Score = (TextView) findViewById(R.id.autoCoralL3Score);
        autoCoralL3Score.setOnClickListener(this);
        autoCoralL3Miss = (TextView) findViewById(R.id.autoCoralL3Miss);
        autoCoralL3Miss.setOnClickListener(this);
        autoCoralL2Score = (TextView) findViewById(R.id.autoCoralL2Score);
        autoCoralL2Score.setOnClickListener(this);
        autoCoralL2Miss = (TextView) findViewById(R.id.autoCoralL2Miss);
        autoCoralL2Miss.setOnClickListener(this);
        autoCoralL1Score = (TextView) findViewById(R.id.autoCoralL1Score);
        autoCoralL1Score.setOnClickListener(this);
        autoCoralL1Miss = (TextView) findViewById(R.id.autoCoralL1Miss);
        autoCoralL1Miss.setOnClickListener(this);

        autoProcessorScore = (TextView) findViewById(R.id.autoProcessorScore);
        autoProcessorScore.setOnClickListener(this);
        autoProcessorMiss = (TextView) findViewById(R.id.autoProcessorMiss);
        autoProcessorMiss.setOnClickListener(this);


        autoNetScore = (TextView) findViewById(R.id.autoNetScore);
        autoNetScore.setOnClickListener(this);
        autoNetMiss = (TextView) findViewById(R.id.autoNetMiss);
        autoNetMiss.setOnClickListener(this);







        //ampMiss = (TextView) findViewById(R.id.AmpMissedCounter);
        //ampMiss.setOnClickListener(this);

        //start animation (Was not used in 2024 season but was used in 2023 off season)
        //animationStart();
    }

    public void onClick(View view){
        int clickedId = view.getId();

        if(clickedId == R.id.autoCoralL4ScoreIncrement){
            counterIncrementLogic(autoCoralL4Score);
        }
        else if(clickedId == R.id.autoCoralL4ScoreDecrement){
            counterDecrementLogic(autoCoralL4Score);
        }
        else if(clickedId == R.id.autoCoralL1ScoreIncrement){
            counterIncrementLogic(autoCoralL1Score);
        }
        else if(clickedId == R.id.autoCoralL1ScoreDecrement){
            counterDecrementLogic(autoCoralL1Score);
        }
        else if(clickedId == R.id.autoCoralL3ScoreIncrement){
            counterIncrementLogic(autoCoralL3Score);
        }
        else if(clickedId == R.id.autoCoralL3ScoreDecrement){
            counterDecrementLogic(autoCoralL3Score);
        }
        else if(clickedId == R.id.autoCoralL2ScoreIncrement){
            counterIncrementLogic(autoCoralL2Score);
        }
        else if(clickedId == R.id.autoCoralL2ScoreDecrement){
            counterDecrementLogic(autoCoralL2Score);
        }

        else if(clickedId == R.id.autoCoralL4MissIncrement) {
            counterIncrementLogic(autoCoralL4Miss);
        }

        else if(clickedId == R.id.autoCoralL4MissDecrement) {
            counterDecrementLogic(autoCoralL4Miss);
        }

        else if(clickedId == R.id.autoCoralL3MissIncrement) {
            counterIncrementLogic(autoCoralL3Miss);
        }

        else if(clickedId == R.id.autoCoralL3MissDecrement) {
            counterDecrementLogic(autoCoralL3Miss);
        }

        else if(clickedId == R.id.autoCoralL2MissIncrement) {
            counterIncrementLogic(autoCoralL2Miss);
        }

        else if(clickedId == R.id.autoCoralL2MissDecrement) {
            counterDecrementLogic(autoCoralL2Miss);
        }


        else if(clickedId == R.id.autoCoralL1MissIncrement) {
            counterIncrementLogic(autoCoralL1Miss);
        }

        else if(clickedId == R.id.autoCoralL1MissDecrement) {
            counterDecrementLogic(autoCoralL1Miss);
        }

        else if(clickedId == R.id.autoProcessorScoreIncrement) {
            counterIncrementLogic(autoProcessorScore);
        }

        else if(clickedId == R.id.autoProcessorScoreDecrement) {
            counterDecrementLogic(autoProcessorScore);
        }

        else if(clickedId == R.id.autoProcessorMissIncrement) {
            counterIncrementLogic(autoProcessorMiss);
        }

        else if(clickedId == R.id.autoProcessorMissDecrement) {
            counterDecrementLogic(autoProcessorMiss);
        }

        else if(clickedId == R.id.autoNetScoreIncrement) {
            counterIncrementLogic(autoNetScore);
        }

        else if(clickedId == R.id.autoNetScoreDecrement) {
            counterDecrementLogic(autoNetScore);
        }

        else if(clickedId == R.id.autoNetMissIncrement) {
            counterIncrementLogic(autoNetMiss);
        }

        else if(clickedId == R.id.autoNetMissDecrement) {
            counterDecrementLogic(autoNetMiss);
        }








        else if(clickedId == R.id.Start_Left){
            robotLeftLogic();
        }
        else if(clickedId == R.id.Start_Center){
            robotCenterLogic();
        }
        else if(clickedId == R.id.Start_Right){
            robotRightLogic();
        }
        else if(clickedId == R.id.LEAVE_YES){
            yesLeaveLogic();
        }
        else if(clickedId == R.id.LEAVE_NO){
            noLeaveLogic();
        }
        else if(clickedId == R.id.NEXT){
            animateButton((Button) view);
            nextPageLogic();
        }
        else if(view instanceof CheckBox){
            CheckBox checkBox = (CheckBox) view;
            if (checkBox.isChecked() && firstAutoPickup == -1) {
                // Store the ID of the first selected checkbox
                firstAutoPickup = clickedId;
                Log.d("checkbox", "picked" + firstAutoPickup);
            }
            else if(firstAutoPickup == clickedId){
                firstAutoPickup = -1;
                Log.d("checkbox", "picked" + firstAutoPickup);
            }
        }
    }

    //Robot position logic
    private void robotLeftLogic(){
        //if not selected
        if(leftPosition.getTextColors() != ContextCompat.getColorStateList(this, R.color.black2)){
            leftPosition.setTextColor(ContextCompat.getColor(this, R.color.black2));
            leftPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            centerPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            centerPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            rightPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            rightPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            robotPosition = "Amp Side";
            nextPageCheck();
        }
    }
    private void robotRightLogic(){
        ///if not selected
        if(rightPosition.getTextColors() != ContextCompat.getColorStateList(this, R.color.black2)){
            rightPosition.setTextColor(ContextCompat.getColor(this, R.color.black2));
            rightPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            centerPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            centerPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            leftPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            leftPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            robotPosition = "Source Side";
            nextPageCheck();
        }
    }
    private void robotCenterLogic(){
        //if not selected
        if(centerPosition.getTextColors() != ContextCompat.getColorStateList(this, R.color.black2)){
            centerPosition.setTextColor(ContextCompat.getColor(this, R.color.black2));
            centerPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            leftPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            leftPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            rightPosition.setTextColor(ContextCompat.getColor(this, R.color.white));
            rightPosition.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.darkGrey));
            robotPosition = "Center";
            nextPageCheck();
        }
    }

    //Leave mobility logic
    private void yesLeaveLogic(){
        //if not selected
        if(yesLeave.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            yesLeave.setTextColor(ContextCompat.getColor(this, R.color.white));
            yesLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            noLeave.setTextColor(ContextCompat.getColor(this, R.color.black2));
            noLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            leaveBool = true;
            nextPageCheck();
        }
    }
    private void noLeaveLogic(){
        //if not selected
        if(noLeave.getTextColors() != ContextCompat.getColorStateList(this, R.color.white)){
            noLeave.setTextColor(ContextCompat.getColor(this, R.color.white));
            noLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.green));
            yesLeave.setTextColor(ContextCompat.getColor(this, R.color.black2));
            yesLeave.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.error));
            leaveBool = false;
            nextPageCheck();
        }
    }

    //next page logic
    private void nextPageCheck(){
        //Check if the Leave Button and the starting position have been answer before moving
        if(yesLeave.getTextColors() != ContextCompat.getColorStateList(this, R.color.green) && !(robotPosition.isEmpty())){
            nextButton.setTextColor(ContextCompat.getColor(this, R.color.black));
            nextButton.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.accent));
            nextButton.setText("NEXT PAGE");
        }
    }
    private void nextPageLogic(){
        if(nextButton.getText().toString().equals("NEXT PAGE")){
            Toast.makeText(AutonomousActivity.this, "Going to Next Page", Toast.LENGTH_SHORT).show();
            // Create an Intent to launch the target activity
            Intent intent = new Intent(AutonomousActivity.this, TeleopActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            // Start the target activity with the Intent
            saveScoutInfo();
            startActivity(intent);
        }
    }

    //Counter increment and decrement logic
    private void counterIncrementLogic(TextView counter) {
        String matchString = counter.getText().toString();
        try {
            int num = Integer.parseInt(matchString);
            counter.setText(String.valueOf(num + 1));
        } catch (NumberFormatException e) {
            // Handle the case where the input string is not a valid integer
            // Display an error message or perform appropriate error handling
            e.printStackTrace();
        }
    }
    private void counterDecrementLogic(TextView counter) {
        String matchString = counter.getText().toString();
        try {
            int num = Integer.parseInt(matchString);
            if(num - 1 < 0){
                counter.setText("0");
            }else{
                counter.setText(String.valueOf(num - 1));
            }
        } catch (NumberFormatException e) {
            // Handle the case where the input string is not a valid integer
            // Display an error message or perform appropriate error handling
            e.printStackTrace();
        }
    }

    //user feedback when clicking button
    private void animateButton(Button button){
        button.animate().scaleXBy(0.025f).scaleYBy(0.025f).setDuration(250).setInterpolator(new AccelerateDecelerateInterpolator()).withEndAction(() -> {
            button.animate().scaleXBy(-0.025f).scaleYBy(-0.025f).setDuration(250);
        }).start();
    }
    //Method to actually save all the information from this page and send to QR object
    //Only get's called when the user is trying to go to the next button
    public void saveScoutInfo(){
        //Singleton object created just so data can be passed across pages easily
        ScoutSingleton singleton = ScoutSingleton.getInstance();

        if(checkBox1.getId() == firstAutoPickup || checkBox4.getId() == firstAutoPickup){
            singleton.setFirstPickup("W1");
        }
        else if(checkBox2.getId() == firstAutoPickup || checkBox5.getId() == firstAutoPickup){
            singleton.setFirstPickup("W2");
        }
        else if(checkBox3.getId() == firstAutoPickup || checkBox6.getId() == firstAutoPickup){
            singleton.setFirstPickup("W3");
        }
        else if(checkBox7.getId() == firstAutoPickup){
            singleton.setFirstPickup("C1");
        }
        else if(checkBox8.getId() == firstAutoPickup){
            singleton.setFirstPickup("C2");
        }
        else if(checkBox9.getId() == firstAutoPickup){
            singleton.setFirstPickup("C3");
        }
        else if(checkBox10.getId() == firstAutoPickup){
            singleton.setFirstPickup("C4");
        }
        else if(checkBox11.getId() == firstAutoPickup){
            singleton.setFirstPickup("C5");
        }
        else{
            singleton.setFirstPickup("");
        }

        if(checkBox1.isChecked() || checkBox4.isChecked()){
            wing1 = true;
        }
        if(checkBox2.isChecked() || checkBox5.isChecked()){
            wing2 = true;
        }
        if(checkBox3.isChecked() || checkBox6.isChecked()){
            wing3 = true;
        }

        //ScoutingSessionViewModel object which calls the .captureAutoData and then passes in the information
        //gathered form this page
        model.captureAutoData(
                robotPosition,
                wing1,
                wing2,
                wing3,
                checkBox7.isChecked(),
                checkBox8.isChecked(),
                checkBox9.isChecked(),
                checkBox10.isChecked(),
                checkBox11.isChecked(),
                0, //Integer.parseInt(ampScore.getText().toString()),
                0,//Integer.parseInt(ampMiss.getText().toString()),
                0, //Integer.parseInt(speakerScore.getText().toString()),
                0,//Integer.parseInt(speakerMiss.getText().toString()),
                leaveBool,
                //2025 captureAutoData
                autoPreplacedCoral.isChecked(),
                Integer.parseInt(autoCoralL4Score.getText().toString()),
                Integer.parseInt(autoCoralL4Miss.getText().toString()),
                Integer.parseInt(autoCoralL3Score.getText().toString()),
                Integer.parseInt(autoCoralL3Miss.getText().toString()),
                Integer.parseInt(autoCoralL2Score.getText().toString()),
                Integer.parseInt(autoCoralL2Miss.getText().toString()),
                Integer.parseInt(autoCoralL1Score.getText().toString()),
                Integer.parseInt(autoCoralL1Miss.getText().toString()),
                Integer.parseInt(autoProcessorScore.getText().toString()),
                Integer.parseInt(autoProcessorMiss.getText().toString()),
                Integer.parseInt(autoNetScore.getText().toString()),
                Integer.parseInt(autoNetMiss.getText().toString())
        );

    }
}
