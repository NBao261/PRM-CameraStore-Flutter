# Kế hoạch Phát triển Camera Store (9 Tuần)

Dựa trên **Software Requirements Specification (SRS)**, dưới đây là kế hoạch phát triển (Workplan) chi tiết chia thành 9 tuần cho dự án Camera Store, bao gồm cả Frontend (Flutter) và Backend (Node.js/Express).

> [!NOTE]
> _Phase 1 (Thiết kế Database & API)_ và _Khởi tạo cấu trúc Clean Architecture cho Flutter_ đã được thực hiện xong một phần lớn. Kế hoạch này sẽ tập trung mạnh vào việc hoàn thiện Frontend và tích hợp.

---

## Tuần 1: Khởi tạo, Cấu trúc & Xác thực (Authentication) [x]

_Tương ứng với Phase 1, Phase 2, Phase 3_

**Mục tiêu:** Hoàn thiện nền tảng dự án và tính năng đăng nhập/đăng ký.

- **Backend:**
  - Hoàn thiện API Register & Login (đã xong).
- **Frontend (Flutter):**
  - Cấu hình Clean Architecture, Routing, Theme, HTTP Client (Dio).
  - Triển khai **Register Screen** (kiểm tra validate họ tên, email, sđt, password tối thiểu 6 ký tự).
  - Triển khai **Login Screen** (xác thực, lưu trữ JWT Token vào bộ nhớ bảo mật, xử lý trạng thái bị khóa).
  - Quản lý trạng thái (State Management) cho Auth (Bloc/Cubit).

---

## Tuần 2: Khám phá Sản phẩm (Product Discovery) [x]

_Tương ứng với Phase 4, Phase 5_

**Mục tiêu:** Cho phép người dùng duyệt, tìm kiếm và xem chi tiết sản phẩm.

- **Frontend (Flutter):**
  - Triển khai **Product List Screen**: Gọi API lấy danh sách, làm giao diện lưới/danh sách.
  - Xây dựng công cụ Tìm kiếm và Bộ lọc (theo danh mục, thương hiệu, khoảng giá).
  - Xử lý UI empty state (khi không có sản phẩm/tìm kiếm rỗng).
  - Triển khai **Product Detail Screen**: Hiển thị ảnh, thông số, trạng thái tồn kho.
  - Vô hiệu hóa nút "Add to Cart" nếu sản phẩm hết hàng.
  - UI/UX Polish: Áp dụng Mobile-First & Premium aesthetics (Glassmorphism, animations).

---

## Tuần 3: Giỏ hàng (Shopping Cart)

_Tương ứng với Phase 6_

**Mục tiêu:** Quản lý giỏ hàng của người dùng một cách liền mạch.

- **Frontend (Flutter):**
  - Tích hợp tính năng thêm sản phẩm vào giỏ từ màn hình chi tiết.
  - Triển khai **Shopping Cart Screen**: Hiển thị danh sách sản phẩm.
  - Logic tăng/giảm số lượng (nếu giảm về 0 -> xóa khỏi giỏ).
  - Tự động tính toán tổng tiền realtime.
  - Bắt lỗi: Không cho phép Checkout nếu giỏ hàng trống.

---

## Tuần 4: Đặt hàng & Thanh toán (Checkout & Billing)

_Tương ứng với Phase 7_

**Mục tiêu:** Hoàn tất luồng mua sắm và tạo đơn hàng thành công.

- **Frontend (Flutter):**
  - Triển khai **Checkout / Billing Screen**: Hiển thị tóm tắt đơn hàng.
  - Form điền thông tin giao hàng (bắt buộc nhập tên, sđt, địa chỉ).
  - Tích hợp chọn phương thức thanh toán (COD, Chuyển khoản, v.v.).
  - Gọi API tạo đơn hàng (trạng thái "Pending").
  - Xóa sạch giỏ hàng nội bộ và chuyển hướng người dùng sau khi đặt thành công.

---

## Tuần 5: Quản lý Đơn hàng (Order History)

_Tương ứng với Phase 8_

**Mục tiêu:** Người dùng theo dõi được lịch sử mua hàng của mình.

- **Frontend (Flutter):**
  - Triển khai **Order History Screen**: Hiển thị danh sách đơn hàng.
  - Sắp xếp đơn hàng mới nhất lên trên cùng.
  - Triển khai **Order Detail Screen**: Xem chi tiết trạng thái, sản phẩm, thông báo giao hàng của một đơn cụ thể.

---

## Tuần 6: Hồ sơ Người dùng & Thông báo

_Tương ứng với Phase 9, Phase 12_

**Mục tiêu:** Quản lý tài khoản cá nhân và trung tâm thông báo.

- **Frontend (Flutter):**
  - Triển khai **User Profile Screen**: Hiển thị thông tin cá nhân.
  - Cho phép cập nhật thông tin (không cho đổi email).
  - Chức năng đổi mật khẩu (validate >= 6 ký tự).
  - Triển khai **Notifications Screen**: Hiển thị danh sách thông báo.
  - UI phân biệt rõ thông báo đã đọc / chưa đọc.

---

## Tuần 7: Hỗ trợ trực tuyến (Real-time Chat)

_Tương ứng với Phase 11_

**Mục tiêu:** Giao tiếp thời gian thực giữa Khách hàng và Nhân viên hỗ trợ.

- **Backend:**
  - Đảm bảo Socket.io hoạt động ổn định, lưu trữ lịch sử chat.
- **Frontend (Flutter):**
  - Cài đặt và cấu hình thư viện Socket.io client cho Flutter.
  - Triển khai **Chat Support Screen**: Giao diện bong bóng chat (chat bubbles).
  - Logic gửi/nhận tin nhắn realtime và tải lịch sử tin nhắn cũ.

---

## Tuần 8: Bản đồ Cửa hàng & Cải thiện UI/UX (Polish)

_Tương ứng với Phase 10_

**Mục tiêu:** Tích hợp bản đồ và tinh chỉnh trải nghiệm người dùng.

- **Frontend (Flutter):**
  - Tích hợp Google Maps SDK (hoặc Mapbox).
  - Triển khai **Map Store Location Screen**: Hiển thị marker vị trí cửa hàng, thông tin liên hệ.
  - UX/UI Polish: Thêm các hiệu ứng chuyển cảnh, skeleton loading, xử lý lỗi mạng (no internet connection).

---

## Tuần 9: Kiểm thử, Sửa lỗi & Chuẩn bị Release (UAT & Deployment)

**Mục tiêu:** Đảm bảo hệ thống hoạt động ổn định, không có bug nghiêm trọng trước khi phát hành.

- **Testing:**
  - Test toàn bộ luồng chức năng (End-to-End).
  - Kiểm tra các Business Rules (điều kiện validate, khóa tài khoản, trạng thái giỏ hàng, v.v.).
- **Fixing:** Sửa các lỗi phát sinh (bugs) trên cả Backend và Frontend.
- **Deployment:**
  - Build file APK/AAB cho Android và IPA cho iOS.
  - Deploy Backend lên server staging/production.
