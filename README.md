# GymProgress Planner

**GymProgress Planner** to kompleksowa aplikacja mobilna stworzona we Flutterze do planowania i monitorowania progresu treningowego na siłowni. Aplikacja wspiera personalizację planów treningowych, śledzenie postępów oraz przechowywanie danych lokalnie i w chmurze.

---

## 📱 Funkcjonalności

### 🔐 Autoryzacja
- Rejestracja i logowanie za pomocą:
  - E-mail i hasło
  - Google
  - (Przygotowane miejsce na Apple Sign-In)
- Zapisywanie zalogowanego użytkownika lokalnie w Hive, aby nie wymagać ponownego logowania przy każdym uruchomieniu aplikacji.

### 🧠 Personalizacja planu treningowego
- Możliwość wyboru liczby treningów w tygodniu: **3 / 5 / 7 dni**
- Wybór konkretnych dni tygodnia, w które odbywają się treningi
- Każdy użytkownik otrzymuje indywidualny plan na podstawie wybranych dni

### 🏋️‍♂️ Plan treningowy
- Ćwiczenia są losowo dobierane z bazy Firebase Firestore
- Ćwiczenia podzielone na grupy mięśniowe: `Chest`, `Backs`, `Biceps`, `Triceps`, `Legs`, `Shoulders`, `ABS`, `Cardio`
- Plan regeneruje się tylko raz – zapisuje się w pamięci
- Możliwość rejestrowania serii (ilość powtórzeń i obciążenie)

### 📊 Dashboard z wykresami
- Wybór konkretnego ćwiczenia z listy
- Wykres progresu (ciężar vs czas)
- Wykres kołowy ze średnią liczbą powtórzeń dla danego ćwiczenia

### 🧭 Nawigacja
- Dolne menu nawigacyjne z 3 sekcjami:
  - Dashboard (wykresy)
  - Plan (kalendarz treningowy)
  - Ustawienia (konfiguracja)

### ☁️ Firebase + Hive
- Firebase Firestore: baza ćwiczeń, dane użytkownika
- Firebase Auth: logowanie i rejestracja
- Hive: lokalna pamięć na ustawienia, postęp i sesję

### 📦 Dodatkowe funkcje
- Dodawanie własnych ćwiczeń do bazy przez użytkownika
- Styl w ciemnym motywie z jasnymi kremowymi akcentami
- Spójne UI z AppBar i dolną nawigacją na każdej stronie

---

## 🚀 Jak uruchomić projekt

1. **Sklonuj repozytorium:**
```bash
git clone https://github.com/your-username/gym_progress_planner.git
cd gym_progress_planner
```

2. **Zainstaluj zależności:**
```bash
flutter pub get
```

3. **Skonfiguruj Firebase:**
- Wygeneruj `firebase_options.dart` przez `flutterfire configure`
- Upewnij się, że masz w `pubspec.yaml` dodane:
```yaml
assets:
  - assets/img/
  - assets/
```

4. **Uruchom aplikację:**
```bash
flutter run
```

---

## 🔧 Technologie
- Flutter 3+
- Firebase Auth & Firestore
- Hive (lokalna baza danych)
- fl_chart
- Google Fonts

---

## 📌 Przyszłe funkcjonalności
- Integracja z aplikacjami typu Fitatu
- Dodanie wersji premium z licznikiem kalorii
- Historia postępów i porównania tygodniowe

---

## 🧑‍💻 Autor
Projekt stworzony przez Arkadiusza Migas

