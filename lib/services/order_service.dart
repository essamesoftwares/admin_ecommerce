import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference ordersList =
  FirebaseFirestore.instance.collection('orders');

  Future<void> createOrderData(
      String status, String total, String userId, String uid) async {
    return await ordersList.doc(uid).set({
      'status': status,
      'total': total,
      'userId': userId,
    });
  }

  Future updateOrderList(
      String status, String id) async {
    return await ordersList.doc(id).set({
      'status': status,
    });
  }

  Future deleteOrderList(String id) async {
    return await ordersList.doc(id).delete();
  }

  Future getOrdersList() async {
    List itemsList = [];

    try {
      await ordersList.get().then((querySnapshot) {
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
