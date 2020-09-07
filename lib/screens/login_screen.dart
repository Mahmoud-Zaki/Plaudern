import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controllers/user_auth.dart';
import '../screens/registration_screen.dart';
import '../screens/Home.dart';
import 'package:email_validator/email_validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email,_pass;
  bool showSpinner=false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:ModalProgressHUD(
          inAsyncCall: showSpinner,
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Welcome',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pacifico(
                          color: Theme.of(context).primaryColor,
                          fontSize: 48.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        autofocus: false,
                        validator: (email)=>EmailValidator.validate(email)?
                        null :"Invalid email address",
                        onSaved: (email)=> _email = email,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.email,
                              color: Colors.grey,
                            ),
                          ),
                          hintText: 'E-mail ...',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        autofocus: false,
                        obscureText: true,
                        validator: (password){
                          Pattern pattern =
                              r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(password))
                            return 'Invalid password';
                          else
                            return null;
                        },
                        onSaved: (password)=> _pass = password,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                          ),
                          hintText: 'Password ...',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Theme.of(context).primaryColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Material(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          elevation: 5.0,
                          child: MaterialButton(
                            minWidth: 200.0,
                            height: 42.0,
                            child: Text(
                              'Log In',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: Login,
                          ),
                        ),
                      ),
                      FlatButton(
                        child: Text(
                          'Create an Accont ...',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void Login() async{
    UserAuth userAuth = UserAuth();
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      try{
        setState(() => showSpinner = true);
        final done = await userAuth.login(_email, _pass);
        setState(()=> showSpinner = false);
        if(done != null){
          print('go to home : $done');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Home(),
            ),
                (route) => false,
          );
        }
        else {
          print('show dilog : $done');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  content: Text('E-Mail or Password is not correct\n'
                      'Please, try again',style: TextStyle(color: Colors.black),),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel',style: TextStyle(color: Colors.black),),
                    )
                  ],
                );
              });
        }
      }catch(e){
        print(e.message.toString());
      }
    }
  }
}