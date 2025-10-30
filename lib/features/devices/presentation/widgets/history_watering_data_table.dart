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
    final String formattedTime;
    if (historyWatering.startTime != null) {
      formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(historyWatering.startTime!);
      formattedTime = DateFormat('HH:mm').format(historyWatering.startTime!);
    } else {
      formattedDate = 'N/A';
      formattedTime = '';
    }

    return DataRow2(
      cells: <DataCell>[
        DataCell(
          Center(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12, 
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
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
