import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExpandableShowWidget extends StatefulWidget {
  Widget child;
  Widget showMore;
  Color arrowColor;
  ExpandableShowWidget({super.key, required this.showMore, required this.child, required this.arrowColor});

  @override
  State<ExpandableShowWidget> createState() => _ExpandableShowWidgetState();
}

class _ExpandableShowWidgetState extends State<ExpandableShowWidget> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.showMore,

                  Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: widget.arrowColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? 200.0 : 0.0,
          child: SingleChildScrollView(
            child: Padding(padding: EdgeInsets.all(16.0), child: widget.child),
          ),
        ),
      ],
    );
  }
}
