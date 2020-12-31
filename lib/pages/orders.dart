import 'package:admin_ecommerce/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  TextEditingController _status = TextEditingController();
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

  updateData(String status, String id) async {
    await OrderService().updateOrderList(status, id);
    fetchDatabaseList();
  }

  deleteData(String id) async {
    await OrderService().deleteOrderList(id);
    fetchDatabaseList();
  }

  fetchDatabaseList() async {
    dynamic resultant = await OrderService().getOrdersList();

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
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: ListTile(
                          title:
                              Text('Status: ${orderList[index]()['status']}'),
                          subtitle:
                              Text('₹${orderList[index]()['total'].toString()}'),
                          leading: CircleAvatar(
                            child: Image(
                              image: AssetImage('images/Profile_Image.png'),
                            ),
                          ),
                            trailing: IconButton(icon: Icon(Icons.edit), color: Colors.red,tooltip: "Edit",onPressed: (){
                              return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Edit Order Details'),
                                      content: Container(
                                        height: 100,
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: _status,
                                              textCapitalization: TextCapitalization.sentences,
                                              decoration: InputDecoration(hintText: 'Delivered or Process'),
                                            ),
                                            Flexible(child: Text("order id: ${orderList[index]()['id']}", style: TextStyle(color: Colors.red),)),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        FlatButton(
                                          onPressed: () async {
                                            if(_status.text.isNotEmpty){
                                              updateData(_status.text, orderList[index]()['id']);
                                              _status.clear();
                                              Navigator.pop(context);
                                            }else{
                                              return Fluttertoast.showToast(msg: 'Please enter valid status');
                                            }
                                          },
                                          child: Text('Submit'),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        )
                                      ],
                                    );
                                  });
                            },)
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              return showDialog( context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red,size: 50,),
                                          Text('Are you want to \ndelete this file?'),
                                        ],
                                      ),
                                      actions: [
                                        FlatButton(onPressed: (){
                                          deleteData(orderList[index]()['id']);
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(msg: "Delete successfully");
                                        }, child: Text("Yes", style: TextStyle(color: Colors.red),)),
                                        FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("No"))
                                      ],
                                    );
                                  });
                            },
                          ),
                        ],
                      ),
                    );
                  })),
        ));
  }
}
