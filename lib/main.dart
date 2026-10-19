import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main()=>runApp(const App());
class App extends StatelessWidget{const App({super.key});Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(brightness:Brightness.dark,colorSchemeSeed:Colors.greenAccent,useMaterial3:true),home:const Home());}
class Home extends StatefulWidget{const Home({super.key});State<Home> createState()=>_Home();}
class _Home extends State<Home>{
Map<String,num> d={'BP SYS':0,'BP DIA':0,'Steps':0,'Water ml':0,'Stress /10':0,'Weight kg':0,'Sleep h':0};
final q=['DISCIPLINE BUILDS THE BODY YOUR EXCUSES NEVER WILL.','GET UP. MOVE. HYDRATE. REPEAT.','NO ZERO DAYS. DO SOMETHING FOR YOUR BODY TODAY.'];
void initState(){super.initState();load();}
Future<void> load()async{final p=await SharedPreferences.getInstance(),s=p.getString('health');if(s!=null){final m=jsonDecode(s) as Map<String,dynamic>;for(final k in d.keys){d[k]=m[k]??0;}if(mounted)setState((){});}}
Future<void> add(String k)async{final c=TextEditingController();final v=await showDialog<double>(context:context,builder:(x)=>AlertDialog(title:Text('Add '+k),content:TextField(controller:c,autofocus:true,keyboardType:const TextInputType.numberWithOptions(decimal:true)),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(x,double.tryParse(c.text)),child:const Text('Save'))]));if(v!=null){d[k]=v;(await SharedPreferences.getInstance()).setString('health',jsonEncode(d));setState((){});}}
Widget build(BuildContext c)=>Scaffold(backgroundColor:const Color(0xff090b0d),appBar:AppBar(title:const Text('HEALTHTRACK',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:2))),body:ListView(padding:const EdgeInsets.all(16),children:[
Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.greenAccent)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('TODAY\'S MINDSET',style:TextStyle(color:Colors.greenAccent,fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(q[DateTime.now().day%q.length],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))])),
const SizedBox(height:16),GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),children:d.keys.map((k)=>Card(child:InkWell(onTap:()=>add(k),child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(k,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(d[k]==0?'ADD':d[k].toString(),style:const TextStyle(fontSize:22,color:Colors.greenAccent))]))))).toList()),
const Text('Records are stored locally. HealthTrack is not a medical diagnosis tool.',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))
]));}
