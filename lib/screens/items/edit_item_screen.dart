import 'package:flutter/material.dart';
import 'package:grand_flow/models/item_model.dart';
import 'package:grand_flow/widgets/item_form.dart';
import 'package:grand_flow/utils/database_helper.dart';

class EditItemScreen extends StatelessWidget {
  final Item item;

  EditItemScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar'),
      ),
      body: ItemForm(
        item: item,
        onSave: (Item updatedItem) async {
          // Atualizar o item no banco de dados
          await DatabaseHelper().updateItem(updatedItem.toMap());
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
