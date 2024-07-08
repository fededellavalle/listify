class ListItem {
  String name;
  String type;
  bool addExtraTime;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  double ticketPrice;
  DateTime? selectedStartExtraDate;
  DateTime? selectedEndExtraDate;
  double? ticketExtraPrice;
  bool allowSublists;
  bool onlyWriteOwners;

  ListItem({
    required this.name,
    required this.type,
    required this.addExtraTime,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.selectedStartExtraDate,
    required this.selectedEndExtraDate,
    required this.ticketPrice,
    required this.ticketExtraPrice,
    required this.allowSublists,
    required this.onlyWriteOwners,
  });
}
