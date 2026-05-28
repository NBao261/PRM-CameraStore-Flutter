# Software Requirements Specification (SRS) - Camera Store App

**Technology Stack (Công nghệ sử dụng):**
- **Frontend (Mobile App):** Flutter (Dart)
- **Backend (REST API):** Node.js (Express)
- **Database:** MongoDB

---

## 1. Role / Actor
- **User (Khách hàng):** Người dùng có tài khoản, thực hiện các thao tác tìm kiếm sản phẩm, xem chi tiết, thêm vào giỏ hàng, đặt hàng, theo dõi đơn hàng, chat với nhân viên hỗ trợ và quản lý thông tin cá nhân.
- **Support Staff (Nhân viên hỗ trợ):** Người tiếp nhận tin nhắn và chat trực tiếp với User để hỗ trợ, tư vấn (được đề cập trong tính năng Chat).
- **Hệ thống (System):** Thực hiện các tác vụ ngầm như tính toán tổng tiền, kiểm tra tồn kho, gửi thông báo, xử lý thanh toán, lưu trữ dữ liệu.

---

## 2. Functional Requirements (Yêu cầu chức năng)

### Phase 1: Design Database / API Structure
- Hệ thống phải cung cấp các REST API endpoints (GET, POST, PUT, DELETE) cho Auth, Products, Categories, Cart, Orders, Notifications, Stores, và Chat.
- Hệ thống lưu trữ dữ liệu trong MongoDB với các collections tương ứng.

### Phase 2: Register Screen
- Hệ thống cho phép người dùng đăng ký tài khoản mới bằng Họ tên, Email, Số điện thoại và Mật khẩu.
- Hệ thống kiểm tra tính hợp lệ của dữ liệu đầu vào.
- Hệ thống chuyển hướng người dùng sang màn hình Login sau khi đăng ký thành công.

### Phase 3: Login Screen
- Hệ thống cho phép người dùng đăng nhập bằng Email và Mật khẩu.
- Hệ thống cấp phát và lưu trữ JWT Token sau khi xác thực thành công.
- Hệ thống cung cấp điều hướng sang màn hình Register nếu người dùng chưa có tài khoản.

### Phase 4: Product List Screen
- Hệ thống hiển thị danh sách các sản phẩm camera.
- Hệ thống cung cấp công cụ tìm kiếm và lọc sản phẩm (danh mục, thương hiệu, khoảng giá, trạng thái).
- Hệ thống điều hướng người dùng đến màn hình chi tiết khi click vào một sản phẩm.

### Phase 5: Product Detail Screen
- Hệ thống hiển thị thông tin chi tiết của sản phẩm (ảnh, giá, thông số, trạng thái tồn kho, chính sách bảo hành).
- Hệ thống cho phép người dùng chọn số lượng và thêm sản phẩm vào giỏ hàng.

### Phase 6: Shopping Cart Screen
- Hệ thống hiển thị danh sách sản phẩm trong giỏ hàng cùng thông tin thành tiền.
- Hệ thống cho phép người dùng tăng/giảm số lượng hoặc xóa sản phẩm khỏi giỏ.
- Hệ thống tự động tính toán lại tổng tiền khi có sự thay đổi.

### Phase 7: Checkout / Billing Screen
- Hệ thống hiển thị tóm tắt đơn hàng (sản phẩm, tổng tiền hàng, phí giao hàng).
- Hệ thống cho phép nhập/xác nhận thông tin giao hàng và chọn phương thức thanh toán.
- Hệ thống tạo đơn hàng mới, gửi thông báo cho user và làm trống giỏ hàng sau khi đặt thành công.

### Phase 8: Order History Screen
- Hệ thống hiển thị danh sách các đơn hàng đã đặt kèm trạng thái hiện tại.
- Hệ thống cho phép xem chi tiết từng đơn hàng (sản phẩm, giao hàng, thanh toán, lịch sử trạng thái).

### Phase 9: Notifications Screen
- Hệ thống hiển thị danh sách thông báo.
- Hệ thống cho phép đánh dấu thông báo là đã đọc và điều hướng đến màn hình liên quan.

### Phase 10: Map Store Location Screen
- Hệ thống hiển thị bản đồ với vị trí (marker) của các cửa hàng.
- Hệ thống hiển thị thông tin liên hệ và thời gian làm việc của cửa hàng khi xem chi tiết marker.

### Phase 11: Chat Support Screen
- Hệ thống cung cấp giao diện chat trực tiếp giữa Khách hàng và Nhân viên hỗ trợ.
- Hệ thống hiển thị và lưu trữ lịch sử tin nhắn.

### Phase 12: User Profile Screen
- Hệ thống hiển thị thông tin cá nhân của người dùng.
- Hệ thống cho phép chỉnh sửa thông tin cá nhân, cập nhật địa chỉ, đổi mật khẩu và đăng xuất.

---

## 3. Non-functional Requirements (Yêu cầu phi chức năng)
- **Bảo mật (Security):** 
  - Mật khẩu phải được mã hóa bằng thuật toán `bcrypt` ở phía backend.
  - Xác thực người dùng phải được thực hiện thông qua `JWT Token` cho các API yêu cầu quyền đăng nhập.
- **Hiệu năng & Trải nghiệm (Performance & Usability):**
  - Phải áp dụng State Management (Provider, Bloc, hoặc Cubit) để quản lý và đồng bộ trạng thái (Authentication, Cart, Orders...) mượt mà mà không cần reload ứng dụng toàn cục.
  - Giao diện cần hiển thị rõ ràng các trạng thái loading, lỗi (error), hoặc thành công (success) để phản hồi kịp thời cho người dùng.
- **Thời gian thực (Real-time):** Tính năng Chat Support phải phản hồi theo thời gian thực (thông qua WebSocket hoặc Socket.io).

---

## 4. Business Rules (Quy tắc nghiệp vụ chi tiết)

### Phase 1: Design Database / API Structure
- Mật khẩu người dùng không bao giờ được lưu dưới dạng plain-text trong database.

### Phase 2: Register Screen
- Các trường Họ tên, Email, SĐT, Mật khẩu đều là bắt buộc.
- Email phải đúng định dạng chuẩn.
- Số điện thoại phải hợp lệ.
- Mật khẩu phải có độ dài tối thiểu là 6 ký tự.
- 'Xác nhận mật khẩu' phải khớp hoàn toàn với 'Mật khẩu'.
- Không cho phép đăng ký tài khoản với Email đã tồn tại trong hệ thống.

### Phase 3: Login Screen
- Người dùng chỉ được đăng nhập nếu tài khoản tồn tại và đúng mật khẩu.
- Tài khoản đang trong trạng thái bị khóa (blocked) không được phép truy cập.

### Phase 4: Product List Screen
- Nếu không có sản phẩm nào, hoặc kết quả lọc/tìm kiếm rỗng, phải hiển thị thông báo cụ thể (không để màn hình trắng).

### Phase 5: Product Detail Screen
- Nút "Add to Cart" phải bị ẩn hoặc vô hiệu hóa nếu trạng thái sản phẩm là "hết hàng".

### Phase 6: Shopping Cart Screen
- Số lượng sản phẩm trong giỏ hàng tối thiểu là 1 (nếu giảm về 0, hệ thống tự hiểu là xóa sản phẩm khỏi giỏ).
- Không cho phép người dùng thao tác Checkout nếu giỏ hàng đang trống.

### Phase 7: Checkout / Billing Screen
- Thông tin giao hàng (Tên người nhận, SĐT, Địa chỉ) là bắt buộc nhập.
- Trạng thái khởi tạo của một đơn hàng mới luôn là "Pending".
- Giỏ hàng hiện tại của User phải được dọn sạch (clear) ngay lập tức sau khi tạo đơn hàng thành công.

### Phase 8: Order History Screen
- Danh sách đơn hàng phải được sắp xếp theo thời gian đặt hàng (đơn hàng mới nhất xếp ở trên cùng).

### Phase 9: Notifications Screen
- Thông báo chưa đọc và đã đọc phải được phân biệt rõ ràng bằng UI.

### Phase 12: User Profile Screen
- Người dùng không được phép thay đổi địa chỉ Email đã dùng để đăng ký.
- Khi đổi mật khẩu, mật khẩu mới cũng phải tuân thủ quy tắc độ dài tối thiểu 6 ký tự.
