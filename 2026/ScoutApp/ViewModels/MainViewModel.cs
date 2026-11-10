using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System.Runtime.Serialization;

namespace ScoutApp.ViewModels
{
    public enum HeadingButtons
    {
        PreMatch,
        Auto,
        TeleOp,
        Endgame,
        PostMatch
    }

    public enum AlliancePosition
    {
        [EnumMember(Value = "Red 1")] Red1,
        [EnumMember(Value = "Red 2")] Red2,
        [EnumMember(Value = "Red 3")] Red3,
        [EnumMember(Value = "Blue 1")] Blue1,
        [EnumMember(Value = "Blue 2")] Blue2,
        [EnumMember(Value = "Blue 3")] Blue3
    }

    public enum Alliance
    {
        Red,
        Blue
    }

    public enum AutoStartingPosition
    {
        [EnumMember(Value = "Left Trench")] LeftTrench,
        [EnumMember(Value = "Left Bump")] LeftBump,
        [EnumMember(Value = "Center")] Center,
        [EnumMember(Value = "Right Bump")] RightBump,
        [EnumMember(Value = "Right Trench")] RightTrench
    }

    public enum Breakdown2026
    {
        [EnumMember(Value = "None")] None,
        [EnumMember(Value = "Tipped")] Tipped,
        [EnumMember(Value = "Mechanical Failure")] MechanicalFailure,
        [EnumMember(Value = "Connection Failure")] ConnectionFailure,
        [EnumMember(Value = "Disabled")] Disabled,
        [EnumMember(Value = "Beached on Fuel")] BeachedOnFuel,
        [EnumMember(Value = "Stuck on Bump")] StuckOnBump
    }

    public enum Climb2026
    {
        [EnumMember(Value = "Level 1")] Level1,
        [EnumMember(Value = "Level 2")] Level2,
        [EnumMember(Value = "Level 3")] Level3,
        [EnumMember(Value = "Failed")] Failed,
        [EnumMember(Value = "Did Not Attempt")] DidNotAttempt
    }

    public enum ClimbTimes
    {
        [EnumMember(Value = "0-10 Seconds")] _0to10Seconds,
        [EnumMember(Value = "10-20 Seconds")] _10to20Seconds,
        [EnumMember(Value = "20-30 Seconds")] _20to30Seconds,
        [EnumMember(Value = "30+ Seconds")] _30PlusSeconds
    }

    public enum BreakdownTimes
    {
        [EnumMember(Value = "0-15 Seconds")] _0to15Seconds,
        [EnumMember(Value = "15-30 Seconds")] _15to30Seconds,
        [EnumMember(Value = "30+ Seconds")] _30PlusSeconds
    }

    public partial class MainViewModel : ObservableObject
    {
        public PreMatchViewModel PreMatchVM { get; } = new PreMatchViewModel();

        public AutoViewModel AutoVM { get; } = new AutoViewModel();

        public TeleopViewModel TeleopVM { get; } = new TeleopViewModel();

        public PostMatchViewModel PostMatchVM { get; }

        public MainViewModel()
        {
            PostMatchVM = new(PreMatchVM, AutoVM, TeleopVM);

            PostMatchVM.NextMatchRequested += () => SelectedHeadingButton = HeadingButtons.PreMatch;
        }

        /*
                === OLD PREMATCH CODE ===


                partial void OnMatchNumberChanged(int value)
                {
                    if (JsonToCSConverter.GetTeamNumberFromSchedule(value, SelectedAlliancePosition) is int scheduledTeamNumber)
                        TeamNumber = scheduledTeamNumber;
                }
                partial void OnSelectedAlliancePositionChanged(AlliancePosition? value)
                {
                    if (JsonToCSConverter.GetTeamNumberFromSchedule(MatchNumber, value) is int scheduledTeamNumber)
                        TeamNumber = scheduledTeamNumber;

                    if (value == null)
                    {
                        SelectedAlliance = null;
                    }
                    else if (value is AlliancePosition.Red1 or AlliancePosition.Red2 or AlliancePosition.Red3)
                    {
                        SelectedAlliance = Alliance.Red;
                    }
                    else if (value is AlliancePosition.Blue1 or AlliancePosition.Blue2 or AlliancePosition.Blue3)
                    {
                        SelectedAlliance = Alliance.Blue;
                    }
                }
                [ObservableProperty]
                [NotifyPropertyChangedFor(nameof(Summary))]
                [NotifyPropertyChangedFor(nameof(QRCode1))]
                [NotifyPropertyChangedFor(nameof(MissingFields))]
                private string? _ScoutName;
                public List<string>? ScoutNames { get; } =
                [
                    "Mentor",
                    "Agriya Agarwal",
                    "Aki Peddireddy",
                    "Andrew Bogen",
                    "Aramis Carrender",
                    "Audrey Le",
                    "Audrey Taubensee",
                    "Blair Liebman",
                    "Bridgette Reinecke",
                    "Caleb Gilroy",
                    "Corbin Theaker",
                    "Damien Phan",
                    "Dhananjay Giridharan",
                    "Diganth Vijay Kumar",
                    "Elise Walters",
                    "Garrett Munson",
                    "Grayden Corkins",
                    "Hailey Rosenau",
                    "Jaxten Hammersmith",
                    "Jaxon Neilson",
                    "Jerry Gu",
                    "Krishang Gupta",
                    "Katharine Le",
                    "Manvik Karnati",
                    "Maria Lukongwa",
                    "Marin McClarty",
                    "Mette' Baldwin",
                    "Marvin Abraham",
                    "Michael Workneh",
                    "Mia Steffen",
                    "Pranav Alreja",
                    "Rayne Davis",
                    "Sophia Pucek",
                    "Tanishqa Raghumandala",
                    "Varshini Karthik",
                    "Viljami Baker"
                ];

                [ObservableProperty]
                [NotifyPropertyChangedFor(nameof(Summary))]
                [NotifyPropertyChangedFor(nameof(QRCode1))]
                private int _MatchNumber = 1;

                [ObservableProperty]
                [NotifyPropertyChangedFor(nameof(Summary))]
                [NotifyPropertyChangedFor(nameof(QRCode1))]
                private int? _TeamNumber;

                [ObservableProperty]
                [NotifyPropertyChangedFor(nameof(QRCode1))]
                [NotifyPropertyChangedFor(nameof(MissingFields))]
                private AlliancePosition? _SelectedAlliancePosition;

                [ObservableProperty]
                [NotifyPropertyChangedFor(nameof(Summary))]
                [NotifyPropertyChangedFor(nameof(QRCode1))]
                private Alliance? _SelectedAlliance;
         */


        [ObservableProperty]
        private HeadingButtons _SelectedHeadingButton = HeadingButtons.PreMatch;

        [RelayCommand]
        private void HeadingButton(HeadingButtons heading)
        {
            SelectedHeadingButton = heading;
        }

        [ObservableProperty]
        public int _TextSize = 20;

        [ObservableProperty]
        public int _HeadingsTextSize = 24;

        /*
        // ===== OLD AUTO =====

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        [NotifyPropertyChangedFor(nameof(MissingFields))]
        private AutoStartingPosition? _StartingPosition;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _AutoMove = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        [NotifyPropertyChangedFor(nameof(MissingFields))]
        private Climb2026? _AutoClimb;

        // ===== Auto Fuel =====

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private int _AutoFuelScored = 0;

        [RelayCommand]
        private void AutoScoredUp()
        {
            AutoFuelScored += 1;
        }
        [RelayCommand]
        private void AutoScoredDown()
        {
            AutoFuelScored -= 1;
            if (AutoFuelScored < 0)
                AutoFuelScored = 0;
        }

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private int _AutoFuelMissed = 0;

        [RelayCommand]
        private void AutoMissedUp()
        {
            AutoFuelMissed += 1;
        }
        [RelayCommand]
        private void AutoMissedDown()
        {
            AutoFuelMissed -= 1;
            if (AutoFuelMissed < 0)
                AutoFuelMissed = 0;
        }

        // ===== Auto Obstacles =====
        public string AutoObstacles
        {
            get
            {
                var obstacles = new List<string>(2);
                if (AutoBump) obstacles.Add("Bump");
                if (AutoTrench) obstacles.Add("Trench");
                return string.Join(",", obstacles);
            }
        }
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoObstacles))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _AutoBump = false;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoObstacles))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _AutoTrench = false;

        // ===== Auto Intakes =====
        public string AutoIntakes
        {
            get
            {
                var intakes = new List<string>(3);
                if (AutoIntakeDepot) intakes.Add("Depot");
                if (AutoIntakeNeutralZone) intakes.Add("NeutralZone");
                if (AutoIntakeOutpost) intakes.Add("Outpost");
                return string.Join(",", intakes);
            }
        }
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoIntakes))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _AutoIntakeDepot = false;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoIntakes))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _AutoIntakeOutpost = false;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoIntakes))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _AutoIntakeNeutralZone = false; */

        /* // ===== OLD TELEOP =====

        // ===== TeleOp Fuel =====
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private int _TeleOpFuelScored = 0;
        [RelayCommand]
        private void TeleOpScoredUp()
        {
            TeleOpFuelScored += 1;
        }
        [RelayCommand]
        private void TeleOpScoredDown()
        {
            TeleOpFuelScored -= 1;
            if (TeleOpFuelScored < 0)
                TeleOpFuelScored = 0;
        }
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private int _TeleOpFuelMissed = 0;
        [RelayCommand]
        private void TeleOpMissedUp()
        {
            TeleOpFuelMissed += 1;
        }
        [RelayCommand]
        private void TeleOpMissedDown()
        {
            TeleOpFuelMissed -= 1;
            if (TeleOpFuelMissed < 0)
                TeleOpFuelMissed = 0;
        }

        // ===== TeleOp Obstacles =====
        public string TeleOpObstacles
        {
            get
            {
                var obstacles = new List<string>(2);
                if (TeleOpBump) obstacles.Add("Bump");
                if (TeleOpTrench) obstacles.Add("Trench");
                return string.Join(",", obstacles);
            }
        }
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpObstacles))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _TeleOpBump = false;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpObstacles))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _TeleOpTrench = false;

        // ===== TeleOp Intakes =====
        public string TeleOpIntakes
        {
            get
            {
                var intakes = new List<string>(3);
                if (TeleOpIntakeDepot) intakes.Add("Depot");
                if (TeleOpIntakeNeutralZone) intakes.Add("NeutralZone");
                if (TeleOpIntakeOutpost) intakes.Add("Outpost");
                return string.Join(",", intakes);
            }
        }
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpIntakes))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _TeleOpIntakeDepot = false;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpIntakes))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _TeleOpIntakeOutpost = false;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpIntakes))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        private bool _TeleOpIntakeNeutralZone = false;

        // ===== ENDGAME =====
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpClimbTime))]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        [NotifyPropertyChangedFor(nameof(MissingFields))]
        private Climb2026? _TeleOpClimb;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        [NotifyPropertyChangedFor(nameof(MissingFields))]
        private ClimbTimes? _TeleOpClimbTime;
        [ObservableProperty]
        private bool _ShowClimbTimes = false;
        partial void OnTeleOpClimbChanged(Climb2026? value)
        {
            ShowClimbTimes = value is Climb2026.Level1 or Climb2026.Level2 or Climb2026.Level3;

            if (!ShowClimbTimes)
                TeleOpClimbTime = null;
        }

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        [NotifyPropertyChangedFor(nameof(MissingFields))]
        private Breakdown2026 _Breakdown = Breakdown2026.None;
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(Summary))]
        [NotifyPropertyChangedFor(nameof(QRCode1))]
        [NotifyPropertyChangedFor(nameof(MissingFields))]
        private BreakdownTimes? _BreakdownTime;
        [ObservableProperty]
        private bool _ShowBreakdownTimes = false;
        partial void OnBreakdownChanged(Breakdown2026 value)
        {
            ShowBreakdownTimes = value != Breakdown2026.None;

            if (!ShowBreakdownTimes)
                BreakdownTime = null;
        } */

        /* // ===== OLD POSTMATCH =====
        public string MissingFields
        {
            get
            {
                var missing = new List<string>();
                if (string.IsNullOrEmpty(PreMatchVM.ScoutName)) missing.Add("Scout Name");
                if (PreMatchVM.SelectedAlliancePosition == null) missing.Add("Alliance Position");
                if (AutoVM.StartingPosition == null) missing.Add("Starting Position");
                if (AutoVM.AutoClimb == null) missing.Add("Auto Climb");
                if (TeleopVM.TeleOpClimb == null) missing.Add("Endgame Climb");
                if (TeleopVM.TeleOpClimbTime == null && TeleopVM.TeleOpClimb != null && TeleopVM.TeleOpClimb != Climb2026.DidNotAttempt && TeleopVM.TeleOpClimb != Climb2026.Failed) missing.Add("Endgame Climb Time");
                if (TeleopVM.BreakdownTime == null && TeleopVM.Breakdown != Breakdown2026.None) missing.Add("Breakdown Time");
                if (missing.Count == 0) return string.Empty;
                return "Missing required fields:\n" + string.Join("\n", missing.Select(f => "  \u2022 " + f));
            }
        }

        [ObservableProperty]
        private bool showSummary = false;

        [RelayCommand]
        private void ToggleSummary()
        {
            ShowSummary = !ShowSummary;
        }

        public string Summary
        {
            get
            {
                return $$"""
{{PreMatchVM.PreMatchSummary}}
{{AutoVM.AutoSummary}}
{{TeleopVM.TeleopSummary}}
""";
            }
        }

        public Bitmap QRCode1
        {
            get
            {
                string textForQRCode =
                    $$"""
{{PreMatchVM.PreMatchQRCode}}
{{AutoVM.AutoQRCode}}
{{TeleopVM.TeleopQRCode}}
""";

                if (
                    SelectedHeadingButton != HeadingButtons.PostMatch ||
                    string.IsNullOrEmpty(PreMatchVM.ScoutName) ||
                    PreMatchVM.SelectedAlliancePosition == null ||
                    AutoVM.StartingPosition == null ||
                    TeleopVM.TeleOpClimb == null ||
                    AutoVM.AutoClimb == null ||
                    (TeleopVM.TeleOpClimbTime == null && TeleopVM.TeleOpClimb != null && TeleopVM.TeleOpClimb != Climb2026.DidNotAttempt && TeleopVM.TeleOpClimb != Climb2026.Failed) ||
                    (TeleopVM.BreakdownTime == null && TeleopVM.Breakdown != Breakdown2026.None)
                )
                {
                    using var stream = AssetLoader.Open(new Uri("avares://ScoutApp/Assets/cartman.jpg"));
                    return new Bitmap(stream);
                }

                using QRCodeGenerator qrGenerator = new();
                using QRCodeData qrCodeData = qrGenerator.CreateQrCode(textForQRCode, QRCodeGenerator.ECCLevel.Q);
                using PngByteQRCode qrCode = new(qrCodeData);
                byte[] data = qrCode.GetGraphic(20);
                return new Bitmap(new MemoryStream(data));
            }
        }

        [RelayCommand]
        private void NextMatch()
        {
            PreMatchVM.NextMatch();
            AutoVM.NextMatch();
            TeleopVM.NextMatch();
            ShowSummary = false;
            SelectedHeadingButton = HeadingButtons.PreMatch;
        } */
    }
}
