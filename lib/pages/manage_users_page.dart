import 'package:flutter/material.dart';
import 'package:yoga/services/database.dart';
import 'package:yoga/services/settings.dart';
import 'package:provider/provider.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  Future<List<YogaSettings>> _getUsers() async {
    YogaSettings settings = Provider.of<YogaSettings>(context);
    return await DBService(uid: "", email: settings.getUser().email).getUsers();
  }

  @override
  Widget build(BuildContext context) {
    YogaSettings settings = Provider.of<YogaSettings>(context);

    return FutureBuilder<List<YogaSettings>>(
      future: _getUsers(), // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<List<YogaSettings>> snapshot) {
        Widget ret;
        //print('Entering manage_users builder: $snapshot');
        if (snapshot.hasData) {
          List<YogaSettings> users = snapshot.data!;

          ret = Scaffold(
            appBar: AppBar(
              title: Text('Manage Users'),
            ),
            body: _listUsers(settings, users),
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
          ret = Scaffold(
            appBar: AppBar(title: Text('Loading ...')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Container(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                ),
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Loading user data ...'),
                  alignment: Alignment.center,
                )
              ],
            ),
          );
        }
        return ret;
      },
    );
  }

  Widget _listUsers(YogaSettings settings, List<YogaSettings> users) {
    return SingleChildScrollView(
      child: Column(
        children: [
              Container(
                color: Colors.lightBlue,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                padding: const EdgeInsets.all(5),
                child: Text(
                  '${users.length} Users',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ] +
            users
                .map(
                  (e) => Container(
                    //color: Colors.lightBlue[100],
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    child: Column(
                      children: [
                        Column(
                          //mainAxisSize: MainAxisSize.max,
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                e.getUser().email,
                                overflow: TextOverflow.ellipsis,
                                //softWrap: false,
                              ),
                            ),
                            Container(
                              child: Text(
                                e.getUser().name,
                                overflow: TextOverflow.ellipsis,
                                //softWrap: false,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
