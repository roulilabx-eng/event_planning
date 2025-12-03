import 'package:flutter/material.dart';

class ParticipantSettingsWidget extends StatefulWidget {
  final DateTime eventTime;
  final List<String> participants;
  final Function(DateTime, List<String>) onSave; // 回傳修改後時間與名單

  const ParticipantSettingsWidget({
    super.key,
    required this.eventTime,
    required this.participants,
    required this.onSave,
  });

  @override
  State<ParticipantSettingsWidget> createState() => _ParticipantSettingsWidgetState();
}

class _ParticipantSettingsWidgetState extends State<ParticipantSettingsWidget> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late TextEditingController _secondController;
  late TextEditingController _participantsController;

  @override
  void initState() {
    super.initState();
    _hourController = TextEditingController(text: widget.eventTime.hour.toString());
    _minuteController = TextEditingController(text: widget.eventTime.minute.toString());
    _secondController = TextEditingController(text: widget.eventTime.second.toString());
    _participantsController = TextEditingController(text: widget.participants.join(', '));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('開發人員設定'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('活動時間 (24小時制)'),
            Row(
              children: [
                Expanded(child: TextField(controller: _hourController, decoration: const InputDecoration(labelText: '時'))),
                Expanded(child: TextField(controller: _minuteController, decoration: const InputDecoration(labelText: '分'))),
                Expanded(child: TextField(controller: _secondController, decoration: const InputDecoration(labelText: '秒'))),
              ],
            ),
            const SizedBox(height: 20),
            const Text('參加者名單 (用逗號分隔)'),
            TextField(controller: _participantsController, maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            // 🔴 回傳修改後的時間與名單
            int h = int.tryParse(_hourController.text) ?? widget.eventTime.hour;
            int m = int.tryParse(_minuteController.text) ?? widget.eventTime.minute;
            int s = int.tryParse(_secondController.text) ?? widget.eventTime.second;
            DateTime newTime = DateTime(widget.eventTime.year, widget.eventTime.month, widget.eventTime.day, h, m, s);

            List<String> newParticipants = _participantsController.text.split(',').map((e) => e.trim()).toList();

            widget.onSave(newTime, newParticipants);
            Navigator.pop(context);
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }
}
