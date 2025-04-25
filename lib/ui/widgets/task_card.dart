// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskm/data/models/task_model.dart';
import 'package:taskm/data/service/network_client.dart';
import 'package:taskm/data/utils/urls.dart';
import 'package:taskm/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:taskm/ui/widgets/snack_bar_message.dart';

enum TaskStatus { sNew, progress, completed, cancelled }

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.taskStatus,
    required this.taskModel,
    required this.refreshList,
    this.refreshCount,
    required Future<void> Function() onTaskChanged,
  });

  final TaskStatus taskStatus;
  final TaskModel taskModel;
  final VoidCallback refreshList;
  final VoidCallback? refreshCount;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskModel.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(widget.taskModel.description),
            Text(
              'Date: ${_formatDate(widget.taskModel.createdDate)}',
            ), // Updated
            Row(
              children: [
                Chip(
                  label: Text(
                    widget.taskModel.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: _getStatusChipColor(),
                  side: BorderSide.none,
                ),
                const Spacer(),
                Visibility(
                  visible: _inProgress == false,
                  replacement: const CenteredCircularProgressIndicator(),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _deleteTask,
                        icon: const Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: _showUpdateStatusDialog,
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusChipColor() {
    late Color color;
    switch (widget.taskStatus) {
      case TaskStatus.sNew:
        color = Colors.blue;
      case TaskStatus.progress:
        color = Colors.purple;
      case TaskStatus.completed:
        color = Colors.green;
      case TaskStatus.cancelled:
        color = Colors.red;
    }
    return color;
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final String formattedDate = DateFormat(
        'dd-MM-yyyy hh:mm a',
      ).format(parsedDate);
      return formattedDate;
    } catch (e) {
      return date; // Return original date string if parsing fails
    }
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusListTile('New'),
              _buildStatusListTile('Progress'),
              _buildStatusListTile('Completed'),
              _buildStatusListTile('Cancelled'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusListTile(String status) {
    return ListTile(
      onTap: () {
        _popDialog();
        if (isSelected(status)) return;
        _changeTaskStatus(status);
      },
      title: Text(status),
      trailing: isSelected(status) ? const Icon(Icons.done) : null,
    );
  }

  void _popDialog() {
    Navigator.pop(context);
  }

  bool isSelected(String status) => widget.taskModel.status == status;

  Future<void> _changeTaskStatus(String status) async {
    _inProgress = true;
    setState(() {});
    final NetworkResponse response = await NetworkClient.getRequest(
      url: Urls.updateTaskStatusUrl(widget.taskModel.id, status),
    );

    _inProgress = false;
    if (response.isSuccess) {
      widget.refreshList();
      if (widget.refreshCount != null) {
        widget.refreshCount!();
      }
    } else {
      setState(() {});
      showSnackBarMessage(context, response.errorMessage, true);
    }
  }

  Future<void> _deleteTask() async {
    _inProgress = true;
    setState(() {});
    final NetworkResponse response = await NetworkClient.getRequest(
      url: Urls.deleteTaskUrl(widget.taskModel.id),
    );

    _inProgress = false;
    if (response.isSuccess) {
      widget.refreshList();
      if (widget.refreshCount != null) {
        widget.refreshCount!();
      }
    } else {
      setState(() {});
      showSnackBarMessage(context, response.errorMessage, true);
    }
  }
}
