import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final CollectionReference categoryList =
  FirebaseFirestore.instance.collection('categories');

  Future<void> createUserData(String category, String uid) async {
    return await categoryList.doc(uid).set({
      'category': category,
    });
  }

  Future updateUserList(String name, String uid) async {
    return await categoryList.doc(uid).update({'name': name});
  }

  Future getCategoriesList() async {
    List itemsList = [];

    try {
      await categoryList.get().then((querySnapshot) {
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
