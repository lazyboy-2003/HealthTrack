import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
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
Future<void> cameraPulse() async {
  try {
    final cams=await availableCameras();
    final back=cams.firstWhere((x)=>x.lensDirection==CameraLensDirection.back,orElse:()=>cams.first);
    if(!mounted)return;
    final bpm=await Navigator.push<double>(context,MaterialPageRoute(builder:(_)=>PulseCamera(camera:back)));
    if(bpm!=null){d['Pulse']=bpm;history.insert(0,{'type':'Pulse (camera)','value':bpm,'time':DateTime.now().toIso8601String()});final p=await SharedPreferences.getInstance();await p.setString('health',jsonEncode(d));await p.setString('history',jsonEncode(history));setState((){});}
  } catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Camera is unavailable.')));}
}
Widget build(BuildContext c)=>Scaffold(backgroundColor:const Color(0xff090b0d),appBar:AppBar(title:const Text('HEALTHTRACK',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:2))),body:ListView(padding:const EdgeInsets.all(16),children:[
Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.greenAccent)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('TODAY\'S MINDSET',style:TextStyle(color:Colors.greenAccent,fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(q[DateTime.now().day%q.length],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))])),
const SizedBox(height:16),
Row(children:[
Expanded(child:_goal('STEPS',d['Steps']!.toDouble(),10000)),
const SizedBox(width:10),
Expanded(child:_goal('WATER',d['Water ml']!.toDouble(),2200)),
]),
const SizedBox(height:12),
FilledButton.icon(onPressed:cameraPulse,icon:const Icon(Icons.camera_alt),label:const Text('MEASURE PULSE WITH CAMERA + FLASH')),
const SizedBox(height:16),GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),children:d.keys.map((k)=>Card(child:InkWell(onTap:()=>add(k),child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(k,style:const TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(d[k]==0?'ADD':d[k].toString(),style:const TextStyle(fontSize:22,color:Colors.greenAccent))]))))).toList()),
const SizedBox(height:16),
Card(child:ExpansionTile(title:const Text('RECENT HISTORY',style:TextStyle(fontWeight:FontWeight.w900)),children:history.take(8).map((e)=>ListTile(dense:true,title:Text(e['type'].toString()),trailing:Text(e['value'].toString(),style:const TextStyle(color:Colors.greenAccent)),subtitle:Text(e['time'].toString().replaceFirst('T',' ').substring(0,16)))).toList())),
const SizedBox(height:8),
const Text('Records are stored locally. HealthTrack is not a medical diagnosis tool.',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))
]));}

class PulseCamera extends StatefulWidget{
 final CameraDescription camera; const PulseCamera({super.key,required this.camera});
 State<PulseCamera> createState()=>_PulseCameraState();
}
class _PulseCameraState extends State<PulseCamera>{
 CameraController? ctl; final List<double> signal=[]; final List<DateTime> times=[]; bool measuring=false; double progress=0; String status='Place fingertip gently over the rear camera and flash.';
 @override void initState(){super.initState();setup();}
 Future<void> setup()async{final c=CameraController(widget.camera,ResolutionPreset.low,enableAudio:false,imageFormatGroup:ImageFormatGroup.yuv420);ctl=c;await c.initialize();try{await c.setFlashMode(FlashMode.torch);}catch(_){}
 if(mounted)setState((){});}
 Future<void> start()async{if(ctl==null||!ctl!.value.isInitialized||measuring)return;signal.clear();times.clear();measuring=true;progress=0;status='Keep your finger still…';setState((){});
 final begin=DateTime.now();await ctl!.startImageStream((img){if(!measuring)return;final now=DateTime.now();if(now.difference(begin).inSeconds>=30){finish();return;}
 final plane=img.planes.first.bytes; if(plane.isEmpty)return; double sum=0;int n=0;for(int i=0;i<plane.length;i+=80){sum+=plane[i];n++;}signal.add(sum/n);times.add(now);if(signal.length%8==0&&mounted)setState(()=>progress=now.difference(begin).inMilliseconds/30000);});
 }
 Future<void> finish()async{if(!measuring)return;measuring=false;try{await ctl!.stopImageStream();}catch(_){}
 final bpm=estimate();if(!mounted)return;if(bpm>=40&&bpm<=200){Navigator.pop(context,bpm.roundToDouble());}else{setState((){status='Signal was not clear. Reposition your finger and try again.';progress=0;});}}
 double estimate(){if(signal.length<40)return 0;final mean=signal.reduce((a,b)=>a+b)/signal.length;final centered=signal.map((x)=>x-mean).toList();final threshold=centered.map((x)=>x.abs()).reduce((a,b)=>a+b)/centered.length*.55;final peaks=<DateTime>[];for(int i=2;i<centered.length-2;i++){if(centered[i]>threshold&&centered[i]>centered[i-1]&&centered[i]>=centered[i+1]){if(peaks.isEmpty||times[i].difference(peaks.last).inMilliseconds>300)peaks.add(times[i]);}}if(peaks.length<3)return 0;final seconds=peaks.last.difference(peaks.first).inMilliseconds/1000;return (peaks.length-1)*60/seconds;}
 @override void dispose(){measuring=false;ctl?.dispose();super.dispose();}
 Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('CAMERA PULSE')),body:Padding(padding:const EdgeInsets.all(20),child:Column(children:[
  if(ctl!=null&&ctl!.value.isInitialized)Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(24),child:CameraPreview(ctl!)))else const Expanded(child:Center(child:CircularProgressIndicator())),
  const SizedBox(height:18),Text(status,textAlign:TextAlign.center,style:const TextStyle(fontSize:16,fontWeight:FontWeight.bold)),const SizedBox(height:14),
  LinearProgressIndicator(value:measuring?progress:0,minHeight:10,borderRadius:BorderRadius.circular(8)),const SizedBox(height:18),
  SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:measuring?null:start,icon:const Icon(Icons.favorite),label:Text(measuring?'MEASURING 30 SEC…':'START 30-SECOND MEASUREMENT'))),
  const SizedBox(height:10),const Text('Wellness estimate only — not a medical device.',style:TextStyle(color:Colors.grey,fontSize:12))
 ])));
}
