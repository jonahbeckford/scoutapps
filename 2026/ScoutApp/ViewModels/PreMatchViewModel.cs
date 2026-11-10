using System.Collections.Generic;
using CommunityToolkit.Mvvm.ComponentModel;
using ScoutApp.Converter;

namespace ScoutApp.ViewModels
{
    public partial class PreMatchViewModel : ObservableObject
    {
        [ObservableProperty]
        public int _TextSize = 20;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(PreMatchSummary))]
        [NotifyPropertyChangedFor(nameof(PreMatchQRCode))]
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
        [NotifyPropertyChangedFor(nameof(PreMatchSummary))]
        [NotifyPropertyChangedFor(nameof(PreMatchQRCode))]
        private int _MatchNumber = 1;

        partial void OnMatchNumberChanged(int value)
        {
            if (JsonToCSConverter.GetTeamNumberFromSchedule(value, SelectedAlliancePosition) is int scheduledTeamNumber)
                TeamNumber = scheduledTeamNumber;
        }

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(PreMatchSummary))]
        [NotifyPropertyChangedFor(nameof(PreMatchQRCode))]
        private int? _TeamNumber;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(PreMatchSummary))]
        [NotifyPropertyChangedFor(nameof(PreMatchQRCode))]
        private AlliancePosition? _SelectedAlliancePosition;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(PreMatchSummary))]
        [NotifyPropertyChangedFor(nameof(PreMatchQRCode))]
        private Alliance? _SelectedAlliance;

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

        public string PreMatchSummary
        {
            get
            {
                return $$"""
                Team Number: {{TeamNumber}}
                Match Number: {{MatchNumber}}
                Alliance Position: {{SelectedAlliancePosition}}
                Alliance: {{SelectedAlliance}}
                Scout Name: {{ScoutName}}
                """;
            }
        }

        public string PreMatchQRCode
        {
            get
            {
                return $$"""
                Team-{{TeamNumber}}
                Match-{{MatchNumber}}
                Alliance-{{SelectedAlliance}}
                """;
            }
        }

        public void NextMatch()
        {
            MatchNumber += 1;
        }
    }
}
