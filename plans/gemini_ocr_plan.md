# OCR Receipt Recognition Plan (Gemini Alternative)

The goal is to fix the receipt scanning feature in `OcrService` so that when a user scans a receipt, it accurately extracts the **merchant name**, **total amount**, and **date**, and populates them into the transaction form in `AddTransactionScreen`.

This plan proposes using **Google ML Kit** for local text extraction, and **Gemini 1.5 Flash** for intelligent, semantic parsing of the raw text.

---

## Alternative Analysis

We compared three options for implementing this feature:

### Option A: Google ML Kit (OCR) + Gemini 1.5 Flash (Parsing) — [RECOMMENDED]
* **How it works**: Use `google_mlkit_text_recognition` to extract all raw text lines from the receipt image locally. Then, send the text to Gemini 1.5 Flash using the existing `google_generative_ai` package to extract structured fields (merchant name, amount, date) as JSON.
* **Pros**:
  * **Extremely High Accuracy**: Gemini handles noisy OCR text, typos, complex/irregular layouts, and formats (e.g. subtotal vs grand total, multi-format dates, merchant names hidden in logo/header text).
  * **Free**: Gemini 1.5 Flash has a free tier allowing up to 15 RPM (Requests Per Minute), which is more than enough for a personal budget tracker app.
  * **No Extra Dependencies**: The project already relies on `google_mlkit_text_recognition` and `google_generative_ai` (configured with an API key).
  * **Zero Maintenance**: No need to maintain manual regex patterns or layout templates.
* **Cons**:
  * Requires an internet connection for the Gemini parsing step.

### Option B: Google ML Kit (OCR) + RegExp / Heuristic Parser
* **How it works**: Extract raw text with ML Kit and parse it using custom Regular Expressions to find amounts (e.g., look for currency symbols or lines with "TOTAL") and dates.
* **Pros**:
  * Works entirely offline.
  * Free.
* **Cons**:
  * **Extremely Fragile**: Very difficult to reliably extract merchant names since they have no fixed structure.
  * **False Positives**: Easily gets confused by other numbers on the receipt (taxes, subtotal, change, phone numbers, date digits, card numbers).

### Option C: Fix/Tune `receipt_recognition` Package
* **How it works**: Debug and continue using the `receipt_recognition` package.
* **Pros**:
  * Works entirely offline.
* **Cons**:
  * **Highly Inaccurate**: Package utilizes hardcoded rule-based layout heuristics optimized for specific supermarket templates.
  * **Fails on Generic Receipts**: Fails completely on most restaurant, cafe, parking, or custom receipts.

---

## Proposed Changes

### OCR & Parsing Service

#### [MODIFY] [ocr_service.dart](file:///d:/NEW/2026%20app/budget_tracker/lib/services/ocr_service.dart)
- Replace imports and usage of the `receipt_recognition` package.
- Introduce `TextRecognizer` from `google_mlkit_text_recognition`.
- Introduce `GenerativeModel` from `google_generative_ai` using the existing key.
- Update `pickImageAndExtractData()` to:
  1. Pick the image using `ImagePicker`.
  2. Perform local OCR using `TextRecognizer.processImage()`.
  3. Send the raw recognized text to Gemini 1.5 Flash with a structured JSON prompt.
  4. Parse the returned JSON into `ReceiptData` (merchantName, amount, date) and return it.
- Correctly close and dispose of the `TextRecognizer`.

#### [MODIFY] [pubspec.yaml](file:///d:/NEW/2026%20app/budget_tracker/pubspec.yaml)
- Remove `receipt_recognition` dependency to clean up the codebase.

---

## Verification Plan

### Automated Tests
* We will write a unit/integration test in a new file `test/services/ocr_service_test.dart` using a mock text recognizer and mock generative model to verify:
  * Image picking logic behaves correctly.
  * Extracted OCR text is successfully mapped to prompt inputs.
  * Gemini JSON outputs are parsed correctly into `ReceiptData`.

### Manual Verification
* Run the Flutter app and trigger the **Scan Receipt** camera action in the Add Transaction screen.
* Capture a receipt and verify:
  1. The **Amount** field is filled with the correct total.
  2. The **Title** field is filled with the merchant's name.
  3. The **Date** field is updated to the date listed on the receipt.
  4. The category prediction automatically triggers using the extracted merchant name.
