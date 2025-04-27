import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class ActionsPopoverButton extends StatelessWidget {
  const ActionsPopoverButton({super.key, required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showPopover(
          context: context,
          bodyBuilder: (context) => Column(children:[
            ListTile(
              trailing: Icon(Icons.edit),
              title: Text('Edit'),
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              onTap: () {
                onEdit();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              trailing: Icon(Icons.delete),
              title: Text('Delete'),
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              onTap: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ]),
          direction: PopoverDirection.bottom,
          width: 125,
          height: 100,
          arrowHeight: 15,
          arrowWidth: 30,
        );
      },
      icon: Icon(Icons.more_vert),
    );
  }
}
