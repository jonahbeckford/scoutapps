using System.Collections.Generic;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace ScoutApp.ViewModels
{
    public partial class AutoViewModel : ObservableObject
    {
        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        public int _TextSize = 20;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        public int _HeadingsTextSize = 24;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        private AutoStartingPosition? _StartingPosition;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        private bool _AutoMove = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        private Climb2026? _AutoClimb;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
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
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
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

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        [NotifyPropertyChangedFor(nameof(AutoObstacles))]
        private bool _AutoBump = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        [NotifyPropertyChangedFor(nameof(AutoObstacles))]
        private bool _AutoTrench = false;

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
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        [NotifyPropertyChangedFor(nameof(AutoIntakes))]
        private bool _AutoIntakeDepot = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        [NotifyPropertyChangedFor(nameof(AutoIntakes))]
        private bool _AutoIntakeOutpost = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(AutoSummary))]
        [NotifyPropertyChangedFor(nameof(AutoQRCode))]
        [NotifyPropertyChangedFor(nameof(AutoIntakes))]
        private bool _AutoIntakeNeutralZone = false;

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

        public string AutoSummary
        {
            get
            {
                return $$"""
                Starting Position: {{StartingPosition}}
                Auto Move: {{AutoMove}}
                Auto Fuel Scored: {{AutoFuelScored}}
                Auto Fuel Missed: {{AutoFuelMissed}}
                Auto Bump: {{AutoBump}}
                Auto Trench: {{AutoTrench}}
                Auto Intake Depot: {{AutoIntakeDepot}}
                Auto Intake Outpost: {{AutoIntakeOutpost}}
                Auto Intake Neutral Zone: {{AutoIntakeNeutralZone}}
                Auto Climb: {{AutoClimb}}
                """;
            }
        }

        public string AutoQRCode
        {
            get
            {
                return $$"""
                StartingPosition-{{StartingPosition}}
                AutoMove-{{AutoMove}}
                AutoFuelScored-{{AutoFuelScored}}
                AutoFuelMissed-{{AutoFuelMissed}}
                AutoObstacles-{{AutoObstacles}}
                AutoIntakes-{{AutoIntakes}}
                AutoClimb-{{AutoClimb}}
                """;
            }
        }

        public void NextMatch()
        {
            StartingPosition = null;
            AutoMove = false;
            AutoFuelScored = 0;
            AutoFuelMissed = 0;
            AutoClimb = null;
            AutoBump = false;
            AutoTrench = false;
            AutoIntakeDepot = false;
            AutoIntakeOutpost = false;
            AutoIntakeNeutralZone = false;
        }

    }
}
