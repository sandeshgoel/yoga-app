import 'package:flutter/material.dart';

class IncDecButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initValue;

  final ValueChanged<int> onChanged;

  IncDecButton(
      {this.initValue = 0,
      this.minValue = 1,
      this.maxValue = 10,
      required this.onChanged});

  @override
  State<IncDecButton> createState() {
    return _IncDecButtonState();
  }
}

class _IncDecButtonState extends State<IncDecButton> {
  int counter = 0;
  bool first = true;

  @override
  Widget build(BuildContext context) {
    if (first) {
      counter = widget.initValue;
      first = false;
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: Theme.of(context).accentColor,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
            iconSize: 32.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.onChanged(counter);
              });
            },
          ),
          Text(
            '$counter',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).accentColor,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
            iconSize: 32.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.onChanged(counter);
                print('Pressed +, $counter');
              });
            },
          ),
        ],
      ),
    );
  }
}
