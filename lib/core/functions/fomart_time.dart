String formatTimeTo12Hour(String timeString) {
  try {
    // Expected format: "16:30:00" or "16:30"
    final cleanTime = timeString.split('.').first; // removes milliseconds if any
    final parts = cleanTime.split(':');
    
    if (parts.length < 2) return timeString; // Return original if format is unexpected

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // Determine AM or PM
    String period = hour >= 12 ? "PM" : "AM";
    
    // Convert to 12-hour format
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12; // Midnight (0) or Noon (12) becomes 12

    // Format minute with leading zero (e.g., "0" becomes "00")
    final formattedMinute = minute.toString().padLeft(2, '0');

    return "$hour12:$formattedMinute $period";
  } catch (e) {
    return timeString; // Fallback if parsing fails
  }
}