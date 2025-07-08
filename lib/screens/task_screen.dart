import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/widgets/task_dialogue.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).confirmLogout(context);
              }
          ),
        ],
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: taskProvider.fetchTasks(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.red.shade700,
                ),
              ),
            );
          } else {
            return Consumer<TaskProvider>(
              builder: (ctx, taskProv, _) {
                if (taskProv.tasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks found.\nTap + to add a new task.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  itemCount: taskProv.tasks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (ctx, i) {
                    final task = taskProv.tasks[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) => taskProv.toggleComplete(task.id),
                          activeColor: Colors.blue.shade600,
                        ),
                        title: Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.completed ? Colors.grey : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue.shade700),
                              tooltip: 'Edit Task',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => TaskDialog(
                                    initial: task.title,
                                    onSubmit: (value) =>
                                        taskProv.updateTask(task.id, value),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red.shade700),
                              tooltip: 'Delete Task',
                              onPressed: () => taskProv.deleteTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Task',
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => TaskDialog(
              onSubmit: (value) => taskProvider.addTask(value),
            ),
          );
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
