import 'package:admin_ecommerce/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List prodList = [];

  String userID = "";

  @override
  void initState() {
    super.initState();
    fetchProdInfo();
    fetchDatabaseList();
  }

  fetchProdInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  fetchDatabaseList() async {
    dynamic resultant = await ProductService().getProductsList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        prodList = resultant;
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
            "Products",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            child: ListView.builder(
                itemCount: prodList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(prodList[index]()['name']),
                      subtitle: Text('₹${prodList[index]()['price'].toString()}'),
                      // leading: CircleAvatar(
                      //   child: Image(
                      //     image: AssetImage('assets/Profile_Image.png'),
                      //   ),
                      // ),
                    ),
                  );
                })));
  }
}
