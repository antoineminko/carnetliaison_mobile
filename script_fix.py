import re
file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("Text('Montant :  FCFA'", "Text('Montant :  FCFA'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
