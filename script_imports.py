import re

file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

imports = '''import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:intl/intl.dart';
'''

content = re.sub(
    r"^import.*?;[\s]*",
    "",
    content,
    flags=re.MULTILINE
)

content = imports + "\n" + content.lstrip()

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
