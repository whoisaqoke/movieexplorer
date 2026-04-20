8690388934:AAEZYipvuGeGZ5A97V26ULJ64Jx0tvDu3m0
# movieexplorer

Movie Explorer - это современное мобильное приложение на Flutter для поиска фильмов и управления личной библиотекой. Интерфейс вдохновлен дизайном Netflix и оптимизирован для AMOLED-экранов.

> **Описание репозитория:** Стильное приложение для киноманов на базе Flutter и OMDB API. Поддерживает поиск на английском языке, работу с локальной базой данных SQLite для избранного и прямую интеграцию с Кинопоиском.

---

## ✨ Основные функции

* **🌐 Двуязычный поиск:** Поиск фильмов на русском и английском языках через API OMDB.
* **📂 Избранное (SQLite):** Сохранение фильмов в локальную базу данных. Доступно офлайн.
* **🍿 Интеграция с Кинопоиском:** Быстрый переход к просмотру фильма через внешнюю ссылку.
* **🌙 Netflix Style UI:** Темная тема, плавные Hero-анимации и удобная навигация.

---

## 🛠 Технологический стек

* **Framework:** Flutter (Dart)
* **API:** Open Movie Database (OMDB)
* **Database:** sqflite (SQLite)
* **Features:** url_launcher, flutter_native_splash, flutter_launcher_icons

---

## 📂 Структура проекта

```text
lib/
├── models/          # Модели данных (Movie)
├── screens/         # Экраны (Home, Search, Details, Settings)
├── services/        # Логика (API Service, DB Helper)
└── main.dart        # Точка входа
