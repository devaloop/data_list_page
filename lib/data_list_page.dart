library devaloop_data_list_page;

import 'package:flutter/material.dart';

class DataListPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<Wrapper> wrapper;
  final Future<Wrapper>? add;
  final Future<SearchWrapper>? search;
  final Future<Wrapper>? refresh;
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
              refresh: refresh,
              add: add,
              search: search,
            );
          }
        });
  }
}

class DataListPageShow extends StatefulWidget {
  final String title;
  final String subtitle;
  final Wrapper wrapper;
  final Future<Wrapper>? add;
  final Future<SearchWrapper>? search;
  final Future<Wrapper>? refresh;
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
  SearchWrapper? _searchWrapper;
  late bool _isShowingMore;
  late bool _isRefreshing;
  late bool _isSearchring;
  late bool _isAdding;

  @override
  void initState() {
    super.initState();
    _isShowingMore = false;
    _isRefreshing = false;
    _isSearchring = false;
    _isAdding = false;
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
          if (widget.refresh != null)
            IconButton(
              onPressed: _isRefreshing
                  ? null
                  : () async {
                      setState(() {
                        _isRefreshing = true;
                      });
                      _wrapper = await widget.refresh!;
                      _searchWrapper = null;
                      setState(() {
                        _isRefreshing = false;
                      });
                    },
              icon: _isRefreshing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.refresh),
            ),
          if (widget.search != null)
            IconButton(
              onPressed: () async {
                setState(() {
                  _isSearchring = true;
                });
                _searchWrapper = await widget.search!;
                _wrapper = _searchWrapper!.searchResult;
                setState(() {
                  _isSearchring = false;
                });
              },
              icon: _isSearchring
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _searchWrapper != null
                      ? const Icon(Icons.search_off)
                      : const Icon(Icons.search),
            ),
          if (widget.add != null)
            IconButton(
              onPressed: () async {
                setState(() {
                  _isAdding = true;
                });
                _wrapper = await widget.add!;
                setState(() {
                  _isAdding = false;
                });
              },
              icon: _isAdding
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.add),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_searchWrapper != null)
            ListTile(
              title: const Text('Search Keyword'),
              subtitle: Text(_searchWrapper!.searchKeyWord),
              trailing: IconButton(
                  onPressed: () {
                    //TODO Implement Clear Search
                  },
                  icon: const Icon(Icons.clear)),
            ),
          Flexible(
            child: ListView.separated(
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
                                  if (_searchWrapper != null) {
                                    _wrapper = await _searchWrapper!
                                        .showSearchResultMore!
                                        .call(_wrapper);
                                  } else {
                                    _wrapper =
                                        await widget.showMore!.call(_wrapper);
                                  }
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
          ),
        ],
      ),
    );
  }
}

class Wrapper {
  final int total;
  final List<DataItem> data;

  Wrapper({required this.total, required this.data});
}

class SearchWrapper {
  final String searchKeyWord;
  final Wrapper searchResult;
  Future<Wrapper> Function(Wrapper wrapper)? showSearchResultMore;

  SearchWrapper(
      {required this.searchKeyWord,
      required this.searchResult,
      required this.showSearchResultMore});
}

class DataItem {
  final dynamic id;
  final String title;
  final String subtitle;

  DataItem({this.id, required this.title, required this.subtitle});
}
