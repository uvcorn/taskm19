import 'package:taskm/data/models/task_status_count_models.dart';

class TaskStatusCountListModel {
  late final List<TaskStatusCountModel> statusCountList;
  late final String status;

  TaskStatusCountListModel.fromJson(Map<String, dynamic> jsonData) {
    status = jsonData['status'];
    if (jsonData['data'] != null) {
      List<TaskStatusCountModel> list = [];
      for (Map<String, dynamic> data in jsonData['data']) {
        list.add(TaskStatusCountModel.fromJson(data));
      }
      statusCountList = list;
    } else {
      statusCountList = [];
    }
  }
}
