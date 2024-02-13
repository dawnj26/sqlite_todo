import 'package:flutter/material.dart';
import 'package:sqlite_todo/helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SQLiteApp());
}

class SQLiteApp extends StatelessWidget {
  const SQLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Todo>> fetchData() async {
    final d = await DBHelper.fetchData();
    print(d);
    
    return d.map((e) => Todo.fromMap(e)).toList();
  }

  void insertData(String t) {
    setState(() {
      print(DBHelper.insertTodo(t));
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLiteApp"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: todoController,
              decoration: const InputDecoration(
                label: Text("To-do item"),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              onPressed: () {
                insertData(todoController.text);
              },
              child: const Text("Add"),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: FutureBuilder(
                future: fetchData(),
                builder: (_, data) {
                  if (data.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (data.data == null) {
                    return const Center(
                      child: Text("No todo"),
                    );
                  }

                  return ListView.builder(
                    itemCount: data.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: Key(data.data![index].id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          setState(() {
                            DBHelper.delTodo(data.data![index]);
                          });
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(data.data![index].name),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
