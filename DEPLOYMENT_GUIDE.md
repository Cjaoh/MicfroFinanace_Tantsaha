# 📦 DEPLOYMENT GUIDE - MicroFinance Tantsaha

Guide complet pour déployer l'application sur les app stores (Google Play, App Store, Web).

---

## 🔧 Pré-Deployment Setup

### 1. Vérifier pubspec.yaml

```yaml
# pubspec.yaml
name: microfinance_tantsaha
description: Application de microfinance rurale
version: 1.0.0+1  # version + build number

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  riverpod: ^2.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^4.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/fonts/
    
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/custom.ttf
```

### 2. Mettre à jour metadata

```dart
// lib/main.dart
const String appVersion = '1.0.0';
const String appBuildNumber = '1';

void main() {
  // ...
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroFinance Tantsaha',
      // ...
    );
  }
}
```

---

## 🤖 Android Deployment

### Step 1: Configurer app signing

```bash
# Générer une keystore (à faire UNE FOIS)
keytool -genkey -v -keystore ~/microfinance-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias microfinance-key

# Créer le fichier de config Android
mkdir -p android/key.properties
```

### Step 2: Configurer android/key.properties

```properties
storePassword=<YOUR_KEYSTORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=microfinance-key
storeFile=/home/yourname/microfinance-key.jks
```

### Step 3: Mettre à jour android/app/build.gradle.kts

```kotlin
// Pour Android 12+, ajouter:
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias = "microfinance-key"
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
            storeFile = file("/path/to/microfinance-key.jks")
            storePassword = System.getenv("STORE_PASSWORD") ?: ""
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.release
            minifyEnabled false
        }
    }
}
```

### Step 4: Build APK/AAB

```bash
# Build APK (tester en local)
flutter build apk --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release

# Le fichier est dans: build/app/outputs/bundle/release/app-release.aab
# Ou: build/app/outputs/flutter-apk/app-release.apk
```

### Step 5: Upload sur Google Play

1. Aller à [Google Play Console](https://play.google.com/console)
2. Créer une nouvelle app
3. Remplir les infos:
   - Nom de l'app: "MicroFinance Tantsaha"
   - Description courte et longue
   - Catégorie: Finance
   - Type de contenu
4. Upload l'AAB
5. Ajouter screenshots, icône, vidéo
6. Remplir questionnaires (respect des données, etc.)
7. Soumettre pour review

---

## 🍎 iOS Deployment

### Step 1: Setup iOS Signing

```bash
# Ouvrir Xcode project
open ios/Runner.xcworkspace

# Configurer signing:
# - Sélectionner Runner project
# - Build Settings → Code Signing Identity
# - Sélectionner votre team Apple
```

### Step 2: Mettre à jour App Version

```bash
# Éditer ios/Runner/Info.plist
# Ou via Xcode:
# Build Settings → iOS Deployment Target: 12.0 ou plus
```

### Step 3: Build iOS App

```bash
# Build pour TestFlight/App Store
flutter build ios --release

# Ouvrir Xcode pour finalize
open ios/Runner.xcworkspace

# Archive et upload (depuis Xcode)
# Product → Archive
# Distribute App
```

### Step 4: Publier sur App Store

1. Aller à [App Store Connect](https://appstoreconnect.apple.com/)
2. Créer une nouvelle app
3. Remplir les infos (même que Android)
4. Uploader via TestFlight ou directement
5. Remplir content rating questionnaire
6. Soumettre pour review

---

## 🌐 Web Deployment

### Step 1: Build Web

```bash
flutter build web --release

# Fichiers dans: build/web/
```

### Step 2: Déployer sur Firebase Hosting

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialiser
firebase init hosting

# Déployer
firebase deploy --only hosting
```

### Ou sur Netlify

```bash
# Installer Netlify CLI
npm install -g netlify-cli

# Déployer
netlify deploy --prod --dir=build/web
```

---

## 🧪 Pre-Release Testing

### Test sur Device

```bash
# Android
flutter run --release

# iOS
flutter run --release

# Web
flutter run -d chrome --release
```

### Test Checklist

- [ ] Toutes les transactions s'affichent correctement
- [ ] Balance calculation est exact
- [ ] Prêts approve/reject functionne
- [ ] Épargnes deposit/withdraw valide
- [ ] Suppression avec confirmation marche
- [ ] Date formatting correct
- [ ] Format devise (Ar) affiche bien
- [ ] UI responsive sur différentes tailles
- [ ] Performance acceptable (pas de lag)
- [ ] Pas d'erreurs non-handled
- [ ] Données de démo populate au premier lancement
- [ ] Clear data et recommencer marche
- [ ] Logs Hive pas problématiques

---

## 📝 Release Notes

Template pour chaque version:

```markdown
# Version 1.0.0 - Initial Release

## Features
- ✅ Dashboard avec résumé financier
- ✅ Gestion complète des transactions
- ✅ Système d'épargne avec dépôt/retrait
- ✅ Gestion des prêts avec plan remboursement
- ✅ Jauge de score de crédit
- ✅ Stockage local Hive
- ✅ Interface Material 3

## Bug Fixes
- N/A (première release)

## Known Issues
- N/A

## Installation
- Android: Google Play Store
- iOS: App Store
- Web: www.microfinance-tantsaha.com

## Support
Pour des problèmes, contactez: support@microfinance-tantsaha.mg
```

---

## 🔐 Security Checklist

- [ ] Pas de credentials stockés en dur
- [ ] API keys/secrets dans environment variables
- [ ] Hive encryption activé (optionnel)
- [ ] Input validation robuste
- [ ] No sensitive logs in production
- [ ] HTTPS enforced si API
- [ ] Permissions properly requested (Android)
- [ ] Privacy policy rédigée et linkée

---

## 🚀 Versioning Strategy

```
Semantic Versioning: MAJOR.MINOR.PATCH+BUILD

1.0.0+1   = Initial release
1.0.1+2   = Bugfix release
1.1.0+3   = New features release
2.0.0+4   = Breaking changes release

Mise à jour pubspec.yaml:
version: 1.0.0+1
           └─ Version app
              └─ Build number
```

---

## 📊 Post-Launch Monitoring

### Setup Crashlytics (Firebase)

```bash
# Ajouter firebase_crashlytics
flutter pub add firebase_crashlytics

# Initialiser dans main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Enable crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const MyApp());
}
```

### Monitor Metrics

- Crash rate
- ANR (Application Not Responding) rate
- DAU (Daily Active Users)
- Retention rate
- Errors by version

---

## 🔄 Update Strategy

### Für Mini-Updates
```bash
# Patch version: bug fixes
flutter build apk --release  # Android APK
# Manual update required

# Atau
flutter build appbundle --release  # Android AAB
# Play Store handles gradual rollout
```

### Für Major Updates
1. Backup user data
2. Test migration paths
3. Gradual rollout (25% → 50% → 100%)
4. Monitor crash rate sebelum 100%
5. Have rollback plan

---

## 📲 Store Optimization

### Google Play Optimization

- **Title**: "MicroFinance Tantsaha" (30 chars max)
- **Short Description**: "Manage savings and loans" (80 chars)
- **Full Description**: Detailed, include features
- **Icon**: 512x512 PNG (no transparency)
- **Screenshots**: 5-8 images (1080x1920 atau 2160x3840)
- **Video**: 30-second intro (optionnel)
- **Category**: Finance
- **Content Rating**: Fill out questionnaire
- **Pricing**: Free atau Paid

### App Store Optimization

- **Name**: "MicroFinance Tantsaha" (30 chars)
- **Subtitle**: "Financial Management" (30 chars)
- **Keywords**: microfinance, savings, loans (100 chars)
- **Description**: Detailed overview
- **Preview/Screenshots**: 2-5 per language
- **Icon**: 1024x1024 PNG
- **Category**: Finance
- **Age Rating**: 4+

---

## 🎯 Launch Checklist

### Before Launch
- [ ] Version incremented (pubspec.yaml + iOS)
- [ ] Build tested on real device
- [ ] Localization complete (French)
- [ ] Privacy policy written
- [ ] Terms of service written
- [ ] Support contact available
- [ ] Release notes prepared
- [ ] Screenshots/videos ready
- [ ] App icon finalized
- [ ] Description text reviewed

### After Launch (Day 1)
- [ ] Monitor crash reports
- [ ] Check user feedback
- [ ] Verify analytics working
- [ ] Test update mechanism

### Week 1
- [ ] 1000+ installs? (Target)
- [ ] Crash rate < 1%?
- [ ] Average rating > 3.5?
- [ ] No critical bugs reported?

### Month 1
- [ ] User retention > 30%?
- [ ] DAU trending up?
- [ ] Review ratings stable?
- [ ] Plan for next update?

---

## 🔧 Common Issues & Solutions

### Issue: Play Store Rejection

**Common Reasons:**
- Privacy policy missing
- Crashes on specific device
- Incompatible with Android 12+
- Fake ratings/reviews

**Solutions:**
- Add privacy policy link
- Test on various API levels
- Fix permissions (manifests)
- Get genuine user reviews

### Issue: iOS App Review Rejection

**Common Reasons:**
- Incomplete functionality
- Crashes on demo iPhone
- Violates App Store guidelines
- Unclear app purpose

**Solutions:**
- Ensure all features work
- Test thoroughly
- Review guidelines
- Clear description

### Issue: Web Performance

**Problem:** Slow load time

**Solutions:**
```bash
# Optimize build
flutter build web --release --no-tree-shake-icons

# Minimize JS
# Enable gzip compression on server
# Use CDN for assets
```

---

## 📚 Resources

- [Flutter Deployment Docs](https://flutter.dev/docs/deployment)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/support/appstoreconnect)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)

---

**Status**: Ready for Production Deployment 🚀
**Last Updated**: Complete deployment guide
