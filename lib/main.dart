import "package:flutter/material.dart";
import "screens/welcome_screen.dart";

void main(){
  runApp(const TicketProMobile());
}

class TicketProMobile extends StatelessWidget{
  const TicketProMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TicketProMobile",
      home: const  WelcomeScreen(),
    );
  }
}