import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../components/custom_button.dart';
import '../../../utils/resources/Colors.dart';
import '../../provider/widgets/sessions_button.dart';

class FeedbackSuccess extends StatelessWidget {
  const FeedbackSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(14),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  offset: Offset(1, 1),
                  blurRadius: 5,
                  spreadRadius: 2,
                  color: Colors.black.withOpacity(0.1))
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Image.asset(
                'assets/icons/ic_check.png',
                height: 82,
                width: 82,
                color: colorPrimary,
              ),
            ),
            Text(
              'Thank You',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: Text(
                'Your feedback is valuable to us.\nWould you like to review on the plasystore?',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * 0.05, bottom: size.height * 0.01),
              child: Row(
                children: [
                  Expanded(
                      child: SessionButton(
                          isOutlined: true,
                          title: 'Later',
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          })),
                  SizedBox(
                    width: 11,
                  ),
                  Expanded(
                      flex: 2,
                      child: SessionButton(
                          color: colorAccent,
                          title: 'Sure, Rate & Review',
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            // push(context, BookSessionMain());
                          })),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
