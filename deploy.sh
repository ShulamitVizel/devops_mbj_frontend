#!/bin/bash


handle_error() {
  echo "❌ שגיאה: $1"
  exit 1
}

echo "🔍 בודק שינויים בקוד..."
if ! git diff-index --quiet HEAD; then
  echo "📂 נמצאו שינויים. מבצע Commit..."
  git add . || handle_error "נכשל בהוספת שינויים."
  git commit -m "🚀 Automated commit" || handle_error "נכשל ביצירת Commit."
  git push origin main || handle_error "נכשל בדחיפת שינויים ל-GitHub."
else
  echo "✅ אין שינויים לדחוף ל-GitHub."
fi


echo "⚙️ מתקין תלותים ובונה את האפליקציה..."
npm install || handle_error "נכשל בהתקנת תלותים."
npm run build || handle_error "נכשל בבניית האפליקציה."

BUCKET_NAME="your-gcs-bucket-name"
BUILD_DIR="build"

echo "☁️ מעלה את קבצי ה-Build ל-GCS..."
gcloud storage cp -r $BUILD_DIR/* gs://$BUCKET_NAME || handle_error "נכשל בהעלאת הקבצים ל-GCS."


echo "✅ הפריסה הושלמה בהצלחה!"
