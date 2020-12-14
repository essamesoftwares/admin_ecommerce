import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference productList =
  FirebaseFirestore.instance.collection('products');

  Future<void> createUserData(String name, String price, String uid) async {
    return await productList
        .doc(uid)
        .set({'name': name, 'price': price});
  }

  Future updateUserList(String name, String price, String uid) async {
    return await productList
        .doc(uid)
        .set({'name': name, 'price': price});
  }

  Future getProductsList() async {
    List itemsList = [];

    try {
      await productList.get().then((querySnapshot) {
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
