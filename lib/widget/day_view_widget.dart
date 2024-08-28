import 'package:flutter/material.dart';
import 'package:rcare_2/screen/home/TimeSheetDetail.dart';
import 'package:rcare_2/screen/home/models/ConfirmedResponseModel.dart';

import '../calendar/day_view/day_view.dart';
import '../calendar/enumerations.dart';
import '../calendar/modals.dart';
import '../screen/home/HomeScreen.dart';

class DayViewWidget extends StatelessWidget {
  final GlobalKey<DayViewState>? state;
  final double? width;
  final DateTime? minDay;
  final DateTime? maxDay;

  const DayViewWidget({
    super.key,
    this.state,
    this.width,
    this.minDay,
    this.maxDay
  });

  @override
  Widget build(BuildContext context) {
    return DayView(
      key: state,
      width: width,
      minDay: minDay,
      maxDay: maxDay,
      initialDay: DateTime(2021),
      startDuration: Duration(hours: 8),
      showHalfHours: true,
      heightPerMinute: 1.5,
      timeLineBuilder: _timeLineBuilder,
      hourIndicatorSettings: HourIndicatorSettings(
        color: Theme.of(context).dividerColor,
      ),
      onEventTap: (events, date) {

        Navigator.of(keyScaffold.currentContext!).push(
          MaterialPageRoute(
            builder: (_) => TimeSheetDetail(
              model: events.first.event as TimeShiteModel,
              indexSelectedFrom: 1,
            ),
          ),
        );
      },
      halfHourIndicatorSettings: HourIndicatorSettings(
        color: Theme.of(context).dividerColor,
        lineStyle: LineStyle.dashed,
      ),
    );
  }

  Widget _timeLineBuilder(DateTime date) {
    if (date.minute != 0) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: -8,
            right: 8,
            child: Text(
              "${date.hour}:${date.minute}",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.black.withAlpha(50),
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    final hour = ((date.hour - 1) % 12) + 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          top: -8,
          right: 8,
          child: Text(
            "$hour ${date.hour ~/ 12 == 0 ? "am" : "pm"}",
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
/*
 Navigator.push(
          MaterialPageRoute(
            builder: (context) => TimeSheetDetail(
              model: events.first.event as TimeShiteModel,
              indexSelectedFrom:
              1,
            )
          ),
        );
 */