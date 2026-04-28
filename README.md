# Floor Plan AI

Приложение для автоматического распознавания комнат на планировках с помощью Gemini AI.

## Возможности

- Загрузка планировки (PNG/JPG)
- Распознавание комнат через Gemini 2.0 Flash
- Отрисовка полигонов поверх изображения
- Сглаживание контуров (Douglas-Peucker)
- Выбор и подсветка отдельных комнат

## Структура проекта

```
lib/
├── main.dart                        # Точка входа + экран ввода API ключа
├── screens/
│   └── home_screen.dart             # Главный экран
├── services/
│   └── gemini_service.dart          # Запросы к Gemini API
├── widgets/
│   └── floor_plan_painter.dart      # CustomPainter для полигонов
├── models/
│   └── room.dart                    # Модель комнаты
└── utils/
    └── douglas_peucker.dart         # Алгоритм сглаживания
```

## Настройка

1. Получи бесплатный API ключ на [aistudio.google.com](https://aistudio.google.com)
2. При первом запуске приложение спросит ключ

## Сборка APK

### Локально
```bash
flutter pub get
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### Через Codemagic
1. Загрузи проект на GitHub
2. Подключи репозиторий на [codemagic.io](https://codemagic.io)
3. Выбери Flutter workflow → Start Build
4. Скачай APK из Artifacts

## Зависимости

- `http` — HTTP запросы к Gemini API
- `image_picker` — выбор фото из галереи
- `permission_handler` — права на чтение файлов
