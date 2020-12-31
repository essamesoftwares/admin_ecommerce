import 'dart:io';

import 'package:admin_ecommerce/db/brand.dart';
import 'package:admin_ecommerce/db/category.dart';
import 'package:admin_ecommerce/services/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  List prodList = [];
  TextEditingController _productNameController = TextEditingController();
  final _priceController = TextEditingController();

  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
  <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;

  String userID = "";
  File _image1;

  @override
  void initState() {
    super.initState();
    fetchProdInfo();
    fetchDatabaseList();
    _getCategories();
    _getBrands();
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].data()['category'];
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].data()['brand'];
    });
  }

  fetchProdInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  updateData(String picture, String name, String brand,String category, String price, String id) async {
    await ProductService().updateProductList(picture, name, brand, category, price, id);
    fetchDatabaseList();
  }

  deleteData(String userID) async {
    await ProductService().deleteProductList(userID);
    fetchDatabaseList();
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

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(categories[i].data()['category']),
                value: categories[i].data()['category']));
      });
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].data()['brand']),
                value: brands[i].data()['brand']));
      });
    }
    return items;
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
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        title: Text(prodList[index]()['name']),
                        subtitle: Text('₹${prodList[index]()['price'].toString()}'),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(prodList[index]()['picture']),
                          ),
                        trailing: IconButton(icon: Icon(Icons.edit), color: Colors.red,tooltip: "Edit",onPressed: (){
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Edit ${prodList[index]()['name']} Details'),
                                  content: Container(
                                    height: 350,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 120,
                                                child: OutlineButton(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey.withOpacity(0.5),
                                                        width: 2.5),
                                                    onPressed: () {
                                                      _selectImage(
                                                        ImagePicker.pickImage(
                                                            source: ImageSource.gallery),
                                                      );
                                                    },
                                                    child:_displayChild1()),
                                              ),
                                            ),
                                          ),
                                          TextField(
                                            controller: _productNameController,
                                            textCapitalization: TextCapitalization.sentences,
                                            decoration: InputDecoration(hintText: 'Category Name'),
                                          ),
                                          TextField(
                                            controller: _priceController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(hintText: 'Price'),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Category: ',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                              DropdownButton(
                                                items: categoriesDropDown,
                                                onChanged: changeSelectedCategory,
                                                value: _currentCategory,
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: [
                                              Text(
                                                'Brand: ',
                                                style: TextStyle(color: Colors.red),
                                              ),
                                              DropdownButton(
                                                items: brandsDropDown,
                                                onChanged: changeSelectedBrand,
                                                value: _currentBrand,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                      onPressed: () async {
                                        if(_productNameController.text.isNotEmpty && _priceController.text.isNotEmpty){

                                          if (_image1 != null) {
                                            String imageUrl1;

                                            final FirebaseStorage storage = FirebaseStorage.instance;
                                            final String picture1 =
                                                "prodEdit${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
                                            StorageUploadTask task1 =
                                            storage.ref().child(picture1).putFile(_image1);

                                            StorageTaskSnapshot snapshot1 =
                                            await task1.onComplete.then((snapshot) => snapshot);

                                            task1.onComplete.then((snapshot3) async {
                                              imageUrl1 = await snapshot1.ref.getDownloadURL();
                                              updateData(imageUrl1, _productNameController.text, _currentCategory, _currentBrand, _priceController.text, prodList[index]()['id']);
                                              _productNameController.clear();
                                              _priceController.clear();
                                            });
                                            Navigator.pop(context);
                                          }else if(_image1==null){
                                            updateData(prodList[index]()['picture'], _productNameController.text, _currentCategory, _currentBrand, _priceController.text,  prodList[index]()['id']);
                                            _productNameController.clear();
                                            _priceController.clear();
                                            Navigator.pop(context);
                                          }

                                        }else{
                                          return Fluttertoast.showToast(msg: 'Please enter valid product name');
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
                        }),
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
                                        deleteData(prodList[index]()['id']);
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

  void _selectImage(Future<File> pickImage) async {
    File tempImg = await pickImage;
    setState(() => _image1 = tempImg);
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: new Icon(
          Icons.add,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.file(
        _image1,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  changeSelectedCategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }
}
