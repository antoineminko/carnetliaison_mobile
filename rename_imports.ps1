$replacements = @{
    'features/auth/welcome/pages/welcome_page.dart' = 'features/auth/welcome/page.dart'
    'features/auth/parent/pages/login_page.dart' = 'features/auth/parent/login_page.dart'
    'features/teacher/pages/teacher_home.dart' = 'features/teacher/accueil/accueil_page.dart'
    'features/teacher/pages/teacher_messages_page.dart' = 'features/teacher/messages/teacher_messages_page.dart'
    'features/teacher/pages/create_appointment_page.dart' = 'features/teacher/agenda/create_appointment_page.dart'
    'features/teacher/pages/teacher_profile_page.dart' = 'features/teacher/profil/teacher_profile_page.dart'
    'features/teacher/pages/class_dashboard.dart' = 'features/teacher/espace_classe/espace_classe.dart'
    'features/teacher/pages/grades_entry_view.dart' = 'features/teacher/espace_classe/grades_entry_view.dart'
    'features/teacher/pages/attendance_view.dart' = 'features/teacher/espace_classe/attendance_view.dart'
    'features/teacher/pages/attendance.dart' = 'features/teacher/espace_classe/attendance.dart'
    'features/teacher/pages/teacher_student_list_page.dart' = 'features/teacher/espace_classe/teacher_student_list_page.dart'
    'features/teacher/components/student_list.dart' = 'features/teacher/espace_classe/student_list.dart'
    'features/teacher/pages/teacher_classes_page.dart' = 'features/teacher/espace_classe/teacher_classes_page.dart'
    'features/teacher/components/class_selector.dart' = 'features/teacher/espace_classe/class_selector.dart'
    'features/teacher/pages/parent_info_page.dart' = 'features/teacher/espace_classe/parent_info_page.dart'
    'features/teacher/pages/textbook_view.dart' = 'features/teacher/espace_classe/textbook_view.dart'
    'features/teacher/pages/create_homework_page.dart' = 'features/teacher/accueil/devoirs/create_homework_page.dart'
    'features/teacher/pages/homework_manager.dart' = 'features/teacher/accueil/devoirs/homework_manager.dart'
    'features/teacher/teacher_slice.dart' = 'features/teacher/utils/teacher_slice.dart'
    'ClassDashboardPage' = 'EspaceClassePage'
}

Get-ChildItem -Path lib -Filter *.dart -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $original = $content
    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }
    if ($content -cne $original) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Updated $($_.FullName)"
    }
}
