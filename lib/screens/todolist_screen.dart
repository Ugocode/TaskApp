import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule_app/Helpers/database_helpers.dart';
import 'package:schedule_app/models/task_models.dart';
import 'package:schedule_app/screens/addtsk_screen.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat("dd MMM, yyyy");

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

//create each task widget:
  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            subtitle: Text(
              '${_dateFormatter.format(task.date)}. Priority ${task.priority}',
              style: TextStyle(
                  fontSize: 14,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              activeColor: Theme.of(context).primaryColor,
              value: task.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTaskScreen(
                          updateTaskList: _updateTaskList,
                          task: task,
                        ))),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddTaskScreen(
                          updateTaskList: _updateTaskList,
                        )));
          }),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/front.jpg'),
                fit: BoxFit.fill)),
        child: FutureBuilder(
            future: _taskList,
            builder: (context, snapshot) {
              //if there is no task in the database of the phone:
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              /// to get the completed task data or done task:
              final int completedTaskCount = snapshot.data
                  .where((Task task) => task.status == 1)
                  .toList()
                  .length;
              return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/front.jpg'),
                        fit: BoxFit.fill)),
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    itemCount: 1 + snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My Tasks...",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "$completedTaskCount of ${snapshot.data.length} Done",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 40),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 70,
                                width: 350,
                                decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  'On todays todo list we have...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildTask(snapshot.data[index - 1]);
                    }),
              );
            }),
      ),
    );
  }
}
