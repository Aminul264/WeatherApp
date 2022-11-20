import 'package:flutter/material.dart';
import 'package:weather_app/screens/appBarWIdget.dart';
import 'package:weather_app/screens/homeBody.dart';

class HomeScreen extends StatefulWidget{
  @override
  State <HomeScreen> createState()=> _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const AppBarWidget(),
      ),
      backgroundColor: Colors.lightBlue[40],
      body: const HomeBody(),

    );
  }
}