// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_task/presentation/providers/home_page_provider.dart';
import 'package:todo_task/presentation/views/add_task_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomePageProvider>(
      create: (_) => HomePageProvider(),
      child: Consumer<HomePageProvider>(
        builder: (context, taskProvider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    taskProvider.logoutUser(context);
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPage()),
                );
              },
              child: const Icon(Icons.add),
            ),

            // ✅ Wrapping body with Builder to get proper ScaffoldMessenger context
            body: Builder(builder: (scaffoldContext) {
              return StreamBuilder(
                stream: taskProvider.getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No tasks found.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data!.docs[index];
                      final data = task.data();

                      final title = data['title'] ?? 'No Title';
                      final description =
                          data['description'] ?? 'No Description';

                      String formattedDate = 'No Date';
                      try {
                        final rawDate = data['date'];
                        final dateTime = rawDate?.toDate();
                        if (dateTime != null) {
                          formattedDate =
                              DateFormat('dd/MM/yy').format(dateTime);
                        }
                      } catch (_) {}

                      final colors = [
                        Colors.yellow.shade100,
                        Colors.green.shade100,
                        Colors.blue.shade100,
                        Colors.pink.shade100,
                        Colors.purple.shade100,
                      ];

                      return Card(
                        color: colors[index % colors.length],
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(description),
                                    const SizedBox(height: 6),
                                    Text("🗓️ $formattedDate"),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.black87),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddPage(editData: task),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await task.reference.delete();

                                      // ✅ Using scaffoldContext to show the snackbar properly
                                      ScaffoldMessenger.of(scaffoldContext)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Task deleted')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      await Share.share(
                                          'Task: $title\n\n$description');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}
