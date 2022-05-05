import 'package:flutter/material.dart';

//This class represents the detailed my bookings view.
class DetailedView extends StatelessWidget {
  final String _place;
  final String _address;
  final String _date;
  final String _description;
  final String _timeslot;
  final String _attribute;

  const DetailedView(this._place, this._address, this._date,
      this._description, this._timeslot, this._attribute,
      {Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      color: Colors.white,
      height: 300,
      width: 150,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Text(
                  _place,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(_date),
                Text(_timeslot),
                const SizedBox(height: 10),
                Text(_description),
                const SizedBox(height: 10),
                Text(_attribute),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
