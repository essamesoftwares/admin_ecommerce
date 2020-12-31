import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference productList =
      FirebaseFirestore.instance.collection('products');

  Future<void> createUserData(String name, String price, String uid) async {
    return await productList.doc(uid).set({'name': name, 'price': price});
  }

  Future updateProductList(String picture, String name, String brand,
      String category, String price, String id) async {
    return await productList.doc(id).set({
      'picture': picture,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'id': id
    });
  }

  Future deleteProductList(String id) async {
    return await productList.doc(id).delete();
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
