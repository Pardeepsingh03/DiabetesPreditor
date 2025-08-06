# Diabix – Diabetes Prediction App

**Diabix** is a mobile app that helps predict the risk of diabetes using machine learning and provides explainable results to help users understand the outcome.

The app uses a SwiftUI frontend and a FastAPI backend. Users enter their personal health data, and the app returns predictions along with visual explanations like SHAP values, anchor rules, and causal effects.

---

## 🔑 Features

- Diabetes risk prediction using ML
- SHAP and Anchor-based explanation
- Causal inference and counterfactual feedback
- iOS app built with SwiftUI
- Secure API communication

---

## 📱 Technologies Used

- SwiftUI (iOS)
- FastAPI (Python backend)
- XGBoost, SHAP, Anchors, DoWhy

---

## 🚀 Getting Started

### Backend

1. Go to the `backend/` folder
2. Run the FastAPI server:

```bash
uvicorn main:app --reload
