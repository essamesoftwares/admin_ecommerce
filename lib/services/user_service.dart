import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference profileList =
  FirebaseFirestore.instance.collection('users');

  Future<void> createUserData(String name, String email, String uid) async {
    return await profileList.doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  Future updateUserList(String name, String email, String uid) async {
    return await profileList.doc(uid).update({
      'name': name,
      'email': email,
    });
  }

  Future getUsersList() async {
    List itemsList = [];

    try {
      await profileList.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          itemsList.add(element.data);
        });
      });
      return itemsList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
