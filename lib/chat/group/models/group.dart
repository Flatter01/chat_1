class Group {
  final String id;
  final String groupName;
  final List<String> members;

  Group({required this.id, required this.groupName, required this.members});

  factory Group.fromMap(Map<String, dynamic> data, String documentId) {
    return Group(
      id: documentId,
      groupName: data['groupName'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupName': groupName,
      'members': members,
    };
  }
}
