import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final CollectionReference categoryList =
  FirebaseFirestore.instance.collection('categories');

  Future<void> createUserData(String category, String id) async {
    return await categoryList.doc(id).set({
      'category': category,
    });
  }

  Future updateCategoryList(String name,String image, String id) async {
    return await categoryList.doc(id).update({'category': name, 'image': image});
  }

  Future deleteCategoryList(String id) async {
    return await categoryList.doc(id).delete();
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
