namespace ScoutApp.Converter
{
    using System;
    using System.Globalization;
    using System.Reflection;
    using System.Runtime.Serialization;
    using Avalonia.Data.Converters;

    public class EnumMemberValueConverter : IValueConverter
    {
        public object? Convert(object? value, Type? targetType, object? parameter, CultureInfo culture)
        {
            if (value == null) return null;

            var enumType = value.GetType();
            var enumValue = Enum.GetName(enumType, value);

            if (string.IsNullOrEmpty(enumValue))
                return value.ToString();

            var memberInfo = enumType.GetMember(enumValue)[0];
            var enumMemberAttribute = memberInfo.GetCustomAttribute<EnumMemberAttribute>();

            return enumMemberAttribute != null ? enumMemberAttribute.Value : enumValue;
        }

        public object? ConvertBack(object? value, Type? targetType, object? parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}