// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/presentation/providers/home_page_provider.dart';
import 'package:todo_task/presentation/views/add_task_page.dart';
import 'package:todo_task/presentation/widgets/empty_state.dart';
import 'package:todo_task/presentation/widgets/task_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;

    return ChangeNotifierProvider<HomePageProvider>(
      create: (_) => HomePageProvider(),
      child: Consumer<HomePageProvider>(
        builder: (context, taskProvider, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(
                'My Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 28 : 24,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.deepPurple,
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
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: Builder(
              builder: (scaffoldContext) {
                return StreamBuilder(
                  stream: taskProvider.getTasksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const EmptyState(
                        title: 'No tasks found',
                        subtitle: 'Tap + to add a new task',
                        icon: Icons.assignment_outlined,
                      );
                    }

                    final colorScheme = [
                      Colors.deepPurple.withOpacity(0.1),
                      Colors.blue.withOpacity(0.1),
                      Colors.teal.withOpacity(0.1),
                      Colors.orange.withOpacity(0.1),
                      Colors.pink.withOpacity(0.1),
                    ];

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? screenWidth * 0.1 : 16.0,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final task = snapshot.data!.docs[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TaskCard(
                              task: task,
                              onDelete: () async {
                                await task.reference.delete();
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddPage(editData: task),
                                  ),
                                );
                              },
                              cardColor:
                                  colorScheme[index % colorScheme.length],
                              scaffoldContext: scaffoldContext,
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
