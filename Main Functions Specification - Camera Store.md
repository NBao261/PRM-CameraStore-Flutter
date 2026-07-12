# Main Functions Specification – Camera Store App

> **Dự án:** Ứng dụng bán Camera  
> **Frontend:** Flutter (Dart)  
> **Backend:** Node.js Express REST API  
> **Database:** MongoDB  
> **Roles:** User (Khách hàng)  
> **Chức năng bổ sung:** Chat với nhân viên hỗ trợ (Human-to-human chat)  

---

## Phase 1: Design Database / API Structure

Nhóm cần thiết kế cấu trúc dữ liệu và REST API để phục vụ toàn bộ ứng dụng bán camera. Backend sử dụng Node.js Express, dữ liệu được lưu trữ trong MongoDB.

### Các dữ liệu chính cần có

| Nhóm dữ liệu     | Mô tả                                                                                                                                                                                                                                |
| ------------------| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| User             | Lưu thông tin tài khoản: họ tên, email, số điện thoại, địa chỉ giao hàng, mật khẩu đã mã hóa (bcrypt), avatar, avatar                                                                                                                |
| Product (Camera) | Lưu thông tin camera: tên sản phẩm, thương hiệu, hình ảnh (nhiều ảnh), giá bán, giá khuyến mãi, mô tả, thông số kỹ thuật (megapixel, loại cảm biến, ISO, loại ống kính, quay video, kết nối), tồn kho, trạng thái còn hàng, danh mục |
| Category / Brand | Lưu danh mục sản phẩm (DSLR, Mirrorless, Compact, Action Camera, Instant Camera) hoặc thương hiệu (Canon, Nikon, Sony, Fujifilm, GoPro, Panasonic)                                                                                   |
| Cart             | Lưu các sản phẩm khách hàng đã thêm vào giỏ hàng, liên kết với user_id                                                                                                                                                               |
| Order            | Lưu thông tin đơn hàng: khách hàng, danh sách sản phẩm, tổng tiền, địa chỉ giao hàng, trạng thái đơn hàng (pending, confirmed, shipping, delivered, cancelled)                                                                       |
| Order Item       | Lưu chi tiết từng sản phẩm trong đơn hàng: product_id, số lượng, giá tại thời điểm đặt                                                                                                                                               |
| Notification     | Lưu thông báo khuyến mãi, cập nhật đơn hàng, thông báo hệ thống, thông báo từ cửa hàng                                                                                                                                               |
| Store Location   | Lưu thông tin vị trí cửa hàng để hiển thị trên bản đồ                                                                                                                                                                                |
| Chat Message     | Lưu nội dung tin nhắn giữa khách hàng và nhân viên hỗ trợ                                                                                                                                                                            |
| Coupon           | Lưu mã khuyến mãi: code (unique), loại giảm (percent/fixed), giá trị giảm, đơn tối thiểu, giảm tối đa, ngày hết hạn, giới hạn lượt dùng, số lượt đã dùng, trạng thái active/inactive                                                   |
| Review           | Lưu đánh giá sản phẩm: user_id, product_id, order_id, rating (1-5), comment, ngày tạo                                                                                                                                               |

### REST API Endpoints chính

| Method | Endpoint                      | Mô tả                             | Role   |
| --------| -------------------------------| -----------------------------------| --------|
| POST   | `/api/auth/register`          | Đăng ký tài khoản                 | Public |
| POST   | `/api/auth/login`             | Đăng nhập                         | Public |
| GET    | `/api/auth/profile`           | Lấy thông tin cá nhân             | User   |
| PUT    | `/api/auth/profile`           | Cập nhật thông tin cá nhân        | User   |
| GET    | `/api/products`               | Lấy danh sách sản phẩm            | Public |
| GET    | `/api/products/:id`           | Lấy chi tiết sản phẩm             | Public |
| GET    | `/api/categories`             | Lấy danh sách danh mục            | Public |
| GET    | `/api/cart`                   | Lấy giỏ hàng                      | User   |
| POST   | `/api/cart`                   | Thêm sản phẩm vào giỏ             | User   |
| PUT    | `/api/cart/:id`               | Cập nhật số lượng                 | User   |
| DELETE | `/api/cart/:id`               | Xóa sản phẩm khỏi giỏ             | User   |
| POST   | `/api/orders`                 | Tạo đơn hàng                      | User   |
| GET    | `/api/orders`                 | Lấy danh sách đơn hàng            | User   |
| GET    | `/api/orders/:id`             | Chi tiết đơn hàng                 | User   |
| GET    | `/api/notifications`          | Lấy danh sách thông báo           | User   |
| PUT    | `/api/notifications/:id/read` | Đánh dấu đã đọc                   | User   |
| GET    | `/api/stores`                 | Lấy danh sách cửa hàng            | Public |
| POST   | `/api/chat`                   | Gửi tin nhắn cho nhân viên hỗ trợ | User   |
| GET    | `/api/chat/history`           | Lấy lịch sử chat                  | User   |
| POST   | `/api/coupons`                | Tạo mã khuyến mãi                 | Admin  |
| GET    | `/api/coupons`                | Lấy danh sách mã khuyến mãi       | Admin  |
| PUT    | `/api/coupons/:id`            | Sửa mã khuyến mãi                 | Admin  |
| POST   | `/api/coupons/apply`          | Áp dụng mã khuyến mãi              | User   |
| POST   | `/api/reviews`                | Tạo đánh giá sản phẩm             | User   |
| GET    | `/api/products/:id/reviews`   | Lấy danh sách đánh giá sản phẩm   | Public |

### Nhóm cần trình bày rõ

- Sơ đồ database hoặc mô tả collection/table.
- Quan hệ giữa các bảng hoặc collection.
- API endpoint đầy đủ cho REST API.
- Cách ứng dụng đọc, ghi, cập nhật và xóa dữ liệu.
- Cách dữ liệu được sử dụng trong từng màn hình.
- Cách xác thực người dùng (JWT Token + Middleware).

---

## Phase 2: Register Screen

Chức năng này cho phép người dùng mới đăng ký tài khoản để sử dụng ứng dụng mua camera.

### Mục đích

Tạo tài khoản mới trong hệ thống cho User.

### Mô tả xử lý

Khi người dùng mở màn hình đăng ký, ứng dụng hiển thị form nhập thông tin gồm:

- Họ và tên.
- Email.
- Số điện thoại.
- Mật khẩu.
- Xác nhận mật khẩu.

Người dùng nhập đầy đủ thông tin và bấm nút Register. Ứng dụng sẽ kiểm tra:

- Các trường bắt buộc đã được nhập đầy đủ hay chưa.
- Email có đúng định dạng không.
- Số điện thoại có hợp lệ không.
- Mật khẩu có đủ độ dài tối thiểu (ví dụ 6 ký tự) không.
- Mật khẩu và xác nhận mật khẩu có khớp nhau không.
- Email đã tồn tại trong hệ thống hay chưa (gọi API kiểm tra).

Nếu thông tin hợp lệ, ứng dụng gọi API `POST /api/auth/register` để tạo tài khoản mới. Backend mã hóa mật khẩu bằng bcrypt trước khi lưu vào database. Sau khi đăng ký thành công, ứng dụng hiển thị thông báo thành công và chuyển sang màn hình đăng nhập.

Nếu thông tin không hợp lệ hoặc email đã tồn tại, ứng dụng hiển thị thông báo lỗi rõ ràng tại vị trí tương ứng.

### Input

- Họ và tên.
- Email.
- Số điện thoại.
- Mật khẩu.
- Xác nhận mật khẩu.

### Output

- Tài khoản mới được tạo trong database.
- Hiển thị thông báo đăng ký thành công.
- Chuyển sang màn hình đăng nhập.
- Hoặc hiển thị thông báo lỗi nếu đăng ký thất bại.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có kiểm tra dữ liệu nhập vào (validation).
- Có hiển thị lỗi khi nhập sai từng trường.
- Có kiểm tra email trùng lặp.
- Có kiểm tra mật khẩu khớp.
- Có mã hóa mật khẩu phía backend.
- Có giao diện rõ ràng, dễ sử dụng.
- Có điều hướng sang màn hình Login sau khi đăng ký thành công.

---

## Phase 3: Login Screen

Chức năng này cho phép người dùng đăng nhập vào ứng dụng để sử dụng các chức năng tương ứng với role của mình.

### Mục đích

Đảm bảo chỉ người dùng đã có tài khoản mới có thể thực hiện các thao tác liên quan đến mua hàng. Hệ thống xác thực để hiển thị giao diện phù hợp.

### Mô tả xử lý

Khi mở ứng dụng, người dùng có thể được đưa đến màn hình đăng nhập nếu chưa đăng nhập trước đó. Người dùng nhập email và mật khẩu, sau đó bấm nút Login.

Ứng dụng gọi API `POST /api/auth/login` và kiểm tra:

- Người dùng đã nhập đủ thông tin hay chưa.
- Email có đúng định dạng không.
- Mật khẩu có hợp lệ không.
- Tài khoản có tồn tại trong hệ thống không.
- Tài khoản có bị khóa (blocked) không.

Nếu thông tin hợp lệ, backend trả về JWT Token cùng thông tin user. Ứng dụng lưu token vào SharedPreferences hoặc SecureStorage, sau đó chuyển đến màn hình chính của khách hàng (Home/Product List).

Nếu thông tin sai, ứng dụng hiển thị thông báo lỗi rõ ràng, ví dụ: "Email hoặc mật khẩu không đúng" hoặc "Tài khoản đã bị khóa".

Ứng dụng cũng có nút chuyển sang màn hình Register cho người dùng chưa có tài khoản.

### Input

- Email.
- Mật khẩu.

### Output

- Đăng nhập thành công và chuyển sang màn hình chính (User) hoặc Dashboard (Admin).
- JWT Token được lưu trữ.
- Hoặc hiển thị thông báo lỗi nếu đăng nhập thất bại.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có kiểm tra dữ liệu nhập vào.
- Có hiển thị lỗi khi nhập sai.
- Có lưu trạng thái đăng nhập (JWT Token).
- Có phân biệt người dùng đã đăng nhập và chưa đăng nhập.
- Có giao diện rõ ràng, dễ sử dụng.
- Có nút chuyển sang màn hình Register.

---

## Phase 4: Product List Screen (User)

Chức năng này hiển thị danh sách các camera đang được bán trong cửa hàng.

### Mục đích

Giúp khách hàng xem nhanh các sản phẩm camera hiện có, tìm kiếm sản phẩm phù hợp và chọn sản phẩm để xem chi tiết.

### Mô tả xử lý

Khi người dùng (User) truy cập màn hình danh sách sản phẩm, ứng dụng gọi API `GET /api/products` để lấy dữ liệu sản phẩm và hiển thị thành danh sách hoặc dạng lưới (Grid).

Mỗi sản phẩm nên hiển thị các thông tin cơ bản:

- Hình ảnh camera.
- Tên sản phẩm.
- Thương hiệu (Canon, Nikon, Sony, Fujifilm...).
- Giá bán.
- Giá khuyến mãi nếu có.
- Trạng thái còn hàng hoặc hết hàng.

Người dùng có thể cuộn danh sách để xem thêm sản phẩm. Ứng dụng nên có thêm chức năng tìm kiếm hoặc lọc sản phẩm theo tiêu chí như:

- Tên camera.
- Thương hiệu.
- Danh mục (DSLR, Mirrorless, Compact, Action Camera, Instant Camera).
- Khoảng giá.
- Sản phẩm khuyến mãi.
- Sản phẩm còn hàng.

Khi người dùng chọn một sản phẩm, ứng dụng chuyển sang màn hình chi tiết sản phẩm.

### Input

- Danh sách sản phẩm từ API `GET /api/products`.
- Từ khóa tìm kiếm (query params: `?search=keyword`).
- Điều kiện lọc sản phẩm nếu có (query params: `?category=mirrorless&brand=sony&minPrice=5000000&maxPrice=20000000`).

### Output

- Danh sách sản phẩm được hiển thị.
- Danh sách sản phẩm sau khi tìm kiếm/lọc.
- Điều hướng sang màn hình chi tiết sản phẩm.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có hiển thị danh sách sản phẩm từ dữ liệu thật (API).
- Có hình ảnh, tên và giá sản phẩm.
- Có xử lý trạng thái loading khi tải dữ liệu.
- Có xử lý trường hợp không có sản phẩm.
- Có tìm kiếm hoặc lọc sản phẩm.
- Có điều hướng sang màn hình chi tiết sản phẩm.

---

## Phase 5: Product Detail Screen (User)

Chức năng này hiển thị thông tin chi tiết của một camera được khách hàng chọn từ danh sách sản phẩm.

### Mục đích

Giúp khách hàng hiểu rõ sản phẩm camera trước khi quyết định thêm vào giỏ hàng hoặc mua hàng.

### Mô tả xử lý

Khi người dùng chọn một sản phẩm từ màn hình danh sách, ứng dụng gọi API `GET /api/products/:id` và mở màn hình chi tiết sản phẩm, hiển thị đầy đủ thông tin của camera đó.

Thông tin chi tiết nên bao gồm:

- Hình ảnh sản phẩm (hỗ trợ nhiều ảnh, có thể vuốt xem).
- Tên sản phẩm.
- Thương hiệu.
- Giá bán.
- Giá khuyến mãi nếu có (hiển thị phần trăm giảm giá).
- Mô tả sản phẩm.
- Thông số kỹ thuật: Megapixel, loại cảm biến (Full-frame, APS-C, Micro Four Thirds), ISO range, loại ống kính (kit lens), quay video (4K, Full HD), kết nối (Wi-Fi, Bluetooth, NFC), pin, trọng lượng.
- Tình trạng còn hàng.
- Chính sách bảo hành.
- Nút thêm vào giỏ hàng (Add to Cart).

Người dùng có thể chọn số lượng sản phẩm muốn mua. Nếu sản phẩm còn hàng, người dùng có thể bấm Add to Cart. Nếu sản phẩm hết hàng, nút thêm vào giỏ hàng nên bị ẩn hoặc bị vô hiệu hóa.

### Input

- Mã sản phẩm (product_id) từ màn hình danh sách.
- Số lượng sản phẩm người dùng muốn mua.

### Output

- Hiển thị thông tin chi tiết sản phẩm.
- Thêm sản phẩm vào giỏ hàng qua API `POST /api/cart` nếu hợp lệ.
- Hiển thị thông báo thành công hoặc lỗi.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Hiển thị đầy đủ thông tin sản phẩm.
- Có thông tin thông số kỹ thuật phù hợp với camera.
- Có xử lý trạng thái còn hàng/hết hàng.
- Có nút thêm vào giỏ hàng.
- Có cập nhật giỏ hàng sau khi thêm sản phẩm.
- Có thông báo phản hồi cho người dùng.

---

## Phase 6: Shopping Cart Screen (User)

Chức năng này cho phép khách hàng xem và quản lý các sản phẩm đã thêm vào giỏ hàng.

### Mục đích

Giúp khách hàng kiểm tra lại sản phẩm camera muốn mua trước khi tiến hành thanh toán.

### Mô tả xử lý

Khi người dùng mở màn hình giỏ hàng, ứng dụng gọi API `GET /api/cart` và hiển thị danh sách các sản phẩm đã được thêm vào. Mỗi dòng sản phẩm trong giỏ hàng nên có:

- Hình ảnh sản phẩm.
- Tên sản phẩm.
- Giá bán.
- Số lượng.
- Thành tiền (giá × số lượng).
- Nút tăng/giảm số lượng.
- Nút xóa sản phẩm khỏi giỏ hàng.

Người dùng có thể thay đổi số lượng sản phẩm bằng cách gọi API `PUT /api/cart/:id`. Khi số lượng thay đổi, ứng dụng phải tự động cập nhật lại tổng tiền. Nếu người dùng xóa một sản phẩm (API `DELETE /api/cart/:id`), sản phẩm đó sẽ biến mất khỏi giỏ hàng và tổng tiền cũng được tính lại.

Nếu giỏ hàng rỗng, ứng dụng cần hiển thị thông báo như: "Your cart is empty" hoặc "Giỏ hàng của bạn đang trống".

Khi người dùng đã kiểm tra xong, họ có thể bấm nút Checkout để chuyển sang màn hình thanh toán.

### Input

- Danh sách sản phẩm trong giỏ hàng từ API.
- Thao tác tăng/giảm số lượng.
- Thao tác xóa sản phẩm.
- Thao tác chuyển sang thanh toán.

### Output

- Giỏ hàng được cập nhật.
- Tổng tiền được tính lại.
- Chuyển sang màn hình checkout.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có hiển thị đúng sản phẩm đã thêm vào giỏ.
- Có cập nhật số lượng sản phẩm.
- Có xóa sản phẩm khỏi giỏ hàng.
- Có tính tổng tiền chính xác.
- Có xử lý giỏ hàng rỗng.
- Có điều hướng sang màn hình checkout.

---

## Phase 7: Checkout / Billing Screen (User)

Chức năng này cho phép khách hàng xác nhận đơn hàng và thực hiện bước đặt mua sản phẩm camera.

### Mục đích

Hoàn tất quá trình mua hàng bằng cách thu thập thông tin giao hàng, phương thức thanh toán và tạo đơn hàng trong hệ thống.

### Mô tả xử lý

Khi người dùng bấm Checkout từ giỏ hàng, ứng dụng mở màn hình thanh toán. Màn hình này hiển thị lại thông tin đơn hàng gồm:

- Danh sách sản phẩm camera.
- Số lượng từng sản phẩm.
- Tổng tiền hàng.
- Phí giao hàng nếu có.
- Tổng tiền thanh toán.

Người dùng cần nhập hoặc xác nhận thông tin giao hàng:

- Họ tên người nhận.
- Số điện thoại.
- Địa chỉ giao hàng.
- Ghi chú nếu có.

Người dùng chọn phương thức thanh toán, ví dụ:

- Thanh toán khi nhận hàng (COD).
- Chuyển khoản ngân hàng.
- Ví điện tử giả lập (momo sandbox, vnPay sandbox).

Sau khi người dùng bấm Place Order hoặc Confirm Order, ứng dụng gọi API `POST /api/orders` với dữ liệu đơn hàng. Backend kiểm tra dữ liệu, tạo đơn hàng mới với trạng thái "pending", lưu vào database, xóa giỏ hàng hiện tại, tạo notification cho user, rồi trả về kết quả. Ứng dụng hiển thị thông báo đặt hàng thành công.

### Input

- Danh sách sản phẩm trong giỏ hàng.
- Thông tin người nhận.
- Địa chỉ giao hàng.
- Phương thức thanh toán.

### Output

- Đơn hàng mới được tạo qua API.
- Giỏ hàng được làm trống.
- Hiển thị thông báo đặt hàng thành công.
- Có thể chuyển sang màn hình thông báo hoặc màn hình danh sách sản phẩm.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có hiển thị tóm tắt đơn hàng.
- Có nhập và kiểm tra thông tin giao hàng.
- Có chọn phương thức thanh toán.
- Có tạo đơn hàng qua API backend.
- Có cập nhật trạng thái đơn hàng.
- Có xóa giỏ hàng sau khi đặt hàng thành công.
- Có thông báo kết quả cho người dùng.

---

## Phase 8: Order History Screen (User)

Chức năng này cho phép khách hàng xem lại lịch sử các đơn hàng đã đặt.

### Mục đích

Giúp khách hàng theo dõi trạng thái đơn hàng và xem lại thông tin các đơn hàng trước đó.

### Mô tả xử lý

Khi người dùng mở màn hình lịch sử đơn hàng, ứng dụng gọi API `GET /api/orders` và hiển thị danh sách các đơn hàng của khách hàng đó.

Mỗi đơn hàng nên hiển thị:

- Mã đơn hàng.
- Ngày đặt hàng.
- Tổng tiền.
- Trạng thái đơn hàng (Pending, Confirmed, Shipping, Delivered, Cancelled).
- Số lượng sản phẩm.

Khi người dùng bấm vào một đơn hàng, ứng dụng gọi API `GET /api/orders/:id` và hiển thị chi tiết đơn hàng gồm:

- Danh sách sản phẩm trong đơn.
- Thông tin giao hàng.
- Phương thức thanh toán.
- Trạng thái đơn hàng hiện tại.
- Lịch sử thay đổi trạng thái nếu có.

Đơn hàng nên được hiển thị theo thứ tự mới nhất lên đầu. Có thể lọc theo trạng thái.

### Input

- Danh sách đơn hàng từ API `GET /api/orders`.
- Thao tác chọn đơn hàng để xem chi tiết.
- Bộ lọc trạng thái đơn hàng nếu có.

### Output

- Danh sách đơn hàng được hiển thị.
- Chi tiết đơn hàng khi bấm vào.
- Trạng thái đơn hàng được cập nhật real-time nếu có.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có danh sách đơn hàng.
- Có hiển thị mã đơn, ngày đặt, tổng tiền và trạng thái.
- Có xem chi tiết đơn hàng.
- Có phân biệt các trạng thái đơn hàng bằng màu sắc hoặc icon.
- Có xử lý khi không có đơn hàng.
- Có sắp xếp đơn hàng theo thời gian.

---

## Phase 9: Notifications Screen (User)

Chức năng này hiển thị các thông báo liên quan đến khách hàng, sản phẩm và đơn hàng.

### Mục đích

Giúp khách hàng nhận được thông tin mới từ cửa hàng như khuyến mãi, sản phẩm mới, xác nhận đơn hàng hoặc cập nhật trạng thái giao hàng.

### Mô tả xử lý

Khi người dùng mở màn hình thông báo, ứng dụng gọi API `GET /api/notifications` và hiển thị danh sách các thông báo.

Thông báo có thể gồm:

- Thông báo khuyến mãi camera.
- Thông báo sản phẩm mới (Camera mới ra mắt).
- Thông báo đơn hàng đã được xác nhận.
- Thông báo đơn hàng đang giao.
- Thông báo đơn hàng đã hoàn tất.
- Thông báo từ cửa hàng.

Mỗi thông báo nên có:

- Tiêu đề.
- Nội dung ngắn.
- Thời gian gửi.
- Trạng thái đã đọc hoặc chưa đọc.
- Loại thông báo (order, promotion, system).

Khi người dùng bấm vào một thông báo, ứng dụng gọi API `PUT /api/notifications/:id/read` để đánh dấu đã đọc, đồng thời có thể chuyển đến màn hình liên quan, ví dụ màn hình đơn hàng hoặc màn hình chi tiết sản phẩm.

### Input

- Danh sách thông báo từ API.
- Thao tác chọn thông báo.
- Thao tác đánh dấu đã đọc.

### Output

- Danh sách thông báo được hiển thị.
- Thông báo được đánh dấu đã đọc.
- Điều hướng đến màn hình liên quan nếu có.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có danh sách thông báo.
- Có tiêu đề, nội dung và thời gian thông báo.
- Có phân biệt đã đọc/chưa đọc.
- Có xử lý khi không có thông báo.
- Có thể mở chi tiết thông báo.
- Có dữ liệu thông báo phù hợp với ngữ cảnh cửa hàng camera.

---

## Phase 10: Map Store Location Screen (User)

Chức năng này hiển thị vị trí cửa hàng camera trên bản đồ.

### Mục đích

Giúp khách hàng biết địa chỉ cửa hàng, xem vị trí trên bản đồ và có thể tìm đường đến cửa hàng.

### Mô tả xử lý

Khi người dùng mở màn hình bản đồ, ứng dụng gọi API `GET /api/stores` để lấy thông tin cửa hàng và hiển thị vị trí trên Google Map hoặc một thư viện bản đồ phù hợp trong Flutter (google_maps_flutter).

Thông tin nên hiển thị gồm:

- Tên cửa hàng.
- Địa chỉ cửa hàng.
- Số điện thoại liên hệ.
- Thời gian làm việc.
- Marker vị trí cửa hàng trên bản đồ.

Người dùng có thể xem vị trí cửa hàng trên bản đồ. Nếu nhóm muốn làm chi tiết hơn, có thể bổ sung chức năng mở Google Maps để chỉ đường.

Ví dụ cửa hàng:
- Tên: Camera World
- Địa chỉ: 456 Lê Văn Việt, Quận 9, TP.HCM
- Hotline: 0909 456 789
- Giờ mở cửa: 8:00 – 21:00

### Input

- Tọa độ cửa hàng từ API.
- Thông tin địa chỉ cửa hàng.

### Output

- Bản đồ hiển thị vị trí cửa hàng.
- Marker cửa hàng.
- Thông tin liên hệ của cửa hàng.
- Có thể mở chỉ đường nếu được triển khai.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có hiển thị bản đồ.
- Có marker vị trí cửa hàng.
- Có thông tin địa chỉ và liên hệ.
- Có giao diện dễ hiểu.
- Có thể mở ứng dụng bản đồ bên ngoài nếu nhóm triển khai thêm.
- Có xử lý quyền truy cập vị trí nếu dùng vị trí hiện tại của người dùng.

---

## Phase 11: Chat Support Screen (User)

Chức năng này cho phép khách hàng trò chuyện trực tiếp với nhân viên hỗ trợ của cửa hàng để hỏi thông tin sản phẩm camera, hỗ trợ đơn hàng hoặc tư vấn mua hàng.

### Mục đích

Tạo kênh hỗ trợ khách hàng trực tiếp ngay trong ứng dụng, cho phép người dùng trao đổi qua lại với nhân viên về các vấn đề như camera, giá cả, bảo hành, tình trạng còn hàng hoặc trạng thái đơn hàng.

### Mô tả xử lý

Khi người dùng mở màn hình Chat, ứng dụng hiển thị khung hội thoại giữa khách hàng và nhân viên hỗ trợ.

Người dùng có thể nhập nội dung tin nhắn và bấm gửi. Ứng dụng gọi API `POST /api/chat` với nội dung tin nhắn. Tin nhắn được gửi đến hệ thống để nhân viên hỗ trợ có thể đọc và trả lời. Ứng dụng có thể sử dụng WebSocket hoặc Socket.io để nhận phản hồi theo thời gian thực (real-time) từ nhân viên. Tin nhắn và phản hồi được lưu vào database.

Nội dung chat có thể bao gồm:

- Hỏi camera nào phù hợp với nhu cầu.
- Hỏi sản phẩm còn hàng không.
- Hỏi chính sách bảo hành, đổi trả.
- Xử lý khiếu nại về đơn hàng, thời gian giao hàng.
- Hỏi chương trình khuyến mãi.
- Tư vấn phụ kiện camera.

Mỗi tin nhắn nên có:

- Nội dung tin nhắn.
- Người gửi (khách hàng hoặc nhân viên hỗ trợ).
- Thời gian gửi.
- Trạng thái gửi thành công.

Lịch sử chat được lưu và có thể tải lại qua API `GET /api/chat/history` khi mở lại màn hình.

### Input

- Nội dung tin nhắn từ khách hàng.
- Thông tin người gửi (user_id).
- Thời gian gửi.

### Output

- Tin nhắn được hiển thị trên màn hình.
- Tin nhắn được lưu vào database.
- Tin nhắn phản hồi từ nhân viên hỗ trợ được cập nhật trên giao diện.
- Lịch sử chat được tải lại khi mở màn hình.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có giao diện chat rõ ràng.
- Có gửi và hiển thị tin nhắn.
- Có lưu và hiển thị lịch sử tin nhắn.
- Có phân biệt tin nhắn của khách hàng và nhân viên hỗ trợ.
- Có hiển thị thời gian gửi.
- Có xử lý trường hợp người dùng gửi tin nhắn rỗng.
- Cập nhật tin nhắn mới theo thời gian thực (nếu có sử dụng socket) hoặc pull to refresh.

---

## Phase 12: User Profile Screen (User)

Chức năng này cho phép khách hàng xem và cập nhật thông tin cá nhân.

### Mục đích

Giúp khách hàng quản lý thông tin tài khoản, cập nhật địa chỉ giao hàng, thay đổi mật khẩu và đăng xuất.

### Mô tả xử lý

Khi người dùng mở màn hình Profile, ứng dụng gọi API `GET /api/auth/profile` và hiển thị thông tin cá nhân gồm:

- Avatar (có thể upload hoặc chọn mặc định).
- Họ và tên.
- Email (không cho phép sửa).
- Số điện thoại.
- Địa chỉ giao hàng mặc định.

Người dùng có thể bấm nút Edit để chỉnh sửa thông tin. Sau khi sửa, bấm Save để gọi API `PUT /api/auth/profile` cập nhật thông tin.

Màn hình Profile cũng nên có:

- Nút đổi mật khẩu.
- Nút xem lịch sử đơn hàng (điều hướng sang Order History).
- Nút đăng xuất (xóa JWT Token và chuyển về màn hình Login).

### Input

- Thông tin cá nhân từ API.
- Thông tin cập nhật từ người dùng.

### Output

- Thông tin cá nhân được hiển thị.
- Thông tin được cập nhật qua API.
- Đăng xuất thành công.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có hiển thị thông tin cá nhân.
- Có chỉnh sửa và lưu thông tin.
- Có kiểm tra dữ liệu khi cập nhật.
- Có chức năng đổi mật khẩu.
- Có chức năng đăng xuất.
- Có giao diện rõ ràng, dễ sử dụng.

---

## Phase 13: Apply State Management – Provider / Bloc

Chức năng này yêu cầu nhóm áp dụng cơ chế quản lý trạng thái trong Flutter, ví dụ Provider hoặc Bloc, để quản lý dữ liệu và trạng thái của ứng dụng.

### Mục đích

Giúp ứng dụng hoạt động ổn định, dễ bảo trì và dễ mở rộng. State management giúp dữ liệu được cập nhật đồng bộ giữa các màn hình, ví dụ khi thêm sản phẩm vào giỏ hàng thì số lượng sản phẩm trong giỏ được cập nhật ngay.

### Mô tả xử lý

Nhóm cần chọn một phương pháp quản lý trạng thái, ví dụ:

- Provider.
- Bloc.
- Cubit.
- Riverpod (nếu được giảng viên chấp nhận).

Đối với project này, nhóm có thể dùng state management cho các phần sau:

| State cần quản lý | Mô tả |
|---|---|
| Authentication State | Quản lý trạng thái đã đăng nhập/chưa đăng nhập, JWT token |
| Product State | Quản lý danh sách sản phẩm, trạng thái loading, lỗi tải dữ liệu |
| Cart State | Quản lý sản phẩm trong giỏ hàng, số lượng, tổng tiền |
| Order State | Quản lý quá trình tạo đơn hàng và trạng thái đặt hàng |
| Notification State | Quản lý danh sách thông báo, số thông báo chưa đọc |
| Chat State | Quản lý danh sách tin nhắn chat, trạng thái gửi/nhận tin nhắn |
| Category State | Quản lý danh sách danh mục/thương hiệu |

Ví dụ: Khi người dùng bấm Add to Cart ở màn hình chi tiết sản phẩm, CartProvider hoặc CartBloc sẽ gọi API thêm vào giỏ hàng, cập nhật danh sách sản phẩm trong giỏ. Màn hình giỏ hàng nhận dữ liệu mới và hiển thị sản phẩm vừa được thêm mà không cần tải lại toàn bộ ứng dụng.

### Input

- Sự kiện từ người dùng: đăng nhập, đăng ký, thêm vào giỏ, xóa sản phẩm, đặt hàng, gửi tin nhắn, thao tác admin.
- Dữ liệu từ REST API backend.
- Trạng thái hiện tại của ứng dụng.

### Output

- UI được cập nhật theo trạng thái mới.
- Dữ liệu giữa các màn hình được đồng bộ.
- Ứng dụng phản hồi đúng khi có loading, error hoặc success.

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có sử dụng Provider hoặc Bloc rõ ràng.
- Không xử lý toàn bộ logic trực tiếp trong UI.
- Có tách logic xử lý ra khỏi màn hình.
- Có cập nhật UI khi dữ liệu thay đổi.
- Có quản lý trạng thái loading, success, error.
- Có áp dụng state management vào các chức năng chính: login, register, product list, cart, checkout, chat.

---

## Phase 14: Coupon / Promo Code (Mã khuyến mãi)

Chức năng này cho phép cửa hàng tạo các mã khuyến mãi để thu hút khách hàng mua camera, và cho phép khách hàng áp dụng mã giảm giá khi thanh toán.

### Mục đích

Tăng doanh số và trải nghiệm mua sắm bằng cách cung cấp ưu đãi giảm giá cho khách hàng thông qua mã khuyến mãi.

### Mô tả xử lý

**Phía Admin:**

Admin có màn hình quản lý mã khuyến mãi, cho phép:

- Tạo mã khuyến mãi mới với các thông tin: mã code (unique), loại giảm (phần trăm hoặc số tiền cố định), giá trị giảm, giá trị đơn hàng tối thiểu để áp dụng, giảm tối đa (nếu loại phần trăm), ngày hết hạn, giới hạn số lượt sử dụng, trạng thái active/inactive.
- Xem danh sách mã khuyến mãi đã tạo (kèm thống kê số lượt đã sử dụng).
- Sửa hoặc vô hiệu hóa mã khuyến mãi.

**Phía User:**

Tại màn hình Checkout, người dùng thấy ô nhập mã khuyến mãi và nút "Áp dụng". Khi nhập mã và bấm áp dụng, ứng dụng gọi API `POST /api/coupons/apply` với mã và tổng tiền đơn hàng.

Backend kiểm tra:

- Mã có tồn tại không.
- Mã có đang active không.
- Mã có hết hạn chưa.
- Mã có hết lượt sử dụng chưa.
- Đơn hàng có đạt giá trị tối thiểu không.

Nếu hợp lệ, backend trả về số tiền giảm. Ứng dụng hiển thị:

- Mã đã áp dụng thành công.
- Tiền giảm giá.
- Tổng tiền sau giảm.

Khi đơn hàng được tạo thành công, hệ thống lưu `couponCode` và `discountAmount` vào Order, đồng thời tăng `usedCount` của coupon.

### Input

- Admin: Thông tin mã khuyến mãi (code, type, value, minOrderAmount, maxDiscount, expiresAt, usageLimit).
- User: Mã khuyến mãi nhập tại Checkout.

### Output

- Admin: Danh sách mã khuyến mãi được quản lý.
- User: Số tiền giảm giá được áp dụng, tổng tiền cập nhật.
- Order: Lưu thông tin coupon đã áp dụng.

### REST API Endpoints

| Method | Endpoint               | Mô tả                    | Role  |
| ------ | ---------------------- | ------------------------- | ----- |
| POST   | `/api/coupons`         | Tạo mã khuyến mãi        | Admin |
| GET    | `/api/coupons`         | Lấy danh sách mã          | Admin |
| PUT    | `/api/coupons/:id`     | Sửa mã khuyến mãi        | Admin |
| POST   | `/api/coupons/apply`   | Áp dụng mã khuyến mãi     | User  |

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có giao diện Admin quản lý coupon (tạo, sửa, xem danh sách).
- Có ô nhập mã khuyến mãi tại Checkout.
- Có validate mã hợp lệ (hết hạn, hết lượt, đơn tối thiểu).
- Có hiển thị tiền giảm và tổng tiền sau giảm.
- Có lưu thông tin coupon vào đơn hàng.
- Có xử lý lỗi khi mã không hợp lệ.

---

## Phase 15: Product Review / Rating (Đánh giá sản phẩm)

Chức năng này cho phép khách hàng đã mua camera đánh giá sản phẩm bằng điểm sao và nhận xét, giúp người mua khác tham khảo.

### Mục đích

Tăng độ tin cậy cho sản phẩm camera thông qua đánh giá thực tế từ người đã mua. Giúp khách hàng tiềm năng đưa ra quyết định mua hàng tốt hơn.

### Mô tả xử lý

**Điều kiện đánh giá:**

Chỉ User đã có đơn hàng ở trạng thái "Delivered" mới được phép đánh giá sản phẩm trong đơn hàng đó. Mỗi sản phẩm trong một đơn hàng chỉ được đánh giá một lần.

**Viết đánh giá:**

Tại màn hình Order Detail, khi đơn hàng ở trạng thái "Delivered", mỗi sản phẩm sẽ có nút "Đánh giá". Khi bấm, ứng dụng mở form/dialog cho phép:

- Chọn số sao (1-5 sao, bắt buộc).
- Viết nhận xét (tùy chọn).

Ứng dụng gọi API `POST /api/reviews` với thông tin product, order, rating và comment. Backend validate quyền và tạo review.

**Hiển thị đánh giá:**

Tại màn hình Product Detail, ứng dụng hiển thị:

- Điểm trung bình (ví dụ: ⭐ 4.8).
- Tổng số lượt đánh giá.
- Danh sách reviews với tên người đánh giá, số sao, nhận xét và ngày đánh giá.

Backend tự động tính lại `averageRating` và `reviewCount` sau mỗi đánh giá mới.

### Input

- Product ID, Order ID (để validate quyền).
- Rating (1-5 sao).
- Comment (tùy chọn).

### Output

- Review được tạo và lưu vào database.
- Product Detail hiển thị rating trung bình và danh sách reviews.
- Nút "Đánh giá" chuyển thành "Đã đánh giá" sau khi review.

### REST API Endpoints

| Method | Endpoint                       | Mô tả                          | Role |
| ------ | ------------------------------ | ------------------------------- | ---- |
| POST   | `/api/reviews`                 | Tạo đánh giá sản phẩm          | User |
| GET    | `/api/products/:id/reviews`    | Lấy danh sách đánh giá sản phẩm | Public |

### Yêu cầu đánh giá

Giảng viên có thể đánh giá chức năng này qua các điểm sau:

- Có kiểm tra quyền đánh giá (chỉ user đã mua, đơn hàng Delivered).
- Có form chọn sao và viết nhận xét.
- Có hiển thị rating trung bình trên Product Detail.
- Có danh sách reviews với tên, sao, nhận xét, ngày.
- Có xử lý đánh giá trùng lặp (mỗi order chỉ review 1 lần).
- Có thông báo phản hồi cho người dùng.

---

## Luồng Demo Chính

### User Flow

> Register → Login → Xem danh sách Camera → Xem chi tiết Camera (xem đánh giá) → Thêm vào giỏ hàng → Cập nhật giỏ hàng → Checkout (nhập mã khuyến mãi) → Tạo đơn hàng → Xem lịch sử đơn hàng → Đánh giá sản phẩm (sau khi Delivered) → Nhận thông báo → Chat với nhân viên hỗ trợ → Xem vị trí cửa hàng → Cập nhật Profile → Đăng xuất.

