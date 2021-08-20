import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:task/profile.dart';
import 'package:task/start.dart';

class Chat extends StatefulWidget {
  const Chat({ Key? key }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}


class _ChatState extends State<Chat> {

  late String message="";
  final myController = TextEditingController();
  CollectionReference users = Firestore.instance.collection('chat');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late FirebaseUser firebaseUser;
  late FirebaseUser user;
  String name = "",id="";
  late QuerySnapshot _querySnapshot;
  late Timer? timer;


  set querySnapshot(QuerySnapshot querySnapshot) {
    _querySnapshot = querySnapshot;
  }

  late SimpleFontelicoProgressDialog _dialog;

  set isLoggedin(bool isLoggedin) {}

   @override
  void initState() {
    super.initState();
    this.getUser();
    setState(() {
      
    });
    
    this.getMessages().whenComplete((){
        setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  getMessages() async{

    setState(() async {
       querySnapshot =
        await Firestore.instance.collection("chat").getDocuments();
    });
    
    for (int i = 0; i < _querySnapshot.documents.length; i++) {
      var a = _querySnapshot.documents[i];
      print(a.data["message"]);
    }

  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser.reload();
    firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isLoggedin = true;
      });
      print("UID" + firebaseUser.uid);
      try {
        await Firestore.instance
            .collection("users")
            .document(firebaseUser.uid)
            .get()
            .then((DocumentSnapshot snapshot) {
          if (snapshot.exists)
            print("NAME" + snapshot.data["name"]);
          else
            showError("User not found");
          setState(() {
            name = snapshot.data["name"];
            id=snapshot.data["id"];
          });
        });
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(name.toString()),
        // ));
      } catch (e) {
        showError(e.toString());
      }
    }
  }


  showSuccess(String successmessage) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        showCloseIcon: true,
        title: 'Succes',
        desc: successmessage,
        btnOkColor: Color(0xFF0029E2),
        btnOkOnPress: () {
          debugPrint('OnClick');
        },
        btnOkIcon: Icons.check_circle,
        onDissmissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        })
      ..show();
  }

  showError(String errormessage) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: true,
        title: 'Error',
        desc: errormessage,
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
  }


void _showDialog(BuildContext context, SimpleFontelicoProgressDialogType type,
      String text) async {
    _dialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);

    if (type == SimpleFontelicoProgressDialogType.custom) {
      _dialog.show(
          message: text,
          type: type,
          width: 150.0,
          height: 75.0,
          loadingIndicator: Text(
            'C',
            style: TextStyle(fontSize: 24.0),
          ));
    } else {
      _dialog.show(
          message: text,
          type: type,
          horizontal: true,
          width: 150.0,
          height: 75.0,
          hideText: true,
          indicatorColor: Colors.red);
    }
  }

 send() async {
   if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

  

  String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
    String time = DateFormat("hh:mm").format(DateTime.now());
  try {
          _showDialog(context, SimpleFontelicoProgressDialogType.hurricane,
              'Hurricane');
          await users.document().setData({
            'id': user.uid,
            'name': name,
            'message': message,
            'date': date,
            'time':time,
          }).then((value) => print("Registered"));

          _dialog.hide();
          myController.clear();
          
        } catch (e) {
          print(e.toString());
          _dialog.hide();
          showError(e.toString());
        }
   }
}

Widget chat(String message,String id1,String name,String date,String time)
{

  if(_querySnapshot.documents.length==0||_querySnapshot==Null)
  {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  else
  {
  return Padding(
    padding: EdgeInsets.all(5.0),
    child: Wrap(
      children:[ Container(
        
        
       
  
          child: Row(
            mainAxisAlignment: id==id1?MainAxisAlignment.end:MainAxisAlignment.start,
            children:[ Container(
              height: 60,
              padding: EdgeInsets.all(5.0),

              decoration: BoxDecoration(
            color: id1 == id
                ? Color(0xFF2950FF)
                : Color(0xFF000000),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
                  BoxShadow(
                      color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0)
                  ,
            ],
          ),
          
              child: Column(
                children:[ 
                   Text(
                        name,
                        style: TextStyle(fontSize: 12, color: Colors.green,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 2,),
                  Text(message,
                
                style: TextStyle(
                  color: id1 == id?Colors.lightBlue[50]:Colors.white,fontSize: 16
                ),
                
                ),
                SizedBox(
                          height: 3,
                        ),
                Text(date+" "+time,style: TextStyle(fontSize: 10,color: Colors.grey),textAlign: TextAlign.left,),
                ],
              ),
            ),
            ],
          ),
      ),
      ],
    ),
  );
  }
}



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0029E2),
        title: Text('Group Chat',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold)),
          actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
               Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
      
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              
              Container(
              height: MediaQuery.of(context).size.height-180,
              width: MediaQuery.of(context).size.width,
              color: Color(0xFFD9F0FC),
              child: 
              StreamBuilder(
                stream: Firestore.instance.collection("chat").orderBy('time',descending: false).snapshots(),
                builder:(context, AsyncSnapshot<QuerySnapshot> snapshot)
                {
                  if (!snapshot.hasData) {
      return Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
    }
    else if(snapshot.connectionState==ConnectionState.none)
    {
      showError("Check Connection");
    }
    else if (snapshot.connectionState ==
                            ConnectionState.none) {
                          showError("Check Connection");
                        }
                        else if (snapshot.connectionState ==
                            ConnectionState.active&&snapshot.connectionState==ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue)));
   
                        }
                        
     else {
           var x=snapshot.data!;
                
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: x.documents.length,
                  itemBuilder: (BuildContext context, int index)
                  {
                    return Column(
                      
                      children: [chat(x.documents[index].data["message"],
                      x.documents[index].data["id"],
                      x.documents[index].data["name"],
                      x.documents[index].data["date"],
                      x.documents[index].data["time"],
                    )
                      ]
                    );
                  },
                );
    }           return Container(
      height: 0,
      width: 0,
    );
                }
              )

                  ),
                  SizedBox(height: 10,),
              Row(
                children:<Widget>[
                  SizedBox(width: 10,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width-70,
                    child: TextFormField(
                      controller: myController,
                      onSaved: (input) => message = input!,
                      validator: (input) {
                        if (input!.isEmpty) return 'Enter message';
                        return null;
                      },
                      
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Color(0xFFD9F0FC),
                          hintText: "Your message",
                         )),
                  ),
                  SizedBox(
                  width: 10,
                ),
                  IconButton(onPressed: (){send();}, icon: Icon(Icons.send,color: Colors.blue,))
                ]
              )
            ],
          ),
        ),
          
              
                            
                        ),
               
                );
  }
  
}

class ShowMessages extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: Firestore.instance.collection("chat").snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData)
        {
          return Center(
            child: CircularProgressIndicator(

            )
          );
        }

        return ListView.builder(
          // itemCount: snapshot.data!.docs.length,
          itemBuilder: (context,i)
        {
          
         
          return ListTile(
            //title: Text(x["message"])
          );

        });
      });
    
 }

}


