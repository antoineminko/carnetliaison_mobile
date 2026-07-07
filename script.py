import re

file_path = r'C:\Users\Initial\Desktop\c\carnetliaison_mobile\lib\features\teacher\accueil\devoirs\create_homework_page.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _buildTypeSelector call
content = content.replace('_buildTypeSelector()', 'HomeworkTypeSelector(\n              selectedType: _selectedType,\n              onTypeChanged: (type) => setState(() => _selectedType = type),\n            )')

# Replace _buildSubjectCard call
content = content.replace('_buildSubjectCard()', 'HomeworkSubjectCard(subject: _subject)')

# Replace _buildClassSelector call
content = content.replace('_buildClassSelector()', 'HomeworkClassSelector(\n              classes: _classes,\n              selectedClass: _selectedClass,\n              onChanged: (val) {\n                setState(() {\n                  _selectedClass = val;\n                  if (val != null) {\n                    _fetchStudents(val[\'id\']);\n                  }\n                });\n              },\n            )')

# Replace _buildStudentSelector call
content = content.replace('_buildStudentSelector()', 'HomeworkStudentSelector(\n              students: _students,\n              selectedStudents: _selectedStudents,\n              selectAllStudents: _selectAllStudents,\n              onToggleSelectAll: _toggleSelectAll,\n              onToggleStudent: _toggleStudentSelection,\n            )')

# Replace _buildDetailsCard call
content = content.replace('_buildDetailsCard()', 'HomeworkDetailsForm(\n              titleController: _titleController,\n              descController: _descController,\n              durationController: _durationController,\n              selectedType: _selectedType,\n            )')

# Replace _buildDatePicker call
content = content.replace('_buildDatePicker()', 'HomeworkDatePicker(\n              dueDate: _dueDate,\n              onDateChanged: (date) => setState(() => _dueDate = date),\n            )')

# Remove the methods
content = re.sub(r'Widget _buildTypeSelector\(\) \{.*?\n  \}\n', '', content, flags=re.DOTALL)
content = re.sub(r'Widget _buildSubjectCard\(\) \{.*?\n  \}\n', '', content, flags=re.DOTALL)
content = re.sub(r'Widget _buildClassSelector\(\) \{.*?\n  \}\n', '', content, flags=re.DOTALL)
content = re.sub(r'Widget _buildStudentSelector\(\) \{.*?\n  \}\n', '', content, flags=re.DOTALL)
content = re.sub(r'Widget _buildDetailsCard\(\) \{.*?\n  \}\n', '', content, flags=re.DOTALL)
content = re.sub(r'Widget _buildDatePicker\(\) \{.*?\n  \}\n', '', content, flags=re.DOTALL)

# Add imports
imports = '''import 'widgets/homework_type_selector.dart';
import 'widgets/homework_subject_card.dart';
import 'widgets/homework_class_selector.dart';
import 'widgets/homework_student_selector.dart';
import 'widgets/homework_details_form.dart';
import 'widgets/homework_date_picker.dart';
'''
content = content.replace(\"import 'package:shared_preferences/shared_preferences.dart';\", \"import 'package:shared_preferences/shared_preferences.dart';\n\" + imports)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('File updated successfully.')
