library devaloop_data_list_page;

import 'package:flutter/material.dart';

class DataListPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<Wrapper> wrapper;
  final void Function()? add;
  final void Function()? search;
  final Future<Wrapper> Function(Wrapper wrapper)?
      refresh; //TODO Implement Refresh
  final Future<Wrapper> Function(Wrapper wrapper)? showMore;

  const DataListPage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.wrapper,
      this.add,
      this.search,
      this.refresh,
      this.showMore});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: wrapper,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: ListTile(
                  title: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return DataListPageShow(
              title: title,
              subtitle: subtitle,
              wrapper: snapshot.data!,
              showMore: showMore,
            );
          }
        });
  }
}

class DataListPageShow extends StatefulWidget {
  final String title;
  final String subtitle;
  final Wrapper wrapper;
  final void Function()? add;
  final void Function()? search;
  final void Function()? refresh;
  final Future<Wrapper> Function(Wrapper wrapper)? showMore;

  const DataListPageShow(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.wrapper,
      this.add,
      this.search,
      this.refresh,
      this.showMore});

  @override
  State<DataListPageShow> createState() => _DataListPageShowState();
}

class _DataListPageShowState extends State<DataListPageShow> {
  late Wrapper _wrapper;
  late bool _isShowingMore;

  @override
  void initState() {
    super.initState();
    _isShowingMore = false;
    _wrapper = widget.wrapper;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.subtitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.5),
            child: Text('${_wrapper.data.length} of ${_wrapper.total}'),
          ),
          if (widget.search != null)
            IconButton(
              onPressed: widget.search,
              icon: const Icon(Icons.search),
            ),
          if (widget.add != null)
            IconButton(
              onPressed: widget.add,
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
                  child: FilledButton.icon(
                    onPressed: _isShowingMore
                        ? null
                        : () async {
                            setState(() {
                              _isShowingMore = true;
                            });
                            _wrapper = await widget.showMore!.call(_wrapper);
                            setState(() {
                              _isShowingMore = false;
                            });
                          },
                    icon: _isShowingMore
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.arrow_circle_down),
                    label: Text(
                        'SHOW MORE (${_wrapper.total - _wrapper.data.length})'),
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
  final List<DataItem> data;

  Wrapper({required this.total, required this.data});
}

class DataItem {
  final dynamic id;
  final String title;
  final String subtitle;

  DataItem({this.id, required this.title, required this.subtitle});
}
