import 'dart:io';

import 'package:admin_ecommerce/services/category_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  TextEditingController _categoryNameController = TextEditingController();
  List categoryList = [];
  File _image1;

  String userID = "";

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchDatabaseList();
  }

  fetchUserInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  updateData(String categoryName, String image, String userID) async {
    await CategoryService().updateCategoryList(categoryName, image, userID);
    fetchDatabaseList();
  }

  deleteData(String userID) async {
    await CategoryService().deleteCategoryList(userID);
    fetchDatabaseList();
  }

  fetchDatabaseList() async {
    dynamic resultant = await CategoryService().getCategoriesList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        categoryList = resultant;
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
            "Categories",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            child: ListView.builder(
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        title: Text(categoryList[index]()['category']),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(categoryList[index]()['image']),
                        ),
                        trailing: IconButton(icon: Icon(Icons.edit), color: Colors.red,tooltip: "Edit",onPressed: (){
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Edit ${categoryList[index]()['category']} Details'),
                                  content: Container(
                                    height: 250,
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
                                          controller: _categoryNameController,
                                          textCapitalization: TextCapitalization.sentences,
                                          decoration: InputDecoration(hintText: 'Category Name'),
                                        ),
                                        Flexible(child: Text("category id: ${categoryList[index]()['id']}", style: TextStyle(color: Colors.red),)),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                      onPressed: () async {
                                        if(_categoryNameController.text.isNotEmpty){

                                          if (_image1 != null) {
                                            String imageUrl1;

                                            final FirebaseStorage storage = FirebaseStorage.instance;
                                            final String picture1 =
                                                "catEdit${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
                                            StorageUploadTask task1 =
                                            storage.ref().child(picture1).putFile(_image1);

                                            StorageTaskSnapshot snapshot1 =
                                                await task1.onComplete.then((snapshot) => snapshot);

                                            task1.onComplete.then((snapshot3) async {
                                              imageUrl1 = await snapshot1.ref.getDownloadURL();
                                              updateData(_categoryNameController.text, imageUrl1, categoryList[index]()['id']);
                                              _categoryNameController.clear();
                                            });
                                            Navigator.pop(context);
                                          }else if(_image1==null){
                                            updateData(_categoryNameController.text, categoryList[index]()['image'], categoryList[index]()['id']);
                                            _categoryNameController.clear();
                                            Navigator.pop(context);
                                          }

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
                        },),
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
                                    deleteData(categoryList[index]()['id']);
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
}
