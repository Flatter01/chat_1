import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  // Метод для добавления пользователя
  Future<void> addMember() async {
    final String newMember = emailController.text.trim();

    if (newMember.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите email пользователя!')),
      );
      return;
    }

    // Проверка, что email имеет домен gmail.com
    if (!newMember.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, используйте email с доменом @gmail.com')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Проверка, существует ли пользователь с таким email
      final userRef = FirebaseFirestore.instance.collection('users').where('email', isEqualTo: newMember);
      final userSnapshot = await userRef.get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь с таким email не зарегистрирован!')),
        );
        return;
      }

      final groupRef = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
      final groupDoc = await groupRef.get();
      if (!groupDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа не найдена!')),
        );
        return;
      }

      final groupData = groupDoc.data() as Map<String, dynamic>;
      final members = List<String>.from(groupData['members'] ?? []);

      if (members.contains(newMember)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$newMember уже в группе!')),
        );
      } else {
        await groupRef.update({
          'members': FieldValue.arrayUnion([newMember]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$newMember добавлен в группу!')),
        );

        emailController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final groupData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final members = List<String>.from(groupData?['members'] ?? []);

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(members[index]),
                      leading: const Icon(Icons.person),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Введите email участника',
                    ),
                  ),
                ),
                isLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                        onPressed: addMember,
                        icon: const Icon(Icons.add),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
