# Database

The VERY FIRST TIME you setup a laptop you will need:

```powershell
./dk SonicScout_Setup.Clean --backend-builds  --dksdk-source-code
./dk SonicScout_Setup.Develop compile-backend --next
```

To delete the database ... which is needed before a game day, do:

```
del C:\Users\melan\AppData\Local\sonic-scout\sqlite3.db
```

<!--
Start the scanner in the Visual Studio Code "Terminal":

```powershell
./dk SonicScout_Setup.Develop scanner --skip-fetch
```
-->

Start the scanner in the Visual Studio Code "Terminal" without compiling (RECOMMENDED for competition days):

```powershell
./dk SonicScout_Setup.Develop scanner --skip-fetch --quick
```

Opens the database in the Visual Studio Code "Terminal" without compiling:

```powershell
./dk SonicScout_Setup.Develop database --skip-fetch --quick
```

right click if copy pasting doesn't work
After ".quit" a csv file will be created. Right click the file and open with file explorer. 

<!--
```sql
.mode line
SELECT * FROM raw_match_data;
SELECT match_number, team_number,endgame_climb, tele_op_coral_l4_score FROM raw_match_data;
SELECT match_number, team_number,endgame_climb, tele_op_coral_l4_score FROM raw_match_data where team_number = 2930; 

.quit
```
-->

```sql
.mode csv
.output blahblah.csv
SELECT * FROM raw_match_data;
.quit
```

Installing Android SDK on another computer:

```
$env:ANDROID_HOME = "C:\work\android-sdk"
$env:JAVA_HOME = "C:\work\jdk"

cd .\2026\ScoutApp.Android\
dotnet build -t:InstallAndroidDependencies -f net8.0-android -p:AndroidSdkDirectory=c:\work\android-sdk -p:JavaSdkDirectory=c:\work\jdk -p:AcceptAndroidSdkLicenses=True


```