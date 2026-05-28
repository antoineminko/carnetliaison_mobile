import re

file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix intl import
if 'package:intl/intl.dart' not in content:
    content = content.replace(
        "import 'package:app_mobile/shared/config/api_client.dart';",
        "import 'package:app_mobile/shared/config/api_client.dart';\nimport 'package:intl/intl.dart';"
    )

# Fix Présence du jour
content = re.sub(
    r"const Text\(\s*'PrÃ©sence du jour',\s*style: TextStyle\(fontSize: 18, fontWeight: FontWeight\.bold\),\s*\),",
    '''Row(
                children: [
                  const Text(
                    \\'Présence du jour\\',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat(\\'dd-MM-yyyy\\').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),''',
    content,
    flags=re.MULTILINE
)

# Fix Actualités
actualites_replacement = '''
          Builder(
            builder: (context) {
              final actualites = _dashboardData?['actualites'] as List<dynamic>? ?? [];
              if (actualites.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune actualité récente',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }
              return Column(
                children: actualites.map((actu) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (actu['type'] ?? 'ANNONCE').toString().toUpperCase(),
                              style: TextStyle(color: Colors.blue[800], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(actu['titre'] ?? 'Information', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(actu['contenu'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                          const SizedBox(height: 12),
                          Text(actu['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(actu['date'])) : '', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }'''

content = re.sub(
    r"Container\(\s*decoration: BoxDecoration\(\s*color: Colors\.white,\s*borderRadius: BorderRadius\.circular\(16\),[\s\S]*?Widget _buildPriorityNotifications",
    actualites_replacement.strip() + r"\n\n  Widget _buildPriorityNotifications",
    content
)

# Fix Notes
notes_replacement = '''
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NOTES DE LA SEMAINE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2),
                ),
                if (_dashboardData?['grades_history'] != null)
                  TextButton(
                    onPressed: () {},
                    child: const Text('Historique notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.seaBlue, decoration: TextDecoration.underline)),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            if (grades.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                child: const Center(child: Text('Aucune note', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
              )
            else
              ...grades.map((g) => _buildGradeItem(g)),'''

content = re.sub(
    r"const Text\(\s*'RELEVÃ‰ DES NOTES'[\s\S]*?\.\.\.grades\.map\(\(g\) => _buildGradeItem\(g\)\),",
    notes_replacement.strip(),
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
