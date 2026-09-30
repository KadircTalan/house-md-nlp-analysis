# House MD - Tıbbi Metin Analizi ve Doğal Dil İşleme Platformu (BLUE AI)

Bu proje, "House MD" dizisinin klinik replikleri üzerinden Türkçe tıbbi diyalogların duygu durumunu, tedavi evresini ve niyetini saptayabilen **uçtan uca bir Doğal Dil İşleme (NLP) ve Çok Görevli Öğrenme (Multi-Task Learning)** sistemidir.

Proje, baştan sona veri işleme, derin öğrenme modelinin sıfırdan eğitilmesi, modelin hafifletilerek bir bulut API servisine dönüştürülmesi ve en nihayetinde mobil uygulama üzerinden kullanıcıya sunulmasını kapsar.

## 🚀 Projenin Temel Özellikleri

- **Çok Görevli Öğrenme (Multi-Task Learning):** Tek bir Cosmos BERT (Turkish) modeli üzerinden aynı anda 4 farklı tahmin:
  - **Alaycılık (Sarcasm):** İkili sınıflandırma (Evet/Hayır)
  - **Niyet (Intent):** 6 farklı sınıf (Açıklama, Hipotez, Soru, Tanı vb.)
  - **Aşama (Stage):** 4 farklı sınıf (Değerlendirme, Test, Tedavi vb.)
  - **Duygu (Emotion):** 6 farklı karmaşık duygu durumu
- **TF-Lite Model Optimizasyonu:** Büyük Keras modeli, bellek (RAM) ve işlemci tasarrufu sağlamak için `.tflite` formatına dönüştürüldü.
- **FastAPI Tabanlı Bulut Servisi:** Model asenkron çalışan, yüksek performanslı bir REST API olarak **Render** üzerinde canlıya alındı.
- **Flutter Mobil Uygulaması:** Firebase (Google Auth & Firestore) destekli, "Blue AI" isminde modern bir mobil arayüz geliştirildi.
- **Gerçek Zamanlı Kullanım:** Kullanıcıdan gelen hasta/vaka metinleri saniyeler içinde analiz edilip mobil uygulamaya iletilir ve geçmiş sekmesinde saklanır.

## 📂 Klasör Yapısı

```text
nlp_proje_github/
├── api/                  # FastAPI web servisi, TF-Lite modeli ve deploy konfigürasyonları
├── mobile_app/           # Flutter ile geliştirilmiş mobil uygulama kodları (Firebase entegreli)
└── model_training/       # Cosmos BERT modelinin eğitildiği, ince ayar yapıldığı Jupyter Notebook
```
*(Not: Veri seti öğrenci grupları tarafından manuel oluşturulduğu için gizli tutulmuştur. Sadece kaynak kodlar ve mimari paylaşılmıştır.)*

## 🛠️ Kullanılan Teknolojiler

- **Yapay Zeka ve Veri Bilimi:** Python, TensorFlow, Keras, HuggingFace (Cosmos BERT), Scikit-Learn
- **API ve Dağıtım (Deployment):** FastAPI, Uvicorn, TensorFlow Lite, Render (Cloud)
- **Mobil Geliştirme:** Flutter, Dart
- **Veritabanı ve Kimlik Doğrulama:** Firebase Cloud Firestore, Google Authentication

## 🏃 Kurulum ve Çalıştırma

### 1. API Katmanı (FastAPI)
Eğer modeli yerelde çalıştırmak isterseniz `api/` dizinine gidin ve bağımlılıkları yükleyin:
```bash
cd api
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```
API yerelde çalışırken `http://localhost:8000/docs` üzerinden Swagger arayüzü ile metin analizi istekleri gönderebilirsiniz.

### 2. Mobil Uygulama (Flutter)
Mobil uygulamayı çalıştırmak için cihazınızda Flutter SDK kurulu olmalıdır:
```bash
cd mobile_app
flutter pub get
flutter run
```
*Not: Proje içerisindeki Firebase ayarlarını çalıştırmak için ilgili Firebase ortam değişkenlerinin yapılandırılmış olması gerekebilir.*

---
*Bu proje, İstanbul Sabahattin Zaim Üniversitesi Bilgisayar Mühendisliği Bölümü Doğal Dil İşleme dersi kapsamında tasarlanmış ve geliştirilmiştir.*
