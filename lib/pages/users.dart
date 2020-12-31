import 'package:admin_ecommerce/services/user_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  List userProfilesList = [];

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

  updateData(String name, String email, String userID) async {
    await UserService().updateUserList(name, email, userID);
    fetchDatabaseList();
  }

  deleteData(String userID) async {
    await UserService().deleteUserList(userID);
    fetchDatabaseList();
  }

  fetchDatabaseList() async {
    dynamic resultant = await UserService().getUsersList();

    if (resultant == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        userProfilesList = resultant;
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
            "Users",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            child: ListView.builder(
                itemCount: userProfilesList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: ListTile(
                        title: Text(userProfilesList[index]()['name']),
                        subtitle: Text(userProfilesList[index]()['email']),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.network(userProfilesList[index]()['image']),
                        ),
                        // trailing: IconButton(icon: Icon(Icons.edit), color: Colors.red,tooltip: "Edit",onPressed: (){
                        //   return showDialog(
                        //       context: context,
                        //       builder: (context) {
                        //         return AlertDialog(
                        //           title: Text('Edit User Details'),
                        //           content: Container(
                        //             height: 150,
                        //             child: Column(
                        //               children: [
                        //                 TextField(
                        //                   controller: _nameController,
                        //                   decoration: InputDecoration(hintText: 'Name'),
                        //                 ),
                        //                 TextField(
                        //                   controller: _emailController,
                        //                   keyboardType: TextInputType.emailAddress,
                        //                   decoration: InputDecoration(hintText: 'Email'),
                        //                 ),
                        //                 Flexible(child: Text("user id: ${userProfilesList[index]()['uid']}", style: TextStyle(color: Colors.red),)),
                        //               ],
                        //             ),
                        //           ),
                        //           actions: [
                        //             FlatButton(
                        //               onPressed: () {
                        //                 if(_nameController.text != null && EmailValidator.validate('${_emailController.text}')){
                        //                   updateData(_nameController.text, _emailController.text, userProfilesList[index]()['uid']);
                        //                   _nameController.clear();
                        //                   _emailController.clear();
                        //                   Navigator.pop(context);
                        //                 }else{
                        //                   Fluttertoast.showToast(msg: 'Please enter valid name and email');
                        //                 }
                        //               },
                        //               child: Text('Submit'),
                        //             ),
                        //             FlatButton(
                        //               onPressed: () {
                        //                 Navigator.pop(context);
                        //               },
                        //               child: Text('Cancel'),
                        //             )
                        //           ],
                        //         );
                        //       });
                        // },),
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
                                        Text('Are you want to \ndelete this user?'),
                                      ],
                                    ),
                                    actions: [
                                      FlatButton(onPressed: (){
                                        deleteData(userProfilesList[index]()['uid']);
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
