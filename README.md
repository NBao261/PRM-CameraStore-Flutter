# 📸 Camera Store - Ứng dụng Mua sắm Máy ảnh

Ứng dụng mobile thương mại điện tử chuyên bán máy ảnh và phụ kiện, được xây dựng với **Flutter** (Frontend) và **Node.js Express** (Backend).

## 📋 Mục lục

- [Tổng quan](#-tổng-quan)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt và Chạy](#-cài-đặt-và-chạy)
  - [1. Backend](#1-backend-nodejs--express--mongodb)
  - [2. Flutter App](#2-flutter-app)
- [Cấu hình môi trường](#-cấu-hình-môi-trường)
- [Các lệnh thường dùng](#-các-lệnh-thường-dùng)
- [Tài khoản test](#-tài-khoản-test)
- [Xử lý sự cố](#-xử-lý-sự-cố)

---

## 🎯 Tổng quan

| Tính năng | Mô tả |
|-----------|-------|
| 🔐 Xác thực | Đăng ký, Đăng nhập, JWT token |
| 🛍️ Sản phẩm | Danh sách, Tìm kiếm, Lọc theo danh mục, Chi tiết sản phẩm |
| 🛒 Giỏ hàng | Thêm/Xóa/Cập nhật số lượng, Validate tồn kho |
| 📦 Đặt hàng | Quy trình đặt hàng, Lịch sử đơn hàng |
| 👤 Hồ sơ | Quản lý thông tin cá nhân |
| 💬 Chat | Nhắn tin real-time (Socket.IO) |
| 🔔 Thông báo | Push notification |

---

## 🛠 Công nghệ sử dụng

### Frontend (Flutter)
| Thư viện | Phiên bản | Mục đích |
|----------|-----------|----------|
| `flutter_bloc` | ^8.1.6 | State Management (BLoC pattern) |
| `dio` | ^5.4.3 | HTTP Client |
| `equatable` | ^2.0.5 | Value equality cho states/events |
| `go_router` | ^14.2.0 | Routing & Navigation |
| `flutter_secure_storage` | ^9.2.2 | Lưu JWT token an toàn |
| `google_fonts` | ^6.2.1 | Typography (Inter, Roboto) |

### Backend (Node.js)
| Thư viện | Phiên bản | Mục đích |
|----------|-----------|----------|
| `express` | ^4.21.0 | Web Framework |
| `mongoose` | ^8.7.0 | MongoDB ODM |
| `jsonwebtoken` | ^9.0.2 | JWT Authentication |
| `bcryptjs` | ^2.4.3 | Mã hóa mật khẩu |
| `express-validator` | ^7.2.0 | Validate request |
| `socket.io` | ^4.8.0 | Real-time communication |
| `helmet` | ^8.0.0 | Security headers |
| `multer` | ^1.4.5 | Upload file |

---

## 📂 Cấu trúc dự án

```
PRM/
├── camera-store-app/          # Flutter Mobile App
│   ├── lib/
│   │   ├── core/              # Shared utilities
│   │   │   ├── config/        # App configuration (API URL, ...)
│   │   │   ├── constants/     # Colors, Strings, ...
│   │   │   ├── network/       # API Client (Dio)
│   │   │   └── widgets/       # Shared widgets
│   │   ├── features/          # Feature modules (Clean Architecture)
│   │   │   ├── auth/          # Đăng ký, Đăng nhập
│   │   │   ├── product/       # Danh sách, Chi tiết sản phẩm
│   │   │   ├── cart/          # Giỏ hàng
│   │   │   ├── order/         # Đặt hàng
│   │   │   ├── profile/       # Hồ sơ người dùng
│   │   │   ├── chat/          # Nhắn tin
│   │   │   ├── notification/  # Thông báo
│   │   │   └── store/         # Thông tin cửa hàng
│   │   └── main.dart          # Entry point
│   ├── android/               # Android platform config
│   └── pubspec.yaml           # Flutter dependencies
│
├── camera-store-backend/      # Node.js REST API
│   ├── src/
│   │   ├── config/            # Biến môi trường
│   │   ├── controllers/       # Request handlers
│   │   ├── middlewares/       # Auth, error handling
│   │   ├── models/            # Mongoose schemas
│   │   ├── routes/            # API endpoints
│   │   ├── services/          # Business logic
│   │   ├── validators/        # Input validation
│   │   ├── seeds/             # Dữ liệu mẫu
│   │   ├── utils/             # Helper functions
│   │   ├── app.ts             # Express app setup
│   │   └── server.ts          # Server entry point
│   └── public/                # Static files (product images)
│
├── WORKPLAN.md                # Kế hoạch phát triển theo tuần
├── SRS - Camera Store.md      # Đặc tả yêu cầu phần mềm
└── README.md                  # File này
```

Mỗi feature module tuân theo **Clean Architecture**:
```
feature/
├── data/
│   ├── datasources/       # Remote/Local data sources
│   ├── models/            # Data models (fromJson/toJson)
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Business entities
│   └── repositories/      # Repository interfaces (abstract)
└── presentation/
    ├── bloc/              # BLoC (Event, State, Bloc)
    ├── screens/           # UI Screens
    └── widgets/           # UI Components
```

---

## 💻 Yêu cầu hệ thống

| Yêu cầu | Phiên bản tối thiểu |
|----------|---------------------|
| **Flutter SDK** | >= 3.0.0 |
| **Dart SDK** | >= 3.0.0 |
| **Node.js** | >= 18.0.0 |
| **npm** | >= 9.0.0 |
| **MongoDB** | >= 6.0 |
| **Android Studio** | Bản mới nhất (có Android Emulator) |
| **Git** | Bản mới nhất |

---

## 🚀 Cài đặt và Chạy

### 1. Backend (Node.js + Express + MongoDB)

#### Bước 1: Cài đặt MongoDB

- **Windows**: Tải và cài từ [mongodb.com/try/download](https://www.mongodb.com/try/download/community)
- Hoặc sử dụng **MongoDB Atlas** (cloud): [cloud.mongodb.com](https://cloud.mongodb.com)

Đảm bảo MongoDB đang chạy trên `mongodb://localhost:27017`.

#### Bước 2: Cài đặt dependencies

```bash
cd camera-store-backend
npm install
```

#### Bước 3: Tạo file `.env` (tùy chọn)

Tạo file `camera-store-backend/.env`:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/camera_store
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_IN=7d
```

> **Lưu ý**: Nếu không tạo file `.env`, backend sẽ dùng giá trị mặc định (port 5000, MongoDB localhost).

#### Bước 4: Seed dữ liệu mẫu

```bash
npm run seed
```

Lệnh này sẽ tạo sẵn:
- Các danh mục sản phẩm (DSLR, Mirrorless, Ống kính, ...)
- Các thương hiệu (Canon, Sony, Fujifilm, ...)
- Sản phẩm mẫu với ảnh
- Tài khoản admin

#### Bước 5: Chạy server

```bash
# Development (auto-reload khi sửa code)
npm run dev

# Production
npm run build
npm start
```

Server sẽ chạy tại: `http://localhost:5000`

---

### 2. Flutter App

#### Bước 1: Cài đặt Flutter SDK

Tải Flutter SDK từ [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install)

Kiểm tra cài đặt:
```bash
flutter doctor
```

Đảm bảo tất cả các mục đều ✅ (đặc biệt là Android toolchain và Android Studio).

#### Bước 2: Cài đặt dependencies

```bash
cd camera-store-app
flutter pub get
```

#### Bước 3: Cấu hình API URL

Mở file `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Cho Android Emulator (mặc định)
  static const String baseUrl = 'http://10.0.2.2:5000';

  // Cho thiết bị thật - đổi thành IP máy tính
  // static const String baseUrl = 'http://192.168.1.xxx:5000';
}
```

| Môi trường | Giá trị `baseUrl` |
|------------|-------------------|
| Android Emulator | `http://10.0.2.2:5000` |
| Thiết bị thật (cùng WiFi) | `http://<IP-máy-tính>:5000` |
| iOS Simulator | `http://localhost:5000` |

> **Lưu ý**: `10.0.2.2` là địa chỉ đặc biệt của Android Emulator, trỏ về `localhost` của máy host.

#### Bước 4: Chạy ứng dụng

```bash
# Liệt kê các thiết bị/emulator
flutter devices

# Chạy trên emulator đang bật
flutter run

# Chạy trên thiết bị cụ thể
flutter run -d <device_id>

# Chạy ở chế độ release
flutter run --release
```

#### Các phím tắt khi đang chạy `flutter run`:

| Phím | Chức năng |
|------|-----------|
| `r` | **Hot Reload** - Cập nhật UI nhanh (giữ state) |
| `R` | **Hot Restart** - Khởi động lại app (reset state) |
| `q` | Thoát |
| `p` | Bật/tắt lưới debug |
| `o` | Chuyển đổi giữa Android/iOS platform |

---

## ⚙️ Cấu hình môi trường

### Backend `.env`

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `PORT` | `5000` | Cổng chạy server |
| `MONGODB_URI` | `mongodb://localhost:27017/camera_store` | Connection string MongoDB |
| `JWT_SECRET` | `default_secret` | Khóa bí mật cho JWT |
| `JWT_EXPIRES_IN` | `7d` | Thời hạn token (7 ngày) |

### Flutter `app_config.dart`

| Hằng số | Mô tả |
|---------|-------|
| `baseUrl` | URL gốc của backend API |
| `apiBaseUrl` | URL API (`baseUrl/api`) |
| `appName` | Tên ứng dụng hiển thị |

---

## 📝 Các lệnh thường dùng

### Backend

```bash
# Cài đặt dependencies
npm install

# Chạy development server (auto-reload)
npm run dev

# Build production
npm run build

# Chạy production
npm start

# Seed dữ liệu mẫu
npm run seed
```

### Flutter App

```bash
# Cài đặt dependencies
flutter pub get

# Kiểm tra môi trường Flutter
flutter doctor

# Chạy ứng dụng (debug mode)
flutter run

# Chạy ứng dụng (release mode)
flutter run --release

# Build APK
flutter build apk

# Build APK (split per ABI - nhẹ hơn)
flutter build apk --split-per-abi

# Build App Bundle (Google Play)
flutter build appbundle

# Phân tích code
flutter analyze

# Chạy unit tests
flutter test

# Dọn cache
flutter clean
flutter pub get
```

### Git

```bash
# Xem nhánh hiện tại
git branch --show-current

# Chuyển nhánh
git checkout <branch_name>

# Tạo nhánh mới và chuyển sang
git checkout -b feature/<tên-tính-năng>

# Commit và push
git add .
git commit -m "feat: mô tả thay đổi"
git push origin <branch_name>
```

---

## 🔑 Tài khoản test

Sau khi chạy `npm run seed`, các tài khoản sau sẽ được tạo sẵn:

| Vai trò | Email | Mật khẩu |
|---------|-------|----------|
| Admin | `admin@camera-store.com` | `Admin@123` |

Bạn cũng có thể **đăng ký tài khoản mới** trực tiếp trên ứng dụng.

---

## 🔧 Xử lý sự cố

### 1. Không kết nối được backend từ Emulator

- Đảm bảo dùng `10.0.2.2` thay vì `localhost` trong `app_config.dart`
- Kiểm tra backend đang chạy: truy cập `http://localhost:5000` trên trình duyệt
- File `AndroidManifest.xml` cần có `android:usesCleartextTraffic="true"`

### 2. Ảnh sản phẩm không hiển thị

- Kiểm tra backend có serve static files: `http://localhost:5000/public/images/products/`
- Đảm bảo đã chạy `npm run seed` để tạo dữ liệu và ảnh mẫu
- Thử **đổi emulator** khác nếu emulator hiện tại có vấn đề về rendering

### 3. Lỗi `flutter pub get` thất bại

```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### 4. Lỗi MongoDB connection refused

- Kiểm tra MongoDB đang chạy: `mongosh` hoặc `mongo`
- Windows: mở Services → kiểm tra **MongoDB Server** đang **Running**
- Hoặc dùng MongoDB Atlas và cập nhật `MONGODB_URI` trong `.env`

### 5. Hot Reload không hoạt động

```bash
# Thử Hot Restart (nhấn R hoa)
# Nếu vẫn lỗi, dừng và chạy lại:
flutter clean
flutter pub get
flutter run
```

---

## 👥 Nhóm phát triển

Dự án môn **Phát triển ứng dụng di động (PRM)** - FPT University

---

## 📄 License

Dự án này chỉ phục vụ mục đích học tập.