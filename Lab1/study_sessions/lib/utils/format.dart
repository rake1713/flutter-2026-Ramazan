const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatTime(DateTime d) =>
    '${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${_twoDigits(d.inMinutes % 60)}m';
  return '${d.inMinutes} min';
}
