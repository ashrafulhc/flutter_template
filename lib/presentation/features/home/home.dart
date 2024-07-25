import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Home Screen'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          },
        ),
      ),
      drawer: const Drawer(
        child: Padding(
          padding: EdgeInsets.only(top: kToolbarHeight),
          child: Column(
            children: [
              Text('Hello World!'),
              Text('Hello World!'),
              Text('Hello World!'),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              // height: double.infinity,
              // width: double.infinity,
              color: Colors.amber,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: kToolbarHeight * 2),
                const Text('Demo of a textfield'),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  onChanged: (value) {
                    print('onChange: $value)');
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter City Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final value = _controller.text;
                    print('textfield value: $value');
                    _controller.text = 'Done';
                  },
                  child: const Text('Submit!'),
                ),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      print(constraints);
                      return const ColoredBox(
                        color: Colors.red,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
