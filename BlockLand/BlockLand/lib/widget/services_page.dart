import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:land_registration/constant/constants.dart';
import 'package:universal_html/html.dart' as html;
import '../constant/utils.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Our Services'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Add your service descriptions here
        child: Column(
          children: [
            Text(
              'We offer a range of services to meet your needs:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // ... service descriptions
          ],
        ),
      ),
    );
  }
}
