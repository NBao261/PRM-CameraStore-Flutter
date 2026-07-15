# Phân công nhiệm vụ - Camera Store App (Tính năng thuần túy)

Danh sách gồm **15 cụm tính năng thực tế** trong App. Mỗi thành viên sẽ đảm nhận **chính xác 3 chức năng** (bao gồm cả Backend và Frontend). Các chức năng đã được phân chia ngẫu nhiên để đảm bảo tính công bằng về số lượng.

---

### 1. Nguyễn Vũ Len
_Đảm nhận 3 chức năng:_

- **Phase 2 & 3: Register / Login Screen:** Xây dựng luồng xác thực, mã hóa mật khẩu, tạo Token đăng nhập và giao diện Auth.
- **Phase 5: Product Detail Screen (User):** Hiển thị chi tiết sản phẩm, cho phép chọn số lượng và gọi logic thêm vào giỏ.
- **Phase 19: Admin Notification & Chat Support:** Xây dựng màn hình Admin quản lý chat của nhiều User cùng lúc và push Socket thông báo cho toàn hệ thống.

---

### 2. Nguyễn Thị Yến Nhi
_Đảm nhận 3 chức năng:_

- **Phase 7: Checkout / Billing Screen:** Xử lý luồng đặt hàng, xác nhận thông tin giao hàng và lưu transaction vào cơ sở dữ liệu.
- **Phase 8: Order History Screen (User):** Lấy và hiển thị lịch sử đơn hàng của User, xem chi tiết các đơn cũ.
- **Phase 14: Coupon / Promo Code:** Tạo mã khuyến mãi (Admin) và tính toán áp dụng mã (% giảm giá, điều kiện) cho User.

---

### 3. Thái Minh Tuấn
_Đảm nhận 3 chức năng:_

- **Phase 6: Shopping Cart Screen (User):** Quản lý trạng thái giỏ hàng, tính tổng tiền, thay đổi số lượng, xóa sản phẩm.
- **Phase 10: Map Store Location Screen (User):** Tích hợp bản đồ (Google Maps) để hiển thị vị trí của cửa hàng.
- **Phase 11: Chat Support Screen (User):** Tích hợp kết nối WebSocket/Socket.io để làm chức năng chat trực tiếp 1-1 với Admin.

---

### 4. Trần Minh Kiệt
_Đảm nhận 3 chức năng:_

- **Phase 4: Product List Screen (User):** Hiển thị danh sách sản phẩm từ DB, làm các bộ lọc (Filter) và tìm kiếm (Search).
- **Phase 12: User Profile Screen (User):** Hiển thị và cập nhật thông tin cá nhân (Tên, Số điện thoại, Địa chỉ).
- **Phase 16: Admin Dashboard:** Viết API thống kê doanh thu, số đơn hàng, khách hàng và hiển thị biểu đồ lên Admin.

---

### 5. Nguyễn Chí Bảo
_Đảm nhận 3 chức năng:_

- **Phase 9: Notifications Screen (User):** Xử lý nhận thông báo real-time khi có cập nhật đơn hàng hoặc tin nhắn, hiển thị danh sách thông báo.
- **Phase 15: Product Review / Rating:** Cho phép User đánh giá sao (1-5), lưu nhận xét và tính lại điểm trung bình cho sản phẩm.
- **Phase 18: Admin Order Management:** Quản lý vòng đời đơn hàng (Pending -> Shipping -> Delivered), cập nhật trạng thái đơn hàng phía Admin.

---

### 📌 Ghi chú
- 15 module tính năng đã được chia ngẫu nhiên và đồng đều (3 task/người), không ai nhiều hơn hay ít hơn.
- Tất cả đều làm Fullstack (Node.js API + Flutter UI) cho phần việc của mình.
