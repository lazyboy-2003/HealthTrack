import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main()=>runApp(const App());
class App extends StatelessWidget{const App({super.key});Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(brightness:Brightness.dark,colorSchemeSeed:Colors.greenAccent,useMaterial3:true),home:const Home());}
class Home extends StatefulWidget{const Home({super.key});State<Home> createState()=>_Home();}
class _Home extends State<Home>{
Map<String,num> d={'BP SYS':0,'BP DIA':0,'Pulse':0,'Steps':0,'Water ml':0,'Stress /10':0,'Weight kg':0,'Sleep h':0};
List<Map<String,dynamic>> history=[];
final q=['DISCIPLINE BUILDS THE BODY YOUR EXCUSES NEVER WILL.','GET UP. MOVE. HYDRATE. REPEAT.','NO ZERO DAYS. DO SOMETHING FOR YOUR BODY TODAY.'];
void initState(){super.initState();load();}
Future<void> load()async{final p=await SharedPreferences.getInstance(),s=p.getString('health');if(s!=null){final m=jsonDecode(s) as Map<String,dynamic>;for(final k in d.keys){d[k]=m[k]??0;}}final h=p.getString('history');if(h!=null){history=List<Map<String,dynamic>>.from(jsonDecode(h));}if(mounted)setState((){});}
Future<void> add(String k)async{final c=TextEditingController();final v=await showDialog<double>(context:context,builder:(x)=>AlertDialog(title:Text('Add '+k),content:TextField(controller:c,autofocus:true,keyboardType:const TextInputType.numberWithOptions(decimal:true)),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(x,double.tryParse(c.text)),child:const Text('Save'))]));if(v!=null){d[k]=v;history.insert(0,{'type':k,'value':v,'time':DateTime.now().toIso8601String()});if(history.length>100)history=history.take(100).toList();final p=await SharedPreferences.getInstance();await p.setString('health',jsonEncode(d));await p.setString('history',jsonEncode(history));setState((){});}}
Widget _goal(String label,double value,double goal){final p=(value/goal).clamp(0.0,1.0);return Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xff121619),borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:10),LinearProgressIndicator(value:p,minHeight:8,borderRadius:BorderRadius.circular(8)),const SizedBox(height:7),Text('${value.toInt()} / ${goal.toInt()}',style:const TextStyle(color:Colors.greenAccent))]));}
Widget build(BuildContext c)=>Scaffold(backgroundColor:const Color(0xff090b0d),appBar:AppBar(title:const Text('HEALTHTRACK',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:2))),body:ListView(padding:const EdgeInsets.all(16),children:[
Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.greenAccent)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('TODAY\'S MINDSET',style:TextStyle(color:Colors.greenAccent,fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(q[DateTime.now().day%q.length],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))])),
const SizedBox(height:16),
Row(children:[
Expanded(child:_goal('STEPS',d['Steps']!.toDouble(),10000)),
const SizedBox(width:10),
Expanded(child:_goal('WATER',d['Water ml']!.toDouble(),2200)),
]),
const SizedBox(height:16),GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),children:d.keys.map((k)=>Card(child:InkWell(onTap:()=>add(k),child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(k,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(d[k]==0?'ADD':d[k].toString(),style:const TextStyle(fontSize:22,color:Colors.greenAccent))]))))).toList()),
const SizedBox(height:16),
Card(child:ExpansionTile(title:const Text('RECENT HISTORY',style:TextStyle(fontWeight:FontWeight.w900)),children:history.take(8).map((e)=>ListTile(dense:true,title:Text(e['type'].toString()),trailing:Text(e['value'].toString(),style:const TextStyle(color:Colors.greenAccent)),subtitle:Text(e['time'].toString().replaceFirst('T',' ').substring(0,16)))).toList())),
const SizedBox(height:8),
const Text('Records are stored locally. HealthTrack is not a medical diagnosis tool.',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))
]));}
