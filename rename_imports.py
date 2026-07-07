import os
import glob

replacements = {
    'features/auth/welcome/pages/welcome_page.dart': 'features/auth/welcome/page.dart',
    'features/auth/parent/pages/login_page.dart': 'features/auth/parent/login_page.dart',
    'features/teacher/pages/teacher_home.dart': 'features/teacher/accueil/accueil_page.dart',
    'features/teacher/pages/teacher_messages_page.dart': 'features/teacher/messages/teacher_messages_page.dart',
    'features/teacher/pages/create_appointment_page.dart': 'features/teacher/agenda/create_appointment_page.dart',
    'features/teacher/pages/teacher_profile_page.dart': 'features/teacher/profil/teacher_profile_page.dart',
    'features/teacher/pages/class_dashboard.dart': 'features/teacher/espace_classe/espace_classe.dart',
    'features/teacher/pages/grades_entry_view.dart': 'features/teacher/espace_classe/grades_entry_view.dart',
    'features/teacher/pages/attendance_view.dart': 'features/teacher/espace_classe/attendance_view.dart',
    'features/teacher/pages/attendance.dart': 'features/teacher/espace_classe/attendance.dart',
    'features/teacher/pages/teacher_student_list_page.dart': 'features/teacher/espace_classe/teacher_student_list_page.dart',
    'features/teacher/components/student_list.dart': 'features/teacher/espace_classe/student_list.dart',
    'features/teacher/pages/teacher_classes_page.dart': 'features/teacher/espace_classe/teacher_classes_page.dart',
    'features/teacher/components/class_selector.dart': 'features/teacher/espace_classe/class_selector.dart',
    'features/teacher/pages/parent_info_page.dart': 'features/teacher/espace_classe/parent_info_page.dart',
    'features/teacher/pages/textbook_view.dart': 'features/teacher/espace_classe/textbook_view.dart',
    'features/teacher/pages/create_homework_page.dart': 'features/teacher/accueil/devoirs/create_homework_page.dart',
    'features/teacher/pages/homework_manager.dart': 'features/teacher/accueil/devoirs/homework_manager.dart',
    'features/teacher/teacher_slice.dart': 'features/teacher/utils/teacher_slice.dart',
    # Also fix ClassDashboardPage rename
    'ClassDashboardPage': 'EspaceClassePage'
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements.items():
        new_content = new_content.replace(old, new)
        
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done.")
