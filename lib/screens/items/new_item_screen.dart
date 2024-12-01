import 'package:flutter/material.dart';
import 'package:grand_flow/models/item_model.dart';
import 'package:grand_flow/widgets/item_form.dart';
import 'package:grand_flow/utils/database_helper.dart';

class NewItemScreen extends StatelessWidget {
  final int userId;

  NewItemScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo'),
      ),
      body: ItemForm(
        onSave: (Item item) async {
          // Salvar o item no banco de dados
          await DatabaseHelper().insertItem(item.toMap());
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
