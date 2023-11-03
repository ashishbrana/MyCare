import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmedTabScreen extends StatefulWidget {
  const ConfirmedTabScreen({super.key});

  @override
  State<ConfirmedTabScreen> createState() => _ConfirmedTabScreenState();
}

class _ConfirmedTabScreenState extends State<ConfirmedTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Bump,Donald",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Domestic",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(
                              CupertinoIcons.person_crop_circle,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: Colors.grey.shade700,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            child: Icon(
                              Icons.arrow_downward_rounded,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Mon, 16-10-2023",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 1,
                            height: 25,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            CupertinoIcons.time,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "1hrs",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 1,
                            height: 25,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 5),
                          const Expanded(child: Icon(Icons.timelapse_rounded)),
                          const SizedBox(width: 5),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.timer,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "12:50:00 - 13:50:00",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Align(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
