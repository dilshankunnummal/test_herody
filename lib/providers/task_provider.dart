import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Task {
  final String id;
  final String title;
  bool completed;

  Task({required this.id, required this.title, this.completed = false});
}

class TaskProvider with ChangeNotifier {
  final String userId;
  final String token;
  List<Task> _tasks = [];

  TaskProvider(this.userId, this.token);

  List<Task> get tasks => [..._tasks];

  DatabaseReference get _userTasksRef =>
      FirebaseDatabase.instance.ref().child('tasks').child(userId);

  Future<void> fetchTasks() async {
    if (userId.isEmpty) return;
    final snapshot = await _userTasksRef.get();
    List<Task> loaded = [];
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((id, val) {
        loaded.add(Task(
          id: id,
          title: val['title'],
          completed: val['completed'] ?? false,
        ));
      });
    }
    _tasks = loaded;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final newTaskRef = _userTasksRef.push();
    await newTaskRef.set({'title': title, 'completed': false});
    _tasks.add(Task(id: newTaskRef.key!, title: title));
    notifyListeners();
  }

  Future<void> updateTask(String id, String title) async {
    await _userTasksRef.child(id).update({'title': title});
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _tasks[idx] = Task(id: id, title: title, completed: _tasks[idx].completed);
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      final newStatus = !_tasks[idx].completed;
      await _userTasksRef.child(id).update({'completed': newStatus});
      _tasks[idx].completed = newStatus;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _userTasksRef.child(id).remove();
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
