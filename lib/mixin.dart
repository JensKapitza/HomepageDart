library mixin_nav;

import 'package:flutter/material.dart';

List<Widget> returnNavBarList(BuildContext context, List<String> items,
    Function(BuildContext, String) onPressdFnc) {
  List<Widget> myList = [];
  for (int i = 0; i < items.length ?? 0; i++) {
    myList.add(
      ElevatedButton(
        onPressed: () {
          onPressdFnc(context, items[i]);
        },
        child: Text(items[i]),
      ),
    );

    myList.add(SizedBox(
      width: 10,
    ));
  }

  myList.add(SizedBox(
    width: 250,
  ));

  return myList;
}
