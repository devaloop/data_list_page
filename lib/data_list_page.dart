library devaloop_data_list_page;

import 'package:flutter/material.dart';

class DataListPage extends StatefulWidget {
  final void Function()? onAdd;
  final void Function()? onSearch;

  const DataListPage({super.key, this.onAdd, this.onSearch});

  @override
  State<DataListPage> createState() => _DataListPageState();
}

class _DataListPageState extends State<DataListPage> {
  final List<DataItem> db = List.generate(
      25,
      (index) =>
          DataItem(title: 'Data ${index + 1}', subtitle: 'Data ${index + 1}'));
  late Wrapper _wrapper;

  @override
  void initState() {
    super.initState();
    _wrapper =
        Wrapper(total: db.length, showed: 10, data: db.take(10).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ListTile(
          title: Text(
            'Product Inventory',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'Product Inventory',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.5),
            child: Text('10 of 200'),
          ),
          if (widget.onSearch != null)
            IconButton(
              onPressed: widget.onSearch,
              icon: const Icon(Icons.search),
            ),
          if (widget.onAdd != null)
            IconButton(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => _wrapper.data.length !=
                    _wrapper.total &&
                index ==
                    (_wrapper.data.length +
                        (_wrapper.data.length != _wrapper.total ? 1 : 0) -
                        1)
            ? Padding(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        var data = db.take(_wrapper.data.length + 10).toList();
                        _wrapper = Wrapper(
                            total: db.length, showed: data.length, data: data);
                      });
                    },
                    icon: const Icon(Icons.arrow_circle_down),
                    label: const Text('SHOW MORE (190)'),
                  ),
                ),
              )
            : Card(
                child: ListTile(
                  leading: const Icon(Icons.more_vert),
                  title: Text(_wrapper.data[index].title),
                  subtitle: Text(_wrapper.data[index].subtitle),
                ),
              ),
        separatorBuilder: (context, index) => const SizedBox(
          height: 7.5,
        ),
        itemCount: _wrapper.data.length +
            (_wrapper.data.length != _wrapper.total ? 1 : 0),
      ),
    );
  }
}

class Wrapper {
  final int total;
  final int showed;
  final List<DataItem> data;

  Wrapper({required this.total, required this.showed, required this.data});
}

class DataItem {
  final dynamic id;
  final String title;
  final String subtitle;

  DataItem({this.id, required this.title, required this.subtitle});
}
