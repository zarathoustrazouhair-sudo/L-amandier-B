with open('pubspec.yaml', 'r') as f:
    content = f.read()

if 'assets:' not in content:
    content = content.replace('flutter:\n  uses-material-design: true', 'flutter:\n  uses-material-design: true\n  assets:\n    - assets/images/')
    with open('pubspec.yaml', 'w') as f:
        f.write(content)
