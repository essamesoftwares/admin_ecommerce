import 'dart:io';

import 'package:admin_ecommerce/db/category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> with TickerProviderStateMixin {
  TextEditingController categoryController = TextEditingController();
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  CategoryService _categoryService = CategoryService();
  bool isLoading = false;
  File _image1;

  AnimationController animationController;
  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
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
          "Add Category",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _categoryFormKey,
        child: SingleChildScrollView(
          child: isLoading
              ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator(valueColor: animationController
                  .drive(ColorTween(begin: Colors.blueAccent, end: Colors.red)))))
              : Column(
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
                              child: _displayChild1()),
                        ),
                      ),
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: categoryController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'category cannot be empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(hintText: "add category"),
                    ),SizedBox(height: 40,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: RaisedButton(
                                color: Colors.red,
                                  onPressed: () {
                                    validateAndUpload();
                                  },
                                  child: Text('ADD', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: RaisedButton(
                                color: Colors.blue,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
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

  void validateAndUpload() async {
    if (_categoryFormKey.currentState.validate()) {
      setState(() => isLoading = true);
      if (_image1 != null) {
        String imageUrl1;

        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 =
            "catimg${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        StorageUploadTask task1 =
            storage.ref().child(picture1).putFile(_image1);

        StorageTaskSnapshot snapshot1 =
            await task1.onComplete.then((snapshot) => snapshot);

        task1.onComplete.then((snapshot3) async {
          imageUrl1 = await snapshot1.ref.getDownloadURL();

          _categoryService.createCategory({
            "category": categoryController.text,
            "image": imageUrl1,
          });
          _categoryFormKey.currentState.reset();
          setState(() => isLoading = false);
          Navigator.pop(context);
        });
      } else {
        setState(() => isLoading = false);

        Fluttertoast.showToast(msg: 'please insert category image');
      }
    }
  }
}
