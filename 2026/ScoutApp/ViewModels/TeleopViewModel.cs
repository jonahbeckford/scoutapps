using System.Collections.Generic;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace ScoutApp.ViewModels
{
    public partial class TeleopViewModel : ObservableObject
    {
        [ObservableProperty]
        public int _TextSize = 20;

        // ===== Fuel =====
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
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
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
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

        // ===== Obstacles =====
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
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private bool _TeleOpBump = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpObstacles))]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private bool _TeleOpTrench = false;

        // ===== Intakes =====
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
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private bool _TeleOpIntakeDepot = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpIntakes))]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private bool _TeleOpIntakeOutpost = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpIntakes))]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private bool _TeleOpIntakeNeutralZone = false;

        // ===== ENDGAME =====
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleOpClimbTime))]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private Climb2026? _TeleOpClimb;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
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
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private Breakdown2026 _Breakdown = Breakdown2026.None;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(TeleopSummary))]
        [NotifyPropertyChangedFor(nameof(TeleopQRCode))]
        private BreakdownTimes? _BreakdownTime;

        [ObservableProperty]
        private bool _ShowBreakdownTimes = false;

        partial void OnBreakdownChanged(Breakdown2026 value)
        {
            ShowBreakdownTimes = value != Breakdown2026.None;

            if (!ShowBreakdownTimes)
                BreakdownTime = null;
        }

        public string TeleopSummary
        {
            get
            {
                return $$"""
                TeleOp Fuel Scored: {{TeleOpFuelScored}}
                TeleOp Fuel Missed: {{TeleOpFuelMissed}}
                TeleOp Bump: {{TeleOpBump}}
                TeleOp Trench: {{TeleOpTrench}}
                TeleOp Intake Depot: {{TeleOpIntakeDepot}}
                TeleOp Intake Outpost: {{TeleOpIntakeOutpost}}
                TeleOp Intake Neutral Zone: {{TeleOpIntakeNeutralZone}}
                Endgame Tower Climb: {{TeleOpClimb}}
                Endgame Climb Time: {{TeleOpClimbTime}}
                Breakdown: {{Breakdown}}
                Breakdown Time: {{BreakdownTime}}
                """;
            }
        }

        public string TeleopQRCode
        {
            get
            {
                return $$"""
                TeleOpFuelScored-{{TeleOpFuelScored}}
                TeleOpFuelMissed-{{TeleOpFuelMissed}}
                TeleOpObstacles-{{TeleOpObstacles}}
                TeleOpIntakes-{{TeleOpIntakes}}
                TowerClimb-{{TeleOpClimb}}
                ClimbTime-{{TeleOpClimbTime}}
                Breakdown-{{Breakdown}}
                BreakdownTime-{{BreakdownTime}}
                """;
            }
        }

        public void NextMatch()
        {
            TeleOpFuelScored = 0;
            TeleOpFuelMissed = 0;
            TeleOpBump = false;
            TeleOpTrench = false;
            TeleOpIntakeDepot = false;
            TeleOpIntakeOutpost = false;
            TeleOpIntakeNeutralZone = false;
            TeleOpClimb = null;
            TeleOpClimbTime = null;
            ShowClimbTimes = false;
            Breakdown = Breakdown2026.None;
            BreakdownTime = null;
            ShowBreakdownTimes = false;
        }
    }
}
