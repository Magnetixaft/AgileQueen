import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  /*bool valNotify = false;

  onChangeFunction(bool newValue) {
    setState(() {
      valNotify = newValue;
    });
  }
  */

  @override
  Widget build(BuildContext context) {

    /// Builds the header.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        const Text('    Menu',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 20),


        /// Builds a profile box with a name, email and user icon.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(6))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: ClipRRect(
                      child: Image.network('https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png'), // temporary image
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text(
                      'Albert Wickman', // TODO get name
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1
                      ),
                    ),
                    Text(
                      'albert.wickman@hotmail.se', // TODO get email
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),



        /// Calls the builder method to build each item.

        _buildSettingItem(context, 'Help', 'Read FAQ'),
        const Divider(height: 0, indent: 20, endIndent: 20),

        _buildSettingItem(context, 'About Elli', 'Read more about Elli'),
        const Divider(height: 0, indent: 20, endIndent: 20),

        _buildSettingItem(context, 'Log Out', 'Leave the application'),
        const Divider(height: 0, indent: 20, endIndent: 20),


      ],
    );

  }

  /// Builder method which creates a setting item with title and subtitle.
  GestureDetector _buildSettingItem(BuildContext context, String title, String subtitle) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        print('Item Tapped');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 8),
                  Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.grey
                      )),
                ],
              ),
            ),
            const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey
            )
          ],
        ),
      ),
    );
  }

/*
  GestureDetector _buildToggleItem(BuildContext context, String title, String subtitle, bool value, Function onChangeMethod) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 8),
                  Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.grey
                      )),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.7,
              child: CupertinoSwitch(
                activeColor: Colors.blue,
                value: value,
                onChanged: (bool newValue) {
                  onChangeMethod(newValue);
                  print(newValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
}