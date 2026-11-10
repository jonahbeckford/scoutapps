using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Avalonia.Media.Imaging;
using Avalonia.Platform;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using QRCoder;

namespace ScoutApp.ViewModels
{
    public partial class PostMatchViewModel : ObservableObject
    {
        private AutoViewModel _autoVM;
        private PreMatchViewModel _preMatchVM;
        private TeleopViewModel _teleopVM;

        public PostMatchViewModel(PreMatchViewModel preMatchVM, AutoViewModel autoVM, TeleopViewModel teleopVM)
        {
            _preMatchVM = preMatchVM;
            _autoVM = autoVM;
            _teleopVM = teleopVM;

            _preMatchVM.PropertyChanged += (_, args) =>
            {
                if (args.PropertyName == nameof(PreMatchViewModel.PreMatchSummary))
                    OnPropertyChanged(nameof(Summary));
                if (args.PropertyName == nameof(PreMatchViewModel.PreMatchQRCode))
                    OnPropertyChanged(nameof(QRCode1));
                if (args.PropertyName == nameof(PreMatchViewModel.ScoutName) || args.PropertyName == nameof(PreMatchViewModel.SelectedAlliancePosition))
                    OnPropertyChanged(nameof(MissingFields));
            };
            _autoVM.PropertyChanged += (_, args) =>
            {
                if (args.PropertyName == nameof(AutoViewModel.AutoSummary))
                    OnPropertyChanged(nameof(Summary));
                if (args.PropertyName == nameof(AutoViewModel.AutoQRCode))
                    OnPropertyChanged(nameof(QRCode1));
                if (args.PropertyName == nameof(AutoViewModel.StartingPosition) || args.PropertyName == nameof(AutoViewModel.AutoClimb))
                    OnPropertyChanged(nameof(MissingFields));
            };
            _teleopVM.PropertyChanged += (_, args) =>
            {
                if (args.PropertyName == nameof(TeleopViewModel.TeleopSummary))
                    OnPropertyChanged(nameof(Summary));
                if (args.PropertyName == nameof(TeleopViewModel.TeleopQRCode))
                    OnPropertyChanged(nameof(QRCode1));
                if (args.PropertyName == nameof(TeleopViewModel.TeleOpClimb) || args.PropertyName == nameof(TeleopViewModel.TeleOpClimbTime) || args.PropertyName == nameof(TeleopViewModel.Breakdown) || args.PropertyName == nameof(TeleopViewModel.BreakdownTime))
                    OnPropertyChanged(nameof(MissingFields));
            };
        }

        public event Action? NextMatchRequested;

        [ObservableProperty]
        public int _TextSize = 20;

        [ObservableProperty]
        public int _HeadingsTextSize = 24;

        public string MissingFields
        {
            get
            {
                var missing = new List<string>();
                if (string.IsNullOrEmpty(_preMatchVM.ScoutName)) missing.Add("Scout Name");
                if (_preMatchVM.SelectedAlliancePosition == null) missing.Add("Alliance Position");
                if (_autoVM.StartingPosition == null) missing.Add("Starting Position");
                if (_autoVM.AutoClimb == null) missing.Add("Auto Climb");
                if (_teleopVM.TeleOpClimb == null) missing.Add("Endgame Climb");
                if (_teleopVM.TeleOpClimbTime == null && _teleopVM.TeleOpClimb != null && _teleopVM.TeleOpClimb != Climb2026.DidNotAttempt && _teleopVM.TeleOpClimb != Climb2026.Failed) missing.Add("Endgame Climb Time");
                if (_teleopVM.BreakdownTime == null && _teleopVM.Breakdown != Breakdown2026.None) missing.Add("Breakdown Time");
                if (missing.Count == 0) return string.Empty;
                return "Missing required fields:\n" + string.Join("\n", missing.Select(f => "  \u2022 " + f));
            }
        }

        [ObservableProperty]
        private bool _ShowSummary = false;

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
{{_preMatchVM.PreMatchSummary}}
{{_autoVM.AutoSummary}}
{{_teleopVM.TeleopSummary}}
""";
            }
        }

        public Bitmap QRCode1
        {
            get
            {
                string textForQRCode =
                    $$"""
{{_preMatchVM.PreMatchQRCode}}
{{_autoVM.AutoQRCode}}
{{_teleopVM.TeleopQRCode}}
""";

                if (
                    string.IsNullOrEmpty(_preMatchVM.ScoutName) ||
                    _preMatchVM.SelectedAlliancePosition == null ||
                    _autoVM.StartingPosition == null ||
                    _teleopVM.TeleOpClimb == null ||
                    _autoVM.AutoClimb == null ||
                    (_teleopVM.TeleOpClimbTime == null && _teleopVM.TeleOpClimb != null && _teleopVM.TeleOpClimb != Climb2026.DidNotAttempt && _teleopVM.TeleOpClimb != Climb2026.Failed) ||
                    (_teleopVM.BreakdownTime == null && _teleopVM.Breakdown != Breakdown2026.None)
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
            _preMatchVM.NextMatch();
            _autoVM.NextMatch();
            _teleopVM.NextMatch();
            ShowSummary = false;
            NextMatchRequested?.Invoke();
        }
    }
}
