import 'package:admin_ecommerce/services/brand_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Brands extends StatefulWidget {
  @override
  _BrandsState createState() => _BrandsState();
}

class _BrandsState extends State<Brands> {
  List brandList = [];

  String userID = "";

  TextEditingController _brandNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBrandInfo();
    fetchDatabaseList();
  }

  fetchBrandInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  updateData(String brand, String brandId) async {
    await BrandService().updateBrandList(brand, brandId);
    fetchDatabaseList();
  }

  deleteData(String brandId) async {
    await BrandService().deleteProductList(brandId);
    fetchDatabaseList();
  }

  fetchDatabaseList() async {
    dynamic resultant = await BrandService().getBrandsList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        brandList = resultant;
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
            "Brands",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            child: ListView.builder(
                itemCount: brandList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        title: Text(brandList[index]()['brand']),
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
                                    title: Text('Edit ${brandList[index]()['brand']} Details'),
                                    content: Container(
                                      height: 100,
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: _brandNameController,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(hintText: 'Brand Name'),
                                          ),
                                          Flexible(child: Text("brand id: ${brandList[index]()['brandId']}", style: TextStyle(color: Colors.red),)),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      FlatButton(
                                        onPressed: () async {
                                          if(_brandNameController.text.isNotEmpty){
                                            updateData(_brandNameController.text, brandList[index]()['brandId']);
                                            _brandNameController.clear();
                                            Navigator.pop(context);
                                          }else{
                                            return Fluttertoast.showToast(msg: 'Please enter valid category name');
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
                                        deleteData(brandList[index]()['brandId']);
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
                })));
  }
}
