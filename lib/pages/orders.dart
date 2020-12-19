import 'package:admin_ecommerce/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List orderList = [];

  String userID = "";

  @override
  void initState() {
    super.initState();
    fetchOrderInfo();
    fetchDatabaseList();
  }

  fetchOrderInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  fetchDatabaseList() async {
    dynamic resultant = await OrderService().getUsersList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        orderList = resultant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            "Orders",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: GestureDetector(
          onTap: (){},
          child: Container(
              child: ListView.builder(
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title:
                            Text('Amount Status: ${orderList[index]()['status']}'),
                        subtitle:
                            Text('₹${orderList[index]()['total'].toString()}'),
                        leading: CircleAvatar(
                          child: Image(
                            image: AssetImage('images/Profile_Image.png'),
                          ),
                        ),
                      ),
                    );
                  })),
        ));
  }
}
