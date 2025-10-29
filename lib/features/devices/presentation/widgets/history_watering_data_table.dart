import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watering_app/features/devices/data/models/history_watering_model.dart';

class HistoryWateringDataSource extends DataTableSource {
  HistoryWateringDataSource({required this.historyWateringList});

  final List<HistoryWatering> historyWateringList;

  @override
  DataRow? getRow(int index) {
    final historyWatering = historyWateringList[index];
    final String formattedDate;
    if (historyWatering.startTime != null) {
      formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(historyWatering.startTime!);
    } else {
      formattedDate = 'N/A';
    }

    return DataRow2(
      cells: <DataCell>[
        DataCell(Center(child: Text(formattedDate))),
        DataCell(Center(child: Text(historyWatering.duration.toString()))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => historyWateringList.length;

  @override
  int get selectedRowCount => 0;
}
