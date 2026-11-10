using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using Avalonia.Platform;
using ScoutApp.ViewModels;

namespace ScoutApp.Converter;

public static class JsonToCSConverter
{
    private const string DefaultScheduleAssetPath = "avares://ScoutApp/Assets/2026wamil.json";

    private static Dictionary<int, int[]> TeamsByMatch = [];

    public sealed class ScheduleJson
    {
        public List<ScheduleRecord>? Records { get; set; }
    }

    public sealed class ScheduleRecord
    {
        public string? CompLevel { get; set; }

        public int MatchNumber { get; set; }

        public int Red1 { get; set; }

        public int Blue1 { get; set; }

        public int Red2 { get; set; }

        public int Blue2 { get; set; }

        public int Red3 { get; set; }

        public int Blue3 { get; set; }
    }

    public static void LoadFromScheduleJson(string json)
    {
        Console.WriteLine("json parameter in LoadFromScheduleJson: " + json);
        using var dom = JsonDocument.Parse(json);
        var root = dom.RootElement;

        // read the "records" array from the root element
        if (!root.TryGetProperty("records", out var recordsElement))
        {
            Console.WriteLine("Failed to find 'records' property in JSON");
            return;
        }

        // for each element in the "records" array, convert it to a ScheduleRecord object and add it to a list.
        // we don't use a serializer ... instead we read each property at a time so the code is clear.
        var records = new List<ScheduleRecord>();
        foreach (var recordElement in recordsElement.EnumerateArray())
        {
            try
            {
                var record = new ScheduleRecord
                {
                    CompLevel = recordElement.GetProperty("comp_level").GetString(),
                    MatchNumber = recordElement.GetProperty("match_number").GetInt32(),
                    Red1 = recordElement.GetProperty("red1").GetInt32(),
                    Blue1 = recordElement.GetProperty("blue1").GetInt32(),
                    Red2 = recordElement.GetProperty("red2").GetInt32(),
                    Blue2 = recordElement.GetProperty("blue2").GetInt32(),
                    Red3 = recordElement.GetProperty("red3").GetInt32(),
                    Blue3 = recordElement.GetProperty("blue3").GetInt32()
                };
                records.Add(record);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to parse a schedule record: {ex}");
            }
        }

        // set TeamsByMatch based on the parsed records ... but skip any comp_level
        // that is not "qm" (qualifier match) since those are the only ones we care about for scouting.
        TeamsByMatch = [];
        foreach (var record in records)
        {
            if (record.CompLevel != "qm")
                continue;
            TeamsByMatch[record.MatchNumber] =
            [
                record.Red1, record.Red2, record.Red3,
                record.Blue1, record.Blue2, record.Blue3
            ];
        }
    }

    public static bool TryLoadDefaultSchedule()
    {
        try
        {
            var uri = new Uri(DefaultScheduleAssetPath);
            if (!AssetLoader.Exists(uri))
                return false;

            using var stream = AssetLoader.Open(uri);
            using var reader = new StreamReader(stream);
            LoadFromScheduleJson(reader.ReadToEnd());
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex);
            Console.WriteLine("Failed to load default schedule from assets.");
            return false;
        }
    }

    private static void EnsureLoaded()
    {
        if (TeamsByMatch.Count <= 0)
            TryLoadDefaultSchedule();
    }

    public static bool TryGetTeamNumber(int matchNumber, AlliancePosition alliance, out int teamNumber)
    {
        EnsureLoaded();
        teamNumber = default;

        if (!TeamsByMatch.TryGetValue(matchNumber, out int[]? teams) || teams.Length < 6)
            return false;

        int index = alliance switch
        {
            AlliancePosition.Red1 => 0,
            AlliancePosition.Red2 => 1,
            AlliancePosition.Red3 => 2,
            AlliancePosition.Blue1 => 3,
            AlliancePosition.Blue2 => 4,
            AlliancePosition.Blue3 => 5,
            _ => -1
        };

        if (index < 0)
            return false;

        teamNumber = teams[index];
        return true;
    }

    public static int? GetTeamNumberFromSchedule(int matchNumber, AlliancePosition? alliance)
    {
        if (alliance == null)
            return null;

        return TryGetTeamNumber(matchNumber, alliance.Value, out int teamNumber)
            ? teamNumber
            : null;
    }
}
