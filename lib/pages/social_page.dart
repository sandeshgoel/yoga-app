import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class SharedInfo {
  late String email;
  late String uid;
  late String name;
  late String photo;
  late List<dynamic> routines;
  late List<Routine> routineDetails;

  SharedInfo(String email, String uid, List<dynamic> routines, String name,
      String photo, List<Routine> routineDetails) {
    this.email = email;
    this.uid = uid;
    this.routines = routines;
    this.name = name;
    this.photo = photo;
    this.routineDetails = routineDetails;
  }

  @override
  String toString() {
    return '$email:$name $routines';
  }
}

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  Future<List<SharedInfo>> _shared() async {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String uid = settings.getUser().uid;
    String email = settings.getUser().email;
    List<SharedInfo> shList = [];

    QuerySnapshot queryRef =
        await DBService(uid: uid, email: email).getShared();

    for (var doc in queryRef.docs) {
      var doc1 = await DBService(uid: uid, email: email)
          .getOtherUserData(doc.get('uid'));

      YogaSettings settings1 = YogaSettings();
      settings1.settingsFromJson(doc1.data());
      shList.add(SharedInfo(
          doc.id,
          doc.get('uid'),
          doc.get('routines'),
          settings1.getUser().name,
          settings1.getUser().photo,
          settings1.routines));
    }
    return shList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SharedInfo>>(
        future: _shared(), // a previously-obtained Future<String> or null
        builder:
            (BuildContext context, AsyncSnapshot<List<SharedInfo>> snapshot) {
          Widget ret = Container();

          if (snapshot.hasData) {
            List<SharedInfo> shList = snapshot.data!;
            List<Widget> children = [];

            for (SharedInfo e in shList) {
              print('${e.email}: ${e.name} ${e.routines}');
              if (e.routines.length > 0) children.add(_socialCard(e));
            }

            ret = GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(20),
              children: children,
            );
          }
          return ret;
        });
  }

  Widget _socialCard(SharedInfo e) {
    return GestureDetector(
      onTap: () {
        _listShared(e);
      },
      child: Card(
        color: Colors.white.withOpacity(0.9),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: [
            Expanded(flex: 5, child: Container()),
            Expanded(
              flex: 60,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.blue),
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: (e.photo == '')
                          ? AssetImage("assets/icon/yoga_icon_circular.png")
                              as ImageProvider
                          : NetworkImage(e.photo)),
                ),
              ),
            ),
            Expanded(flex: 10, child: Container()),
            Expanded(
              flex: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.name,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 5, child: Container()),
          ],
        ),
      ),
    );
  }

  void _listShared(SharedInfo e) {
    showDialog(
      context: context,
      builder: (_) {
        var width = MediaQuery.of(context).size.width;

        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          //titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          content: Builder(builder: (context) {
            return Container(
              width: width - 50,
              child: SingleChildScrollView(
                child: Column(
                  children: e.routines
                      .map((r) => Column(
                            children: [
                              Card(
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        r,
                                        style: settingsTextStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                        onPressed: () =>
                                            _importRoutine(context, e, r),
                                        child: Text('Import')),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ))
                      .toList(),
                ),
              ),
            );
          }),
          title: Text('Routines shared:'),
        );
      },
    );
  }

  void _importRoutine(context, SharedInfo e, String r) async {
    print('Importing routine $r from $e');

    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    int rindex = settings.findRoutineIndex(r);
    if (rindex == -1) {
      for (int i = 0; i < e.routineDetails.length; i++)
        if (e.routineDetails[i].name == r) {
          settings.addRoutine(e.routineDetails[i]);
          Navigator.pop(context);
          showMsg(context, 'Routine \'$r\' imported!!');
          return;
        }
      Navigator.pop(context);
      showMsg(context, 'Routine \'$r\' not found in config!!');
    } else {
      Navigator.pop(context);
      showMsg(context, 'Routine \'$r\' already present!!');
    }
  }
}
