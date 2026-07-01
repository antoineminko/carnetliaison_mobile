import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  int start = -1;
  int end = -1;
  
  for(int i=0; i<lines.length; i++) {
    if(lines[i].contains('void _onChildSelected')) {
      start = i;
      int braceCount = 0;
      bool started = false;
      for(int j=i; j<lines.length; j++) {
        for(int k=0; k<lines[j].length; k++) {
          if(lines[j][k] == '{') { braceCount++; started = true; }
          if(lines[j][k] == '}') { braceCount--; }
        }
        if(started && braceCount == 0) {
          end = j;
          break;
        }
      }
      break;
    }
  }
  
  if (start != -1 && end != -1) {
    lines.removeRange(start, end + 1);
    lines.insert(start, r'''  void _onChildSelected(int index) {
    setState(() {
      _selectedChildIndex = index;
      if (index < _childrenData.length) {
        _childrenData[index]['notif'] = 0;
      }

      final currentChild = index < _childrenData.length
          ? _childrenData[index]
          : null;
          
      if (currentChild != null) {
        _selectedChild = {
          'name': currentChild['name'],
          'prenom': currentChild['prenom'] ?? currentChild['name'],
          'grade': currentChild['grade'],
          'raw_id': currentChild['id'],
          'id': currentChild['id'] != null ? '#${currentChild['id']}' : '#0000',
          'image': currentChild['image'],
          'isNetworkImage': currentChild['isNetworkImage'],
          'newsImage': null,
          'school': currentChild['school'],
          'schoolIcon': null,
          'newsTitle': 'Aucune actualité',
          'newsContent': 'Rien à signaler pour le moment.',
          'status': currentChild['status'] ?? currentChild['attendance_status'] ?? 'En attente',
          'statusColor': currentChild['statusColor'] ?? Colors.grey,
          'arrivalTime': currentChild['arrival_time'] ?? currentChild['arrivalTime'] ?? '--:--',
          'attendance_status': currentChild['attendance_status'],
          'arrival_time': currentChild['arrival_time'],
          'feesOwed': '0 FCFA',
          'homeworks': [],
          'notifications': [],
          'calendarDate': 'Mars 2026',
          'incidents': [],
          'fromApi': true,
          'raw': currentChild['raw'] ?? currentChild,
        };
      }
    });
  }''');
    file.writeAsStringSync(lines.join('\n'));
    print('Successfully replaced _onChildSelected');
  } else {
    print('Could not find _onChildSelected');
  }
}
