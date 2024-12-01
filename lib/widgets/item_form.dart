import 'package:flutter/material.dart';
import 'package:grand_flow/models/item_model.dart';

class ItemForm extends StatefulWidget {
  final Item? item;
  final Function(Item) onSave;

  ItemForm({this.item, required this.onSave});

  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  late String _name;
  late String _description;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late String _category;
  late String _type;

  @override
  void initState() {
    super.initState();
    _name = '';
    _description = '';
    _dueDate = DateTime.now();
    _dueTime = TimeOfDay.now();
    _category = 'Pessoal';
    _type = 'task'; // Default type

    if (widget.item != null) {
      _name = widget.item!.name;
      _description = widget.item!.description;
      _dueDate = widget.item!.dueDateTime;
      _dueTime = TimeOfDay.fromDateTime(_dueDate);
      _category = widget.item!.category;
      _type = widget.item!.type;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateController.text = _dueDate.toLocal().toString().split(' ')[0];
    _timeController.text = _dueTime.format(context);
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        _dateController.text = _dueDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
        _timeController.text = _dueTime.format(context);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DateTime dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );
      Item item = Item(
        id: widget.item?.id,
        userId: widget.item?.userId ?? 0,
        name: _name,
        description: _description,
        dueDateTime: dueDateTime,
        category: _category,
        type: _type,
      );
      widget.onSave(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Hora'),
                readOnly: true,
                onTap: () => _selectTime(context),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Categoria'),
                items: ['Pessoal', 'Trabalho', 'Estudo']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(labelText: 'Tipo'),
                items: ['task', 'reminder']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type == 'task' ? 'Tarefa' : 'Lembrete'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
