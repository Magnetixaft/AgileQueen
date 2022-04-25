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
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: ClipRRect(
                      child: Image.network('https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png'),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
