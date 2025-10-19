extension DateTimeExtensions on DateTime {
  String? dateToDateForShow() {
    return '${getDayName()}  ${getMonthName()}  $year';
  }

  String? dateToTimeForShow() {
    return '$hour  $minute  $second';
  }

  String? toMainFormat() {
    return '$day  $month  $year';
  }

  String getMonthName() {
    switch (month) {
      case 1:
        return 'jan';
      case 2:
        return 'feb';
      case 3:
        return 'mar';
      case 4:
        return 'apr';
      case 5:
        return 'may';
      case 6:
        return 'jun';
      case 7:
        return 'jul';
      case 8:
        return 'aug';
      case 9:
        return 'sep';
      case 10:
        return 'oct';
      case 11:
        return 'nov';
      case 12:
        return 'dec';
    }
    return '';
  }

  String getDayName() {
    String dayName;
    switch (DateTime.wednesday) {
      case DateTime.monday:
        dayName = 'monday';
        break;
      case DateTime.tuesday:
        dayName = 'tuesday';
        break;
      case DateTime.wednesday:
        dayName = 'wednesday';
        break;
      case DateTime.thursday:
        dayName = 'thursday';
        break;
      case DateTime.friday:
        dayName = 'friday';
        break;
      case DateTime.saturday:
        dayName = 'saturday';
        break;
      case DateTime.sunday:
        dayName = 'sunday';
        break;
      default:
        dayName = '';
    }
    return dayName;
  }
}
