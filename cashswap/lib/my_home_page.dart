import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // One item per row
            childAspectRatio: 2, // Adjust the height of the grid items
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: 3, // Number of items in the grid
          itemBuilder: (context, index) {
            String deliveryTime;
            switch (index) {
              case 0:
                deliveryTime = '30 minutes';
                break;
              case 1:
                deliveryTime = '3 hours';
                break;
              case 2:
                deliveryTime = '1 hour 20 minutes';
                break;
              default:
                deliveryTime = 'Unknown';
            }
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.jfif',
                          height: 50,
                          width: 50,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount: \$${(index + 1) * 100}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Title ${index + 1}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Username${index + 1}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Distance: ${(index + 1) * 10} km',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Button'),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.deepPurple.withOpacity(0.1),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Est. delivery time: $deliveryTime',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.deepPurple,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
