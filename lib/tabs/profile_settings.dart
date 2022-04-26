import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        const Text('    Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 20),

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
                      'Albert Wickman',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1
                      ),
                    ),
                    Text(
                      'albert.wickman@hotmail.se',
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
        buildSettingItem(context, 'My Account', 'Make changes to my profile'),
        const Divider(height: 0, indent: 20, endIndent: 20),

        buildSettingItem(context, 'Notifications', 'Adjust notificaton settings'),
        const Divider(height: 0, indent: 20, endIndent: 20),

        buildSettingItem(context, 'Help', 'Read FAQ'),
        const Divider(height: 0, indent: 20, endIndent: 20),

        buildSettingItem(context, 'About Elli', 'Read more about Elli'),
        const Divider(height: 0, indent: 20, endIndent: 20),

        buildSettingItem(context, 'Log Out', 'Leave the application'),
        const Divider(height: 0, indent: 20, endIndent: 20),
      ],
    );

  }

  GestureDetector buildSettingItem(BuildContext context, String title, String subtitle) {
    return GestureDetector(
      onTap: () {

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
}