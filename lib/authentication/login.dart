import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:task/authentication/register.dart';

import '../chat.dart';
class Test extends StatefulWidget {
  Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final myController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email="", _password;
  

  bool _passwordVisible = false;
  
  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Chat()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    _passwordVisible = false;
    setState(() {
      
    });
  }

  late SimpleFontelicoProgressDialog _dialog;

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

  

  login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        _showDialog(
            context, SimpleFontelicoProgressDialogType.hurricane, 'Hurricane');
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
            showSuccess('Log-in completed');
            _dialog.hide();

        navigateToHome();
      } catch (e) {
         _dialog.hide();
        showError(e.toString());
        
        print(e);
      }
    }
  }

  
  
navigateToSignUp() async {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Regsiter()));
  }

  navigateToHome() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Chat()));
  }

  showError(String errormessage) {
   AwesomeDialog(
                        context: context,
                        dialogType: DialogType.ERROR,
                        animType: AnimType.RIGHSLIDE,
                        headerAnimationLoop: true,
                        title: 'Error',
                        desc:errormessage,
                            
                        btnOkOnPress: () {},
                        btnOkIcon: Icons.cancel,
                        btnOkColor: Colors.red)
                      ..show();
                  }
  

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:SingleChildScrollView(child: Container(
         constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height,
         maxWidth: MediaQuery.of(context).size.width,),
         decoration: BoxDecoration(
           gradient: LinearGradient(colors: [Color(0xFF0029E2),Color(0xFF417BFB)],
           begin: Alignment.topLeft,
           end: Alignment.centerRight,
          ),
         ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            flex: 2,
            child: Padding(padding: const EdgeInsets.symmetric(vertical:36.0,horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Login",style: TextStyle(color: Colors.white,fontSize: 46.0,fontWeight:FontWeight.w800 ),),
              SizedBox(height: 10.0,),
              Text("Note-Keeping made easy",style: TextStyle(color: Colors.white,fontSize: 24.0,fontWeight:FontWeight.w300 ),)
            ],)
          ),),
          Expanded(flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )
            ),
            child: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    TextFormField(
                      controller: myController,
                      onSaved: (input) => _email = input!,
                      validator: (input) {
                                      if (input!.isEmpty) return 'Enter Email';
                                      if (!input.contains('@') ||
                                          !input.contains('.'))
                                        return 'Invalid Email';
                                      return null;
                                    },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border:OutlineInputBorder(borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Color(0xFFD9F0FC),
                        hintText: "E-mail",
                        
                        prefixIcon: Icon(Icons.email,color:Color(0xFF417BFB) ,))
                      ),
                      SizedBox(height:40),
                      TextFormField(
                        obscureText: !_passwordVisible,
                         onSaved: (input) => _password = input!,
                         validator: (input) {
                                      if (input!.length < 6)
                                        return 'Provide Minimum 6 Character';
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                            // Based on passwordVisible state choose the icon
                                            _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                            color: Theme.of(context).primaryColorDark,
                                            ),
                                          onPressed: () {
                                            // Update the state i.e. toogle the state of passwordVisible variable
                                            setState(() {
                                                _passwordVisible = !_passwordVisible;
                                            });
                                          },),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide.none),
                                        filled: true,
                                        fillColor: Color(0xFFD9F0FC),
                                        hintText: "Password",
                                        prefixIcon: Icon(
                                          Icons.password,
                                          color: Color(0xFF417BFB),
                                        ))),
                                SizedBox(height: 30),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        child: Column(
                                          children: [GestureDetector(
                                            
                                            onTap: () async {
                                                _email = myController.text;
                                              print(_email);
                                              if(_email.length>0&&_email.contains('@')&&_email.contains('.'))
                                              {
                                                try{
                                                 _showDialog(
                                                        context,
                                                        SimpleFontelicoProgressDialogType
                                                            .hurricane,
                                                        'Hurricane');
                                                await _auth.sendPasswordResetEmail(email: _email);
                                                _dialog.hide();
                                                showSuccess(
                                                      "Password Reset Link has been sent to your E-mail");
                                                }
                                                catch(e)
                                                {
                                                  showError(e.toString());
                                                }
                                                
                                              }
                                              else
                                                showError("Please enter valid E-mail");
                                                },
                                            child: Text(
                                              "Forgot Password",
                                              style: TextStyle(color: Color(0xFF0042D1),fontWeight: FontWeight.w400,fontSize: 16.0),
                                              textAlign: TextAlign.right,
                                              ),
                                          ),
                                          SizedBox(height: 20.0,),
                                          GestureDetector(
                                            onTap: ()  {
                                                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Regsiter()));
                                            },
                                            child: Text(
                                                "Create a new account",
                                                style: TextStyle(color: Color(0xFF0042D1),fontWeight: FontWeight.w400,fontSize: 16.0),
                                                textAlign: TextAlign.left,
                                                ),
                                          ),
                                          ],
                                        ),
            
                                        
                                      ),
                                      
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(onPressed: (){login();}, 
                        style: ButtonStyle(
                         backgroundColor: MaterialStateProperty.all(Color(0xFF0029E2)),
                          shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      
                                    borderRadius:BorderRadius.circular(18.0), 
                                          side: BorderSide(color: Color(0xFF0029E2))))
                        ),
                        child: Text("LOGIN",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600),)),
                      )
                  ],
                    ),
              )
                
                ),
            ),),
          ),
          ]
          ),
       ),
        ),
       );
  
    
  }
}