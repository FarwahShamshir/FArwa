import 'package:flutter/material.dart';
import 'package:faru/services/database_services.dart';
import 'package:faru/models/task.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  final DatabaseServices _dbServices = DatabaseServices.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Task>>(
        future: _dbServices.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks found. Add a task to get started!'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                child: ListTile(
                  title: Text(
                    task.content,
                    style: TextStyle(
                      decoration: task.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    task.status == 1 ? 'Completed' : 'Incomplete',
                    style: TextStyle(
                      color: task.status == 1 ? Colors.green : Colors.red,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: task.status == 1 ? Colors.green : Colors.grey,
                        ),
                        onPressed: () async {
                          await _dbServices.updateTaskStatus(task.id, task.status == 1 ? 0 : 1);
                          setState(() {}); // Refresh the UI
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditTaskDialog(context, task);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _dbServices.deleteTask(task.id);
                          setState(() {}); // Refresh the UI
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _taskController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(hintText: 'Enter your task here'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final taskContent = _taskController.text.trim();
                if (taskContent.isNotEmpty) {
                  await _dbServices.addTask(taskContent);
                  _taskController.clear();
                  setState(() {}); // Refresh the UI
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    _taskController.text = task.content;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(hintText: 'Edit your task'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedContent = _taskController.text.trim();
                if (updatedContent.isNotEmpty) {
                  await _dbServices.updateTaskContent(task.id, updatedContent);
                  _taskController.clear();
                  setState(() {}); // Refresh the UI
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

