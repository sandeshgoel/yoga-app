import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:yoga/shared/constants.dart';

class SharedInfo {
  late String email;
  late String name;
  late String photo;
  late List<dynamic> routines;
  late List<Routine> routineDetails;
  late List<ConfigParam> exercises;

  SharedInfo(String email, List<dynamic> routines, String name, String photo,
      List<Routine> routineDetails, List<ConfigParam> exercises) {
    this.email = email;
    this.routines = routines;
    this.name = name;
    this.photo = photo;
    this.routineDetails = routineDetails;
    this.exercises = exercises;
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

    // First get all the add/del friend requests from DB
    Map<String, List<Map<String, dynamic>>> reqs = {};
    QuerySnapshot fQueryRef =
        await DBService(uid: uid, email: email).getFriendRequests();
    for (var doc in fQueryRef.docs) {
      print('${doc.id}:${doc.data()}');
      String from = doc.get('from');
      if (!reqs.containsKey(from)) reqs[from] = [];
      reqs[from]!.add(
          {'status': doc.get('status'), 'ts': doc.get('ts'), 'id': doc.id});
    }

    // Act on the most recent request for each peer
    for (String k in reqs.keys) {
      if (reqs[k]![0]['status'] == FRIEND_ADD)
        _rcvdAddFriend(k);
      else // must be FRIEND_DEL
        _rcvdDelFriend(k);

      // Delete all the documents from this email
      for (Map<String, dynamic> m in reqs[k]!)
        await DBService(uid: uid, email: email).deleteFriendDoc(m['id']);
    }

    settings.alignFriends();
    Set<String> f = settings.getFriends();
    Set<String> fP = settings.getFriendsPending();
    Set<String> fR = settings.getFriendsReceived();
    Set<String> fAll = f.union(fP.union(fR));
    print('fAll: $fAll [$f,$fP, $fR]');

    // Get all the sharers
    QuerySnapshot sQueryRef =
        await DBService(uid: uid, email: email).getShared();

    List<SharedInfo> shList = [];
    for (var doc in sQueryRef.docs) {
      String userEmail = doc.id;

      var doc1 = await DBService(uid: uid, email: email)
          .getOtherUserDataByEmail(userEmail);

      YogaSettings settings1 = YogaSettings();
      settings1.settingsFromJson(doc1.data());
      shList.add(SharedInfo(
          userEmail,
          doc.get('routines'),
          settings1.getUser().name,
          settings1.getUser().photo,
          settings1.routines,
          settings1.cps));

      if (fAll.contains(userEmail)) fAll.remove(userEmail);
    }

    // Create profile for friends who are not in sharers
    for (String f in fAll) {
      var doc1 =
          await DBService(uid: uid, email: email).getOtherUserDataByEmail(f);

      YogaSettings settings1 = YogaSettings();
      settings1.settingsFromJson(doc1.data());
      shList.add(SharedInfo(f, [], settings1.getUser().name,
          settings1.getUser().photo, settings1.routines, settings1.cps));
    }

    return shList;
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    return FutureBuilder<List<SharedInfo>>(
        future: _shared(),
        builder:
            (BuildContext context, AsyncSnapshot<List<SharedInfo>> snapshot) {
          Widget ret = Container();

          if (snapshot.hasData) {
            List<SharedInfo> shList = snapshot.data!;
            List<Widget> sharers = [];
            List<Widget> friends = [];
            List<Widget> sent = [];
            List<Widget> received = [];

            shList
                .sort((a, b) => b.routines.length.compareTo(a.routines.length));

            for (SharedInfo e in shList) {
              //print('${e.email}: ${e.name} ${e.routines}');
              Widget w = _socialCard(e);

              if (settings.friendsContains(e.email))
                friends.add(w);
              else if (settings.friendsReceivedContains(e.email))
                received.add(w);
              else if (settings.friendsPendingContains(e.email))
                sent.add(w);
              else if (e.routines.length > 0) sharers.add(w);
            }

            ret = SingleChildScrollView(
              child: Column(
                children: [
                  // Friends

                  Card(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: Text('Friends',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          alignment: Alignment.center,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  friends.length == 0
                      ? Container()
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          children: friends,
                        ),

                  // Top Sharers

                  Card(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: Text('Top Sharers',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          alignment: Alignment.center,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  sharers.length == 0
                      ? Container()
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          children: sharers,
                        ),

                  // Friend Requests Sent

                  sent.length == 0
                      ? Container()
                      : Card(
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: Text('Friend Requests Sent',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                alignment: Alignment.center,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                  sent.length == 0
                      ? Container()
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          children: sent,
                        ),

                  // Friend Requests Received

                  received.length == 0
                      ? Container()
                      : Card(
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: Text('Friend Requests Received',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                alignment: Alignment.center,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                  received.length == 0
                      ? Container()
                      : GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          children: received,
                        ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ]);
          } else {
            ret = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ]);
          }

          return ret;
        });
  }

  Widget _socialCard(
    SharedInfo e,
  ) {
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
            Expanded(flex: 7, child: Container()),
            Expanded(
              flex: 60,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.blue),
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: (e.photo == '')
                            ? AssetImage("assets/icon/yoga_icon_circular.png")
                                as ImageProvider
                            : NetworkImage(e.photo),
                      ),
                    ),
                    //child: BackdropFilter(
                    //    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    //    child: Container()),
                  ),
                  Row(
                    children: [
                      Expanded(child: Container(height: 20)),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.red),
                          color: Colors.white,
                        ),
                        child: FittedBox(
                          child: Text(
                            e.routines.length > 9
                                ? '9'
                                : e.routines.length.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(flex: 6, child: Container()),
            Expanded(
              flex: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      obfuscate(e.name),
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
            Expanded(flex: 7, child: Container()),
          ],
        ),
      ),
    );
  }

  void _listShared(SharedInfo e) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) {
        var width = MediaQuery.of(context).size.width;

        return AlertDialog(
          title: e.routines.length == 0
              ? Text('No routines shared')
              : Text('Routines shared:'),
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          //titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          content: Builder(builder: (context) {
            return Container(
              width: width - 50,
              child: SingleChildScrollView(
                child: Column(
                  children: e.routines
                          .map((r) => _sharedRoutineTile(e, r))
                          .toList() +
                      [
                        e.email == settings.getUser().email
                            ? Container()
                            : Column(
                                children: [
                                  SizedBox(width: 20),
                                  settings.friendsReceivedContains(e.email)
                                      ? Column(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _acceptFriend(e.email);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  Text('Accept friend request'),
                                            ),
                                            SizedBox(width: 20),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _sendDelFriend(e.email);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  Text('Reject friend request'),
                                            )
                                          ],
                                        )
                                      : settings.friendsContains(e.email) |
                                              settings.friendsPendingContains(
                                                  e.email)
                                          ? ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _sendDelFriend(e.email);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  Text('Cancel friend request'),
                                            )
                                          : ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _sendAddFriend(e.email);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child:
                                                  Text('Send friend request'),
                                            ),
                                ],
                              ),
                      ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _sendDelFriend(String userEmail) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String uid = settings.getUser().uid;
    String email = settings.getUser().email;

    settings.delFriendsAll(userEmail);
    DBService(uid: uid, email: email)
        .addFriendRequest(userEmail, FRIEND_REMOVE);
  }

  void _rcvdDelFriend(String userEmail) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    settings.delFriendsAll(userEmail);
  }

  void _acceptFriend(String userEmail) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String uid = settings.getUser().uid;
    String email = settings.getUser().email;

    settings.addFriends(userEmail);
    DBService(uid: uid, email: email).addFriendRequest(userEmail, FRIEND_ADD);
  }

  void _sendAddFriend(String userEmail) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);
    String uid = settings.getUser().uid;
    String email = settings.getUser().email;

    settings.addFriendsPending(userEmail);
    DBService(uid: uid, email: email).addFriendRequest(userEmail, FRIEND_ADD);
  }

  void _rcvdAddFriend(String userEmail) {
    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    if (settings.friendsPendingContains(userEmail))
      settings.addFriends(userEmail);
    else
      settings.addFriendsReceived(userEmail);
  }

  Widget _sharedRoutineTile(SharedInfo e, String r) {
    return Column(
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRoutineDetails(e, r),
                  child: Text(
                    r,
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () => _importRoutine(context, e, r),
                  child: Text('Import')),
              SizedBox(width: 10),
            ],
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  void _showRoutineDetails(SharedInfo e, String r) {
    int i;

    for (i = 0; i < e.routineDetails.length; i++)
      if (e.routineDetails[i].name == r) break;
    Routine rt = e.routineDetails[i];

    showDialog(
      context: context,
      builder: (_) {
        var width = MediaQuery.of(context).size.width;

        return AlertDialog(
          title: Text(r),
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          //titlePadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          content: Builder(builder: (context) {
            return Container(
              width: width - 50,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Exercise',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(child: Container()),
                            Text(
                              'Rounds',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ] +
                      rt.exercises
                          .map((e) => Row(
                                children: [
                                  Text(
                                    e.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    e.rounds.toString(),
                                  ),
                                  SizedBox(width: 20),
                                ],
                              ))
                          .toList(),
                ),
              ),
            );
          }),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context), child: Text('Back'))
          ],
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
          List<String> changedEx = [];

          for (int j = 0; j < e.routineDetails[i].exercises.length; j++) {
            String ename = e.routineDetails[i].exercises[j].name;
            int exIndex = settings.findParamIndex(ename);
            ConfigParam newEx =
                e.exercises.firstWhere((element) => element.name == ename);
            if (exIndex == -1) {
              settings.addParam(newEx);
              print('Added exercise $ename');
            } else {
              ConfigParam oldEx = settings.getParam(exIndex);
              if (!oldEx.equals(newEx)) changedEx.add(ename);
            }
          }
          settings.addRoutine(e.routineDetails[i]);
          Navigator.pop(context);
          if (changedEx.length > 0)
            showMsg(
                context,
                'Routine \'$r\' imported!!' +
                    '\n\nFollowing exercises are part of the imported routine, and they already exist in your config, but are different:\n\n' +
                    changedEx.map((e) => ' - $e').join('\n') +
                    '\n\nWe have retained the original exercise versions. Delete these exercises and reimport the routine if you want the new exercises versions.');
          return;
        }
      Navigator.pop(context);
      showMsg(context, 'Routine \'$r\' not found in config!!');
    } else {
      Navigator.pop(context);
      showMsg(context,
          'Routine \'$r\' already present!!\n\nDelete it to import it again.');
    }
  }
}
