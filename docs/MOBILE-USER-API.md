# User API được scaffold

App hiện chỉ có lớp gọi các API thuộc người dùng trong `lib/features/user/data/user_api.dart`.

| Nhóm | API |
|---|---|
| Đăng ký | `POST /api/account/registrations`, `verify`, `resend` |
| Phiên | `POST /api/auth/login`, `POST /api/auth/logout` |
| Khôi phục mật khẩu | `POST /api/account/password-resets`, `verify` |
| Hồ sơ | `GET`, `PUT /api/account/profile` |
| Mật khẩu | `POST /api/account/password` |

`ApiClient` lưu cookie phiên trong bộ nhớ bằng `CookieJar`, nên cookie tự động đi kèm các request khi app đang mở. Base URL mặc định là `http://10.0.2.2:6789` cho Android emulator và `http://127.0.0.1:6789` cho iOS simulator. Khi chạy trên thiết bị thật, truyền `baseUrl` vào `ApiClient.create` với IP/LAN URL của backend.

Khi chạy Web, app không dùng `dio_cookie_manager` vì trình duyệt quản lý cookie và gọi backend mặc định tại `http://localhost:6789`. Backend cần cho phép origin của web app và credentials trong cấu hình CORS để cookie session hoạt động giữa hai cổng khác nhau.

Theo đặc tả backend, response thành công có thể được bọc trong `{ "is_success": true, "data": ... }`; `UserApi` nhận cả dạng bọc và dữ liệu trực tiếp. Lỗi RFC 7807 được đổi thành `ApiException` để UI hiển thị `detail` hoặc `title`.
