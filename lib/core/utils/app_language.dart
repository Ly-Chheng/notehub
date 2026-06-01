import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  final locale = const Locale('km', 'KM');
  final fallbackLocale = const Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // General
          'locale': 'en',
          'home': 'HomeScreen',
          'search': 'Search',
          'my_note': 'My Notes',
          'folders': 'Folders',

          // More Screen
          'about': 'About',
          'dark_mode': 'Dark Mode',
          'how_to_use': 'How to Use',
          'change_language': 'Change Language',
          'share_app': 'Share App',
          'recently_deleted': 'Recently Deleted',

          // Security
          'change_password': 'Change Password',
          'reset_password': 'Reset Password',
          'forget_password': 'Forget Password',

          // Footer
          'copyright': 'Copyright © 2026 Student Note App.\nVersion 1.0.0 (6)',

          // Editor
          'title': 'Title',
          'start_typing': 'Start typing...',
          'add_media': 'Add Media',
          'cancel': 'Cancel',
          'backgrounds': 'Backgrounds',
          'format': 'Format',
          'text_alignment': 'Text Alignment',
          'text_style': 'Text Style',
          'font_size': 'Font Size',
          'save': 'Save',
          'pin': 'Pin',
          'share': 'Share',
          'move_note': 'Move Note',
          'lock_note': 'Lock Note',
          'delete': 'Delete',

          // Auth / Password
          'create': 'Create',
          'create_new_password': 'Create New Password',
          'create_password_desc': 'Create a secure password to protect your personal notes.',
          'new_password': 'New Password',
          'confirm_password': 'Confirm Password',
          'hint': 'Hint',
          'optional': 'Optional',
          'security_question_verification': 'Security Question Verification',
          'select_security_question': 'Select Security Question',
          'security_answer': 'Security Answer',
          'change_password_desc': 'Update the password to protect your notes.',
          'current_password': 'Current Password',
          'confirm_new_password': 'Confirm New Password',
          'new_hint': 'New Hint',
          'select_question': 'Select Question',
          'enter_your_answer': 'Enter your answer',
          'remove_lock_desc': 'Please enter your current password to remove all protection.',
          'submit': 'Submit',
          'forget_password_desc': 'Verify your identity using your security question to reset your password.',
          'no_security_question': 'No security question set up.',
          'loading': 'Loading...',

          // Folder
          'create_folder': 'Create Folder',
          'update_folder': 'Update Folder',
          'folder_name': 'Folder Name',
          'duplicate_name': 'Duplicate Name',
          'folder_exists': 'A folder with this name already exists.',
          'ok': 'OK',
        },
        'km_KM': {
          // General
          'locale': 'km',
          'home': 'ទំព័រដើម',
          'search': 'ស្វែងរក',
          'my_note': 'កំណត់ចំណាំរបស់ខ្ញុំ',
          'folders': 'ថតឯកសារ',

          // More Screen
          'about': 'អំពីកម្មវិធី',
          'dark_mode': 'របៀបងងឹត',
          'how_to_use': 'របៀបប្រើប្រាស់',
          'change_language': 'ប្ដូរភាសា',
          'share_app': 'ចែករំលែកកម្មវិធី',
          'recently_deleted': 'បានលុបថ្មីៗ',

          // Security
          'change_password': 'ប្ដូរពាក្យសម្ងាត់',
          'reset_password': 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
          'forget_password': 'ភ្លេចពាក្យសម្ងាត់',

          // Footer
          'copyright': 'រក្សាសិទ្ធិ © 2026 កម្មវិធី Student Note\nកំណែ 1.0.0 (6)',

          // Editor
          'title': 'ចំណងជើង',
          'start_typing': 'ចាប់ផ្តើមវាយអត្ថបទ...',
          'add_media': 'បន្ថែមមេឌៀ',
          'cancel': 'បោះបង់',
          'backgrounds': 'ផ្ទៃខាងក្រោយ',
          'format': 'ទម្រង់',
          'text_alignment': 'តម្រឹមអត្ថបទ',
          'text_style': 'រចនាប័ទ្មអត្ថបទ',
          'font_size': 'ទំហំអក្សរ',
          'save': 'រក្សាទុក',
          'pin': 'បិទភ្ជាប់',
          'share': 'ចែករំលែក',
          'move_note': 'ផ្លាស់ទីកំណត់ចំណាំ',
          'lock_note': 'ចាក់សោកំណត់ចំណាំ',
          'delete': 'លុប',

          // Auth / Password
          'create': 'បង្កើត',
          'create_new_password': 'បង្កើតពាក្យសម្ងាត់ថ្មី',
          'create_password_desc': 'បង្កើតពាក្យសម្ងាត់ដែលមានសុវត្ថិភាព ដើម្បីការពារកំណត់ចំណាំផ្ទាល់ខ្លួនរបស់អ្នក។',
          'new_password': 'ពាក្យសម្ងាត់ថ្មី',
          'confirm_password': 'បញ្ជាក់ពាក្យសម្ងាត់',
          'hint': 'ចំណាំជំនួយ',
          'optional': 'ជម្រើស',
          'security_question_verification': 'សំណួរសុវត្ថិភាពសម្រាប់ផ្ទៀងផ្ទាត់',
          'select_security_question': 'ជ្រើសរើសសំណួរសុវត្ថិភាព',
          'security_answer': 'ចម្លើយសុវត្ថិភាព',
          'change_password_desc': 'ធ្វើបច្ចុប្បន្នភាពពាក្យសម្ងាត់ ដើម្បីការពារកំណត់ចំណាំរបស់អ្នក។',
          'current_password': 'ពាក្យសម្ងាត់បច្ចុប្បន្ន',
          'confirm_new_password': 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
          'new_hint': 'ចំណាំជំនួយថ្មី',
          'select_question': 'ជ្រើសរើសសំណួរ',
          'enter_your_answer': 'បញ្ចូលចម្លើយរបស់អ្នក',
          'remove_lock_desc': 'សូមបញ្ចូលពាក្យសម្ងាត់បច្ចុប្បន្នរបស់អ្នក ដើម្បីដកការការពារទាំងអស់។',
          'submit': 'បញ្ជូន',
          'forget_password_desc': 'ផ្ទៀងផ្ទាត់អត្តសញ្ញាណរបស់អ្នកដោយប្រើសំណួរសុវត្ថិភាព ដើម្បីកំណត់ពាក្យសម្ងាត់ឡើងវិញ។',
          'no_security_question': 'មិនទាន់បានកំណត់សំណួរសុវត្ថិភាពទេ',
          'loading': 'កំពុងផ្ទុក...',

          // Folder
          'create_folder': 'បង្កើតថតឯកសារ',
          'update_folder': 'កែប្រែថតឯកសារ',
          'folder_name': 'ឈ្មោះថតឯកសារ',
          'duplicate_name': 'ឈ្មោះស្ទួន',
          'folder_exists': 'មានថតឯកសារដែលមានឈ្មោះនេះរួចហើយ។',
          'ok': 'យល់ព្រម',
        },
      };
}
