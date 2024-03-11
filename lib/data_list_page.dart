library devaloop_data_list_page;

import 'package:flutter/material.dart';

class DataListPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<Wrapper> Function() initial;
  final Future<IsAdded> Function(BuildContext context)? add;
  final Future<IsUpdatedOrDeleted> Function(BuildContext context, dynamic id)?
      detail;
  final Future<MapEntry<List<KeyWord>, SearchWrapper>?> Function(
      BuildContext context)? search;
  final Future<Wrapper> Function(Wrapper wrapper)? showMore;

  const DataListPage(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.initial,
      this.add,
      this.search,
      this.showMore,
      this.detail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initial.call(),
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
              initial: () => snapshot.data!,
              showMore: showMore,
              refresh: initial,
              add: add,
              detail: detail,
              search: search,
            );
          }
        });
  }
}

class DataListPageShow extends StatefulWidget {
  final String title;
  final String subtitle;
  final Wrapper Function() initial;
  final Future<IsAdded> Function(BuildContext context)? add;
  final Future<IsUpdatedOrDeleted> Function(BuildContext context, dynamic id)?
      detail;
  final Future<MapEntry<List<KeyWord>, SearchWrapper>?> Function(
      BuildContext context)? search;
  final Future<Wrapper> Function()? refresh;
  final Future<Wrapper> Function(Wrapper wrapper)? showMore;

  const DataListPageShow(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.initial,
      this.add,
      this.search,
      this.refresh,
      this.showMore,
      this.detail});

  @override
  State<DataListPageShow> createState() => _DataListPageShowState();
}

class _DataListPageShowState extends State<DataListPageShow> {
  late Wrapper _wrapper;
  SearchWrapper? _searchWrapper;
  late List<KeyWord> _searchKeyWord;
  late bool _isShowingMore;
  late bool _isRefreshing;
  late bool _isSearchring;
  late bool _isAdding;
  late bool _isSearchClearing;

  @override
  void initState() {
    super.initState();
    _isShowingMore = false;
    _isRefreshing = false;
    _isSearchring = false;
    _isAdding = false;
    _isSearchClearing = false;
    _searchKeyWord = [];
    _wrapper = widget.initial.call();
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
                      _wrapper = await widget.refresh!.call();
                      _searchWrapper = null;
                      _searchKeyWord = [];
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
                var search = await widget.search!.call(context);
                if (search != null) {
                  _searchWrapper = search.value;
                  _searchKeyWord = search.key;
                  _wrapper = _searchWrapper!.searchResult;
                }
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
                var isAdded = await widget.add!.call(context);
                if (isAdded == IsAdded.yes) {
                  _wrapper = await widget.refresh!.call();
                }
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
              subtitle: Text(
                  _searchKeyWord.map((e) => e.toString()).toList().join(" • ")),
              trailing: IconButton(
                  onPressed: () async {
                    setState(() {
                      _isSearchClearing = true;
                    });
                    _wrapper = await widget.refresh!.call();
                    _searchWrapper = null;
                    _searchKeyWord = [];
                    setState(() {
                      _isSearchClearing = false;
                    });
                  },
                  icon: _isSearchClearing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.clear)),
            ),
          _wrapper.data.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(_searchKeyWord.isEmpty
                            ? 'There is no data yet.'
                            : 'No data found.'),
                      ],
                    ),
                  ),
                )
              : Flexible(
                  child: ListView.separated(
                    itemBuilder: (context, index) => _wrapper.data.length !=
                                _wrapper.total &&
                            index ==
                                (_wrapper.data.length +
                                    (_wrapper.data.length != _wrapper.total
                                        ? 1
                                        : 0) -
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
                                          var searchWrapper =
                                              await _searchWrapper!
                                                  .showSearchResultMore!
                                                  .call(
                                                      _wrapper, _searchKeyWord);
                                          _wrapper = searchWrapper.value;
                                          _searchKeyWord = searchWrapper.key;
                                        } else {
                                          _wrapper = await widget.showMore!
                                              .call(_wrapper);
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
                              onTap: widget.detail == null
                                  ? null
                                  : () async {
                                      var result = await widget.detail!.call(
                                          context, _wrapper.data[index].id);
                                      if (result == IsUpdatedOrDeleted.yes) {
                                        setState(() {
                                          _isRefreshing = true;
                                        });
                                        _wrapper = await widget.refresh!.call();
                                        _searchWrapper = null;
                                        _searchKeyWord = [];
                                        setState(() {
                                          _isRefreshing = false;
                                        });
                                      }
                                    },
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
  final Wrapper searchResult;
  Future<MapEntry<List<KeyWord>, Wrapper>> Function(
      Wrapper wrapper, List<KeyWord> searchKeyWord)? showSearchResultMore;

  SearchWrapper(
      {required this.searchResult, required this.showSearchResultMore});
}

class DataItem {
  final dynamic id;
  final String title;
  final String subtitle;

  DataItem({this.id, required this.title, required this.subtitle});
}

class KeyWord {
  final String name;
  final String label;
  final dynamic hiddenValue;
  final String showedValue;

  KeyWord(
      {required this.name,
      required this.label,
      required this.hiddenValue,
      required this.showedValue});

  @override
  String toString() {
    return '$label: $showedValue';
  }
}

enum IsAdded {
  yes,
  no;
}

enum IsUpdatedOrDeleted {
  yes,
  no;
}
