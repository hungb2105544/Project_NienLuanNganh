import 'package:flutter/material.dart';
import 'package:project/model/report/Report.dart';
import 'package:project/model/database/pocketbase.dart';

class ReportManager extends ChangeNotifier {
  List<Report> _reports = [];
  final DataBase productDataBase = DataBase();
  Report? _report;

  List<Report> get reports => _reports;
  Report? get report => _report;

  Future<void> fetchReports() async {
    try {
      final response =
          await productDataBase.pb.collection('reports').getFullList();
      if (response.isEmpty) {
        print('No reports found.');
        _reports = [];
      } else {
        _reports =
            response.map((item) => Report.fromJson(item.toJson())).toList();
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching reports: $e');
    }
  }

  Future<void> fetchReportById(String user_id) async {
    try {
      final response =
          await productDataBase.pb.collection('reports').getFullList(
                filter: "user_id = '$user_id'",
              );
      _reports =
          response.map((item) => Report.fromJson(item.toJson())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching report: $e');
    }
  }

  Future<void> addReport(Report report) async {
    try {
      if (report.title.trim().isEmpty || report.content.trim().isEmpty) {
        throw Exception('Title and content cannot be empty');
      }

      final reportData = report.toJson();
      print("Sending report data: $reportData"); // Debugging

      final response = await productDataBase.pb
          .collection('reports')
          .create(body: reportData); // FIXED

      print("Response from PocketBase: $response"); // Debugging

      final newReport = Report.fromJson(response.data);
      _reports.add(newReport);
      notifyListeners();
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    }
  }
}
