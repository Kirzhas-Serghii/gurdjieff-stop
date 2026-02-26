# Gurdjieff Stop — Flutter Додаток

Мобільний додаток для практики вправи Гурджієва «Стоп» (самозапам'ятовування).

## Що робить додаток

У випадкові моменти протягом дня телефон вібрує та/або відтворює звук.
Почувши сигнал — зупиніть все, відчуйте тіло, згадайте себе.

---

## Швидкий старт (збірка APK)

### 1. Встановіть Flutter
```
https://docs.flutter.dev/get-started/install
```
Перевірте: `flutter doctor`

### 2. Клонуйте / розпакуйте проект
```bash
cd gurdjieff_stop
```

### 3. Додайте звукові файли
Покладіть у папку `assets/sounds/` файли:
- `bell.mp3`
- `tibetan_bowl.mp3`
- `soft_chime.mp3`
- `gong.mp3`
- `wind_bell.mp3`

Безкоштовні звуки: https://freesound.org (пошук "bell", "tibetan bowl")

### 4. Встановіть залежності
```bash
flutter pub get
```

### 5. Зберіть APK
```bash
flutter build apk --release
```

Готовий файл: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Встановіть на телефон
```bash
flutter install
```
або просто перенесіть APK на телефон і встановіть.

---

## Важливо: Оптимізація батареї

Щоб сигнали працювали у фоні:

**Android:**
1. Налаштування → Програми → Gurdjieff Stop
2. Батарея → Необмежений режим
3. Або: Налаштування → Батарея → Оптимізація батареї → Не оптимізувати

**Xiaomi/MIUI:**
- Налаштування → Програми → Gurdjieff Stop → Автозапуск → Увімкнути
- Дозволи → Запуск у фоні → Увімкнути

---

## Структура проекту

```
lib/
  main.dart                    — Точка входу
  models/
    app_settings.dart          — Налаштування (збереження/завантаження)
    stats_service.dart         — Статистика сесій
  services/
    notification_service.dart  — Сповіщення (flutter_local_notifications)
    trigger_service.dart       — Планування (WorkManager)
  screens/
    home_screen.dart           — Головний екран
    settings_screen.dart       — Налаштування
    statistics_screen.dart     — Статистика
    stop_overlay_screen.dart   — Екран СТОП (повноекранний)

android/
  app/
    src/main/
      AndroidManifest.xml      — Дозволи та конфіг
      kotlin/com/gurdjieff/stop/
        MainActivity.kt

assets/
  sounds/                      — Звукові файли (додати вручну)
```

---

## Використані пакети

| Пакет | Призначення |
|-------|-------------|
| `workmanager` | Фонові завдання (Android WorkManager) |
| `flutter_local_notifications` | Системні сповіщення |
| `audioplayers` | Відтворення звуку |
| `vibration` | Керування вібрацією |
| `shared_preferences` | Збереження налаштувань |
| `permission_handler` | Запит дозволів |

---

## Онлайн збірка без встановлення Flutter

1. Зареєструйтесь на https://codemagic.io
2. Завантажте ZIP проекту
3. Натисніть Build → отримаєте APK на email

---

## Ліцензія

MIT — вільне використання та модифікація.
