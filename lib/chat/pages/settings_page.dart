import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  final String currentUserId = "currentUserId123"; // ID текущего пользователя

  // Поиск пользователей
  void searchProducts(String input) async {
    print("Функция поиска вызвана с текстом: $input");
    final firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: input)
          .get();

      print("Найдено документов: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          searchResults = querySnapshot.docs
              .map((doc) => {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id, // Сохраняем ID документа
                  })
              .toList();
        });
      } else {
        print("Документов не найдено!");
        setState(() {
          searchResults = [];
        });
      }
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
    }
  }

  // Добавление в друзья
  Future<void> addFriend(String friendId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Создаем запись о дружбе
      await firestore.collection('friends').add({
        'userId': currentUserId, // ID текущего пользователя
        'friendId': friendId,   // ID друга
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Пользователь $friendId добавлен в друзья!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Пользователь добавлен в друзья!")),
      );
    } catch (e) {
      print('Ошибка при добавлении в друзья: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: не удалось добавить в друзья")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by email',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () => searchProducts(searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Список результатов
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      return ListTile(
                        title: Text(
                          result['email'] ?? 'No email',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          result['name'] ?? 'No name',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => addFriend(result['id']),
                          child: Text("Добавить"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
