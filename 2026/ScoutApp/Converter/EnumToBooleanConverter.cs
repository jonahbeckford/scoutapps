using Avalonia.Data.Converters;
using Avalonia.Data;
using System.Globalization;

namespace ScoutApp.Converter
{
    public class EnumToBooleanConverter : IValueConverter
    {
        public object Convert(object? value, System.Type targetType, object? parameter, CultureInfo culture)
        {
            if (value == null || parameter == null)
                return false;

            return value.Equals(parameter);
        }

        public object ConvertBack(object? value, System.Type targetType, object? parameter, CultureInfo culture)
        {
            if (value is bool isChecked && isChecked && parameter != null)
                return parameter;

            return BindingOperations.DoNothing; // Important for correct group behavior
        }
    }
}