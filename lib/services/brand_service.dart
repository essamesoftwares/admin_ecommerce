import 'package:cloud_firestore/cloud_firestore.dart';

class BrandService {
  final CollectionReference brandsList =
      FirebaseFirestore.instance.collection('brands');

  Future<void> createUserData(String brand, String uid) async {
    return await brandsList.doc(uid).set({
      'brand': brand,
    });
  }

  Future updateBrandList(String brand, String uid) async {
    return await brandsList.doc(uid).update({'brand': brand});
  }

  Future getBrandsList() async {
    List itemsList = [];

    try {
      await brandsList.get().then((querySnapshot) {
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
