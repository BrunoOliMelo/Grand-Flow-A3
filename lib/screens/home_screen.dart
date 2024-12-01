import 'package:flutter/material.dart';
import 'package:grand_flow/models/item_model.dart';
import 'package:grand_flow/utils/database_helper.dart';
import 'package:grand_flow/screens/items/new_item_screen.dart';
import 'package:grand_flow/screens/items/edit_item_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  TextEditingController _searchController = TextEditingController();
  Set<int> _expandedItems = Set<int>();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_filterItems);
  }

  void _loadItems() async {
    List<Map<String, dynamic>> items =
        await DatabaseHelper().getItems(widget.userId);
    setState(() {
      _items = List<Map<String, dynamic>>.from(
          items); // FAZER A LISTA SER MODIFICÁVEL
      _filteredItems = _items;
    });
  }

  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items.where((item) {
          return item['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _items.add(item);
      _filterItems(); // ATUALIZAR A LISTA FILTRADA
    });
  }

  void _editItem(int index, Map<String, dynamic> item) {
    setState(() {
      _items[index] =
          Map<String, dynamic>.from(item); // GARANTIR QUE O ITEM É MODIFICÁVEL
      _filterItems(); // ATUALIZAR A LISTA FILTRADA
    });
  }

  void _toggleItemCompletion(int index) async {
    setState(() {
      Map<String, dynamic> item = Map<String, dynamic>.from(
          _items[index]); // GARANTIR QUE O ITEM É MODIFICÁVEL
      item['done'] = item['done'] == 1 ? 0 : 1;
      _items[index] = item;
    });
    await DatabaseHelper().updateItem(_items[index]);
    _filterItems(); // ATUALIZAR A LISTA FILTRADA
  }

  void _deleteItem(int id) async {
    await DatabaseHelper().deleteItem(id);
    setState(() {
      _items.removeWhere((item) => item['id'] == id);
      _filterItems(); // ATUALIZAR A LISTA FILTRADA
    });
  }

  void _confirmDeleteItem(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Você realmente deseja apagar este item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id);
              },
              child: Text('Apagar'),
            ),
          ],
        );
      },
    );
  }

  void _toggleDescription(int id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }

  IconData _getDueDateIcon(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) {
      return Icons.error; // ATRASADA
    } else if (dueDate.difference(now).inDays <= 3) {
      return Icons.warning; // FALTAM 3 DIAS OU MENOS
    } else {
      return Icons.check_circle; // DENTRO DO PRAZO
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) {
      return const Color.fromARGB(255, 168, 31, 22); // ATRASADA
    } else if (dueDate.difference(now).inDays <= 3) {
      return const Color.fromARGB(255, 201, 181, 5); // FALTAM 3 DIAS OU MENOS
    } else {
      return const Color.fromARGB(255, 26, 92, 29); // DENTRO DO PRAZO
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pessoal':
        return Colors.blue;
      case 'Trabalho':
        return Colors.orange;
      case 'Estudo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewItemScreen(userId: widget.userId),
      ),
    ).then((itemAdded) {
      if (itemAdded == true) {
        _loadItems();
      }
    });
  }

  IconData _getIconForItem(Map<String, dynamic> item) {
    if (item['type'] == 'task') {
      return Icons.task; // ÍCONES PARA TAREFAS
    } else if (item['type'] == 'reminder') {
      return Icons.alarm; // ÍCONES PARA LEMBRETES
    } else {
      return Icons.help; // ÍCONES PARA OUTROS TIPOS
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar tarefas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ...['Pessoal', 'Trabalho', 'Estudo'].map((category) {
            List<Map<String, dynamic>> categoryItems = _filteredItems
                .where((item) => item['category'] == category)
                .toList();
            return ExpansionTile(
              key: ValueKey(category), // GARANTIR KEYS ÚNICAS
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              children: categoryItems.map((item) {
                int index = _items.indexOf(item);
                DateTime dueDate = DateTime.parse(item['dueDateTime']);
                return Column(
                  children: [
                    ListTile(
                      key: ValueKey(
                          '${item['type']}_${item['id']}'), // GARANTIR KEYS ÚNICAS
                      title: Row(
                        children: [
                          Checkbox(
                            value: item['done'] == 1,
                            onChanged: (bool? value) {
                              _toggleItemCompletion(index);
                            },
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getIconForItem(item),
                                    color: item['type'] == 'task'
                                        ? Colors.blue
                                        : Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: item['done'] == 1
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${dueDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(dueDate).format(context)}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    _getDueDateIcon(dueDate),
                                    color: _getDueDateColor(dueDate),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditItemScreen(
                                    item: Item.fromMap(item),
                                  ),
                                ),
                              ).then((_) {
                                _loadItems();
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeleteItem(item['id']);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _toggleDescription(item['id']);
                      },
                    ),
                    if (_expandedItems.contains(item['id']))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(item['description'] ?? ''),
                        ),
                      ),
                  ],
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
