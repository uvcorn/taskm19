// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:taskm/data/models/task_list_model.dart';
import 'package:taskm/data/models/task_model.dart';
import 'package:taskm/data/service/network_client.dart';
import 'package:taskm/data/utils/urls.dart';
import 'package:taskm/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:taskm/ui/widgets/snack_bar_message.dart';
import 'package:taskm/ui/widgets/task_card.dart';

class ProgressTaskScreen extends StatefulWidget {
  const ProgressTaskScreen({super.key});

  @override
  State<ProgressTaskScreen> createState() => _ProgressTaskScreenState();
}

class _ProgressTaskScreenState extends State<ProgressTaskScreen> {
  bool _getProgressTasksInProgress = false;
  List<TaskModel> _progressTaskList = [];
  @override
  void initState() {
    super.initState();
    _getAllProgressTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: _getProgressTasksInProgress == false,
        replacement: const CenteredCircularProgressIndicator(),
        child: ListView.separated(
          itemCount: _progressTaskList.length,
          itemBuilder: (context, index) {
            return TaskCard(
              taskStatus: TaskStatus.progress,
              taskModel: _progressTaskList[index],
              refreshList: _getAllProgressTaskList,
              onTaskChanged: _refreshTaskData,
              refreshCount: () {},
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ),
    );
  }

  Future<void> _refreshTaskData() async {
    await Future.wait([_getAllProgressTaskList()]);
  }

  Future<void> _getAllProgressTaskList() async {
    _getProgressTasksInProgress = true;
    setState(() {});
    final NetworkResponse response = await NetworkClient.getRequest(
      url: Urls.progressTaskListUrl,
    );
    if (response.isSuccess) {
      TaskListModel taskListModel = TaskListModel.fromJson(response.data ?? {});
      _progressTaskList = taskListModel.taskList;
    } else {
      showSnackBarMessage(context, response.errorMessage, true);
    }

    _getProgressTasksInProgress = false;
    setState(() {});
  }
}
