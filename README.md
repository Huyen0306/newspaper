# Newspaper App - Documentation

Flutter application với các chức năng đăng nhập, đọc báo, lưu bài viết, và đổi thưởng.

## 📋 Mục lục

- [Chức năng Đăng nhập](#chức-năng-đăng-nhập)
- [Chức năng Đọc Báo (News Screen)](#chức-năng-đọc-báo-news-screen)
- [Chức năng Chi tiết Bài Viết (Post Detail Screen)](#chức-năng-chi-tiết-bài-viết-post-detail-screen)
- [Chức năng Lưu Bài Viết (Saved Screen)](#chức-năng-lưu-bài-viết-saved-screen)
- [Chức năng Đổi Thưởng (Rewards Screen)](#chức-năng-đổi-thưởng-rewards-screen)
- [Chức năng Profile (Profile Screen)](#chức-năng-profile-profile-screen)

---

## 🔐 Chức năng Đăng nhập

### 📍 File Location
- **UI**: `lib/presentation/screens/auth/login_screen.dart`
- **Service**: `lib/data/services/auth_service.dart`
- **API Service**: `lib/data/services/auth_api_service.dart`
- **API Base**: `lib/data/services/api_service.dart`

### 📝 Form Inputs

```
LoginScreen
├── Username Field (TextField)
│   ├── Controller: _usernameController
│   ├── Default value: 'emilys'
│   └── Validation: Required (không được để trống)
│
├── Password Field (TextField)
│   ├── Controller: _passwordController
│   ├── Default value: 'emilyspass'
│   ├── Obscure: true (ẩn mật khẩu)
│   └── Validation: Required (không được để trống)
│
└── Remember Me (Checkbox)
    └── Default: true
```

### 🔄 Flow Diagram (Cây nhị phân)

```
User clicks "Đăng nhập" button
│
├─> Validation Check
│   │
│   ├─> [FAIL] Username hoặc Password trống
│   │   └─> Show SnackBar: "Vui lòng nhập đầy đủ thông tin" (màu đỏ)
│   │   └─> STOP
│   │
│   └─> [PASS] Cả 2 field đều có giá trị
│       │
│       └─> Set _isLoading = true
│           └─> Show loading indicator
│               │
│               └─> Call _authApiService.login()
│                   │
│                   ├─> [SUCCESS] API trả về response
│                   │   │
│                   │   ├─> Extract data:
│                   │   │   ├─> token (accessToken hoặc token)
│                   │   │   ├─> refreshToken
│                   │   │   └─> user (UserModel)
│                   │   │
│                   │   └─> Call _authService.saveAuthData()
│                   │       │
│                   │       ├─> [SUCCESS] Save to SharedPreferences
│                   │       │   ├─> Save token → 'access_token'
│                   │       │   ├─> Save refreshToken → 'refresh_token'
│                   │       │   ├─> Save user (JSON) → 'user_data'
│                   │       │   ├─> Update tokenNotifier.value = token
│                   │       │   ├─> Update userNotifier.value = user
│                   │       │   │
│                   │       │   └─> [SUCCESS] saveAuthData returns true
│                   │       │       │
│                   │       │       └─> if (success && mounted)
│                   │       │           ├─> Show SnackBar: "Đăng nhập thành công!" (màu xanh)
│                   │       │           └─> Navigate to MainScreen (pushReplacement)
│                   │       │
│                   │       └─> [FAIL] Save failed
│                   │           └─> saveAuthData returns false
│                   │           └─> No navigation (user stays on login screen)
│                   │
│                   └─> [FAIL] API throws exception
│                       │
│                       └─> Catch error
│                           └─> Show SnackBar: "Đăng nhập thất bại: {error message}" (màu đỏ)
│
└─> Finally block
    └─> Set _isLoading = false
        └─> Hide loading indicator
```

### 🔗 API Call Details

```
_authApiService.login()
│
├─> Endpoint: POST https://dummyjson.com/auth/login
│
├─> Request Body:
│   {
│     "username": "emilys",
│     "password": "emilyspass",
│     "expiresInMins": 30
│   }
│
└─> Response Structure:
    {
      "user": { ...UserModel data... },
      "accessToken": "string" hoặc "token": "string",
      "refreshToken": "string"
    }
```

### ✅ Kết quả thành công

```
Thành công
│
├─> SnackBar hiển thị: "Đăng nhập thành công!" (màu xanh, 2 giây)
│
├─> Dữ liệu được lưu:
│   ├─> SharedPreferences:
│   │   ├─> 'access_token' = token string
│   │   ├─> 'refresh_token' = refreshToken string
│   │   └─> 'user_data' = user JSON string
│   │
│   └─> ValueNotifiers:
│       ├─> tokenNotifier.value = token
│       └─> userNotifier.value = user object
│
└─> Navigation:
    └─> pushReplacement → MainScreen
        └─> User không thể quay lại LoginScreen bằng back button
```

### ❌ Kết quả lỗi

```
Lỗi
│
├─> Validation Error (trước khi gọi API)
│   └─> SnackBar: "Vui lòng nhập đầy đủ thông tin" (màu đỏ)
│   └─> _isLoading = false
│   └─> User vẫn ở LoginScreen
│
├─> API Error (khi gọi API)
│   ├─> Connection Timeout
│   │   └─> SnackBar: "Kết nối timeout. Vui lòng thử lại."
│   │
│   ├─> 400 Bad Request
│   │   └─> SnackBar: "Yêu cầu không hợp lệ"
│   │
│   ├─> 401 Unauthorized
│   │   └─> SnackBar: "Không có quyền truy cập"
│   │
│   ├─> 404 Not Found
│   │   └─> SnackBar: "Không tìm thấy dữ liệu"
│   │
│   ├─> 500 Server Error
│   │   └─> SnackBar: "Lỗi máy chủ"
│   │
│   ├─> No Internet
│   │   └─> SnackBar: "Không có kết nối internet"
│   │
│   └─> Other errors
│       └─> SnackBar: "Đăng nhập thất bại: {error.toString()}"
│
└─> Save Error (sau khi API thành công nhưng save thất bại)
    └─> saveAuthData returns false
    └─> No SnackBar, no navigation
    └─> User vẫn ở LoginScreen
```

### 🎨 UI Components

```
LoginScreen UI
│
├─> Header
│   ├─> Title: "Đăng nhập" (32px, bold, đen)
│   └─> Subtitle: "Chào mừng trở lại, chúng tôi rất nhớ bạn" (16px, xám)
│
├─> Form Fields
│   ├─> Username Field
│   │   ├─> Label: "Tên đăng nhập"
│   │   ├─> Input: TextField với border radius 12
│   │   └─> Focus border: Color(0xFF1e293b), width 1.5
│   │
│   └─> Password Field
│       ├─> Label: "Mật khẩu"
│       ├─> Input: TextField với obscureText
│       ├─> Suffix Icon: Eye/Eye-slash để toggle visibility
│       └─> Focus border: Color(0xFF1e293b), width 1.5
│
├─> Options Row
│   ├─> Checkbox: "Ghi nhớ đăng nhập" (màu Color(0xFF1e293b))
│   └─> Text: "Quên mật khẩu?" (màu Color(0xFF1e293b), clickable)
│       └─> Click → Show SnackBar: "Chức năng quên mật khẩu chưa được thực hiện"
│
├─> Login Button
│   ├─> Background: Color(0xFF1e293b)
│   ├─> Text: "Đăng nhập" (17px, bold, trắng)
│   ├─> Loading state: CircularProgressIndicator (trắng)
│   └─> Disabled khi _isLoading = true
│
└─> Footer
    ├─> Demo info: "Demo: emilys / emilyspass"
    └─> Sign up link: "Chưa có tài khoản? Đăng ký"
        └─> Click → Show SnackBar: "Chức năng đăng ký chưa được thực hiện"
```

### 📦 Data Storage

```
SharedPreferences Keys:
│
├─> 'access_token'
│   └─> Type: String
│   └─> Value: JWT token từ API
│
├─> 'refresh_token'
│   └─> Type: String
│   └─> Value: Refresh token từ API
│
└─> 'user_data'
    └─> Type: String (JSON)
    └─> Value: UserModel.toJson() encoded
```

### 🔔 ValueNotifiers (Reactive State)

```
AuthService Notifiers:
│
├─> tokenNotifier: ValueNotifier<String?>
│   └─> Notify khi token thay đổi
│   └─> Listeners: ProfileScreen, các screen cần token
│
└─> userNotifier: ValueNotifier<UserModel?>
    └─> Notify khi user data thay đổi
    └─> Listeners: ProfileScreen
```

---

## 📰 Chức năng Đọc Báo (News Screen)

### 📍 File Location
- **UI**: `lib/presentation/screens/news/news_screen.dart`
- **Service**: `lib/data/services/post_service.dart`
- **API Service**: `lib/data/services/api_service.dart`
- **API Config**: `lib/core/network/api_config.dart`

### 📝 Form Inputs

```
NewsScreen
└── Không có form input
    └── Chỉ hiển thị danh sách bài viết
```

### 🔄 Flow Diagram (Cây nhị phân)

```
NewsScreen initState()
│
├─> Load Posts (_loadPosts)
│   │
│   └─> Call _postService.getPosts(limit: 30)
│       │
│       ├─> [SUCCESS] API trả về danh sách posts
│       │   │
│       │   └─> Update state:
│       │       ├─> _posts = response.posts
│       │       └─> _isLoading = false
│       │
│       └─> [FAIL] API throws exception
│           │
│           └─> Update state:
│               ├─> _errorMessage = error.toString()
│               └─> _isLoading = false
│
├─> Load Saved Post IDs (_loadSavedPostIds)
│   │
│   └─> Call _savedPostsService.getSavedPosts()
│       │
│       └─> Update _savedPostIds = Set of saved post IDs
│
└─> Listen to savedPostsNotifier
    └─> Auto update _savedPostIds khi có thay đổi

User clicks on Post Card
│
└─> Navigate to PostDetailScreen
    ├─> Pass post data
    ├─> Pass heroTagPrefix: 'news'
    └─> Use smooth page transition

User clicks Bookmark icon on Post Card
│
└─> Call _toggleSave()
    │
    ├─> [If _isSaved = true]
    │   └─> Call _savedPostsService.removePost(post.id)
    │       │
    │       └─> Update local state: _isSaved = false
    │
    └─> [If _isSaved = false]
        └─> Call _savedPostsService.savePost(post)
            │
            └─> Update local state: _isSaved = true

User pulls to refresh
│
└─> Call _loadPosts(forceRefresh: true)
    └─> Force reload posts từ API
```

### 🔗 API Call Details

```
_postService.getPosts(limit: 30)
│
├─> Endpoint: GET https://dummyjson.com/posts?limit=30
│
└─> Response Structure:
    {
      "posts": [PostModel, PostModel, ...],
      "total": 150,
      "skip": 0,
      "limit": 30
    }
```

### ✅ Kết quả thành công

```
Thành công
│
├─> Hiển thị danh sách posts:
│   ├─> ListView với RefreshIndicator
│   ├─> Mỗi post card hiển thị:
│   │   ├─> Hero image (200px height)
│   │   ├─> Title (18px, bold, max 2 lines)
│   │   ├─> Body preview (truncate 160 chars, max 3 lines)
│   │   ├─> Tags (tối đa 3 tags đầu tiên)
│   │   ├─> Reactions count (heart icon)
│   │   ├─> User ID
│   │   ├─> Author name
│   │   ├─> Date
│   │   └─> Bookmark button (blue nếu đã lưu, gray nếu chưa)
│   │
│   └─> Pull to refresh enabled
│
└─> Saved post IDs được sync tự động qua notifier
```

### ❌ Kết quả lỗi

```
Lỗi
│
├─> Loading Error
│   └─> Hiển thị error screen:
│       ├─> Icon: Danger icon (đỏ)
│       ├─> Title: "Đã xảy ra lỗi"
│       ├─> Message: Error message
│       └─> Button: "Thử lại" (màu blue)
│           └─> Click → Call _loadPosts()
│
└─> Empty State
    └─> Hiển thị empty screen:
        ├─> Icon: Document icon (xám nhạt)
        └─> Text: "Không có bài viết nào"
```

---

## 📄 Chức năng Chi tiết Bài Viết (Post Detail Screen)

### 📍 File Location
- **UI**: `lib/presentation/screens/news/post_detail_screen.dart`
- **Widget**: `lib/presentation/widgets/floating_reward_badge.dart`
- **Service**: `lib/data/services/saved_posts_service.dart`
- **Service**: `lib/data/services/task_service.dart`
- **Service**: `lib/data/services/points_service.dart`

### 📝 Form Inputs

```
PostDetailScreen
└── Không có form input
    └── Chỉ hiển thị chi tiết bài viết
```

### 🔄 Flow Diagram (Cây nhị phân)

```
PostDetailScreen initState()
│
├─> Check if post is saved (_checkIfSaved)
│   │
│   └─> Check savedPostsNotifier.value
│       │
│       └─> Set _isSaved = true/false
│
└─> Listen to savedPostsNotifier
    └─> Auto update _isSaved khi có thay đổi

User clicks Bookmark icon in AppBar
│
└─> Call _toggleSave()
    │
    ├─> [Prevent multiple clicks]
    │   └─> if (_isToggling) return
    │
    ├─> Set _isToggling = true
    │
    ├─> [If _isSaved = true]
    │   └─> Call _savedPostsService.removePost(post.id)
    │       │
    │       ├─> [SUCCESS]
    │       │   └─> Update state: _isSaved = false, _isToggling = false
    │       │
    │       └─> [FAIL]
    │           └─> Update state: _isToggling = false
    │
    └─> [If _isSaved = false]
        └─> Call _savedPostsService.savePost(post)
            │
            ├─> [SUCCESS]
            │   └─> Update state: _isSaved = true, _isToggling = false
            │
            └─> [FAIL]
                └─> Update state: _isToggling = false

FloatingRewardBadge appears (auto start)
│
├─> Reset task: _taskService.resetTask()
│
├─> Start animations:
│   ├─> _appearController.forward() (350ms)
│   └─> _progressController.forward() (5 seconds)
│
└─> Progress countdown: 5s → 4s → 3s → 2s → 1s → 0s
    │
    └─> When progress completes
        │
        └─> Call _handleCompletion()
            │
            ├─> Update task: _taskService.updateReadTime(5)
            │
            ├─> Add points: _pointsService.addPoints(100)
            │
            ├─> Play sound: success.mp3
            │
            ├─> Play confetti animation
            │
            ├─> Hide badge (reverse animation)
            │
            └─> Show SnackBar: "Chúc mừng! Bạn nhận được 100 điểm"
```

### 🔗 API Call Details

```
Không có API call trực tiếp
│
└─> Post data được truyền từ screen trước
    └─> Chỉ sử dụng local services:
        ├─> SavedPostsService (lưu/xóa bài viết)
        ├─> TaskService (quản lý task đọc bài)
        └─> PointsService (cộng điểm)
```

### ✅ Kết quả thành công

```
Thành công
│
├─> Hiển thị chi tiết bài viết:
│   ├─> Hero image (250px height, với hero animation)
│   ├─> Title (22px, bold)
│   ├─> Author & Date row
│   ├─> Body content (16px, full text)
│   ├─> Tags section (nếu có)
│   └─> Footer: Reactions count & User ID
│
├─> Bookmark functionality:
│   ├─> Icon màu blue nếu đã lưu
│   ├─> Icon màu gray nếu chưa lưu
│   └─> Toggle state được sync với SavedPostsService
│
└─> Floating Reward Badge:
    ├─> Hiển thị countdown 5 giây
    ├─> Khi hoàn thành:
    │   ├─> Pháo hoa animation
    │   ├─> Âm thanh success
    │   ├─> Cộng 100 điểm
    │   └─> SnackBar thông báo
    └─> Badge tự ẩn sau khi hoàn thành
```

### ❌ Kết quả lỗi

```
Lỗi
│
└─> Image Load Error
    └─> Hiển thị placeholder:
        ├─> Background: Color(0xFFF2F2F7)
        └─> Icon: Image icon (xám)
```

---

## 💾 Chức năng Lưu Bài Viết (Saved Screen)

### 📍 File Location
- **UI**: `lib/presentation/screens/saved/saved_screen.dart`
- **Service**: `lib/data/services/saved_posts_service.dart`

### 📝 Form Inputs

```
SavedScreen
└── Không có form input
    └── Chỉ hiển thị danh sách bài viết đã lưu
```

### 🔄 Flow Diagram (Cây nhị phân)

```
SavedScreen initState()
│
├─> Check savedPostsNotifier.value
│   │
│   ├─> [If not empty]
│   │   └─> Set _savedPosts = currentPosts
│   │       └─> Set _isLoading = false
│   │
│   └─> [If empty]
│       └─> Call _loadSavedPosts()
│
└─> Listen to savedPostsNotifier
    └─> Auto update _savedPosts khi có thay đổi

_loadSavedPosts()
│
└─> Call _savedPostsService.getSavedPosts()
    │
    ├─> [SUCCESS]
    │   └─> Update state:
    │       ├─> _savedPosts = posts
    │       └─> _isLoading = false
    │
    └─> [FAIL]
        └─> Return empty list

User clicks on Post Card
│
└─> Navigate to PostDetailScreen
    ├─> Pass post data
    ├─> Pass heroTagPrefix: 'saved'
    └─> Use smooth page transition

User clicks Trash icon on Post Card
│
└─> Call _removePost(postId)
    │
    └─> Call _savedPostsService.removePost(postId)
        │
        └─> Reload saved posts (_loadSavedPosts)
            │
            └─> UI tự động update qua notifier

User pulls to refresh
│
└─> Call _loadSavedPosts(forceRefresh: true)
    └─> Force reload từ SharedPreferences
```

### 🔗 API Call Details

```
Không có API call
│
└─> Chỉ đọc từ SharedPreferences
    └─> Key: 'saved_posts'
        └─> Value: JSON array of PostModel
```

### ✅ Kết quả thành công

```
Thành công
│
├─> Hiển thị danh sách bài viết đã lưu:
│   ├─> ListView với RefreshIndicator
│   ├─> Mỗi post card hiển thị:
│   │   ├─> Hero image (200px height)
│   │   ├─> Title (18px, bold, max 2 lines)
│   │   ├─> Body preview (truncate 160 chars, max 3 lines)
│   │   ├─> Tags (tối đa 3 tags đầu tiên)
│   │   ├─> Reactions count
│   │   ├─> User ID
│   │   ├─> Author name
│   │   ├─> Date
│   │   └─> Trash button (đỏ) để xóa
│   │
│   └─> Pull to refresh enabled
│
└─> Auto sync với SavedPostsService notifier
```

### ❌ Kết quả lỗi

```
Lỗi
│
└─> Empty State
    └─> Hiển thị empty screen:
        ├─> Icon: Bookmark icon (xám nhạt, 64px)
        └─> Text: "Chưa có bài viết nào được lưu"
```

### 📦 Data Storage

```
SharedPreferences:
│
└─> Key: 'saved_posts'
    └─> Type: String (JSON)
    └─> Value: JSON array of PostModel
        └─> Format: [{"id": 1, "title": "...", ...}, ...]
```

### 🔔 ValueNotifiers

```
SavedPostsService:
│
└─> savedPostsNotifier: ValueNotifier<List<PostModel>>
    └─> Notify khi danh sách saved posts thay đổi
    └─> Listeners: NewsScreen, SavedScreen, PostDetailScreen
```

---

## 🎁 Chức năng Đổi Thưởng (Rewards Screen)

### 📍 File Location
- **UI**: `lib/presentation/screens/rewards/rewards_screen.dart`
- **Service**: `lib/data/services/points_service.dart`
- **Model**: `lib/data/models/reward_model.dart`

### 📝 Form Inputs

```
RewardsScreen
└── Không có form input
    └── Hiển thị danh sách phần thưởng có sẵn
        └── Mỗi reward card có button "Đổi thưởng"
```

### 🔄 Flow Diagram (Cây nhị phân)

```
RewardsScreen initState()
│
├─> Initialize ConfettiController
│
├─> Load current points (_loadData)
│   │
│   └─> Call _pointsService.getPoints()
│       │
│       └─> Update state:
│           ├─> _currentPoints = points
│           └─> _isLoading = false
│
└─> Listen to pointsNotifier
    └─> Auto update _currentPoints khi có thay đổi

User clicks "Đổi thưởng" button
│
└─> Call _redeemReward(reward)
    │
    ├─> Check points validation
    │   │
    │   ├─> [FAIL] _currentPoints < reward.pointsRequired
    │   │   └─> Show SnackBar: "Bạn cần {thiếu} điểm nữa..." (màu đỏ)
    │   │   └─> STOP
    │   │
    │   └─> [PASS] Đủ điểm
    │       │
    │       └─> Show confirmation dialog
    │           │
    │           ├─> [User clicks "Hủy"]
    │           │   └─> Dialog closes, no action
    │           │
    │           └─> [User clicks "Xác nhận"]
    │               │
    │               └─> Call _pointsService.addPoints(-reward.pointsRequired)
    │                   │
    │                   ├─> [SUCCESS]
    │                   │   │
    │                   │   ├─> Reset confetti: _confettiController.stop()
    │                   │   │
    │                   │   ├─> Play confetti: _confettiController.play()
    │                   │   │
    │                   │   ├─> Play sound: success.mp3
    │                   │   │
    │                   │   └─> Show SnackBar: "Đã đổi thành công: {reward.title}" (màu xanh)
    │                   │
    │                   └─> [FAIL]
    │                       └─> No action (points không được trừ)
```

### 🔗 API Call Details

```
Không có API call
│
└─> Chỉ sử dụng local PointsService
    └─> Lưu trữ trong SharedPreferences
        └─> Key: 'user_points'
```

### ✅ Kết quả thành công

```
Thành công
│
├─> Points được trừ:
│   ├─> _currentPoints -= reward.pointsRequired
│   ├─> Lưu vào SharedPreferences
│   └─> pointsNotifier.value được update
│
├─> Hiệu ứng:
│   ├─> Pháo hoa animation (ConfettiWidget)
│   ├─> Âm thanh success.mp3
│   └─> SnackBar: "Đã đổi thành công: {reward.title}" (màu xanh)
│
└─> UI update:
    └─> Button "Đổi thưởng" có thể chuyển sang disabled state
        └─> Nếu điểm còn lại < pointsRequired của reward khác
```

### ❌ Kết quả lỗi

```
Lỗi
│
├─> Validation Error (không đủ điểm)
│   └─> SnackBar: "Bạn cần {thiếu} điểm nữa để đổi phần thưởng này" (màu đỏ)
│   └─> Button vẫn hiển thị nhưng không thể click (canRedeem = false)
│
└─> Save Error (sau khi confirm nhưng trừ điểm thất bại)
    └─> addPoints returns false
    └─> No confetti, no sound, no SnackBar
    └─> Points không bị trừ
```

### 🎨 UI Components

```
RewardsScreen UI
│
├─> Header
│   └─> AppBar: "Đổi thưởng"
│
├─> Rewards List
│   └─> ListView với RefreshIndicator
│       │
│       └─> Reward Cards:
│           ├─> Image: Product image (200px height, BoxFit.cover)
│           ├─> Title: Reward title (18px, bold)
│           ├─> Description: Reward description (14px, xám)
│           ├─> Points: Star icon + "{points} điểm"
│           │   └─> Nếu không đủ: Hiển thị "(Thiếu {thiếu} điểm)" (màu đỏ)
│           │
│           └─> Button "Đổi thưởng"
│               ├─> [Đủ điểm]
│               │   ├─> Background: Color(0xFF1e293b) (đậm)
│               │   ├─> Text: Trắng
│               │   └─> Clickable
│               │
│               └─> [Không đủ điểm]
│                   ├─> Background: Color(0xFF1e293b).withOpacity(0.3) (nhạt)
│                   ├─> Text: Trắng với opacity 0.5
│                   └─> Not clickable
│
└─> Confetti Widget
    └─> Hiển thị pháo hoa khi đổi thưởng thành công
```

### 📦 Data Storage

```
SharedPreferences:
│
└─> Key: 'user_points'
    └─> Type: int
    └─> Value: Số điểm hiện tại của user
```

### 🔔 ValueNotifiers

```
PointsService:
│
└─> pointsNotifier: ValueNotifier<int>
    └─> Notify khi số điểm thay đổi
    └─> Listeners: RewardsScreen, FloatingRewardBadge
```

### 🎁 Sample Rewards Data

```
Rewards List (hardcoded):
│
├─> AirPods Pro (500 điểm)
├─> iPhone 15 (2000 điểm)
├─> MacBook Air M2 (3000 điểm)
├─> iPad Pro (2500 điểm)
├─> Apple Watch Series 9 (1500 điểm)
└─> Magic Keyboard (800 điểm)
```

---

## 👤 Chức năng Profile (Profile Screen)

### 📍 File Location
- **UI**: `lib/presentation/screens/profile/profile_screen.dart`
- **Service**: `lib/data/services/auth_service.dart`
- **API Service**: `lib/data/services/auth_api_service.dart`

### 📝 Form Inputs

```
ProfileScreen
└── Không có form input
    └── Chỉ hiển thị thông tin user và các action buttons
```

### 🔄 Flow Diagram (Cây nhị phân)

```
ProfileScreen initState()
│
├─> Load user data (_loadUser)
│   │
│   └─> Call _authService.getUser()
│       │
│       ├─> [SUCCESS] User exists
│       │   └─> Update state:
│       │       ├─> _user = user
│       │       └─> _isLoading = false
│       │
│       └─> [FAIL] User is null
│           └─> Update state:
│               ├─> _user = null
│               └─> _isLoading = false
│
└─> Listen to userNotifier
    └─> Auto update _user khi có thay đổi

User clicks "Đăng xuất" button
│
└─> Call _logout()
    │
    └─> Show confirmation dialog
        │
        ├─> [User clicks "Hủy"]
        │   └─> Dialog closes, no action
        │
        └─> [User clicks "Đăng xuất"]
            │
            └─> Call _authService.logout()
                │
                ├─> Clear SharedPreferences:
                │   ├─> Remove 'access_token'
                │   ├─> Remove 'refresh_token'
                │   └─> Remove 'user_data'
                │
                ├─> Update notifiers:
                │   ├─> tokenNotifier.value = null
                │   └─> userNotifier.value = null
                │
                └─> Navigate to LoginScreen (pushAndRemoveUntil)
                    └─> Clear navigation stack

User clicks "Refresh Token" button
│
└─> Call _refreshToken()
    │
    ├─> Set _isRefreshing = true
    │
    ├─> Get refreshToken từ _authService.getRefreshToken()
    │   │
    │   ├─> [FAIL] refreshToken is null
    │   │   └─> Throw exception: "Không có refresh token"
    │   │
    │   └─> [PASS] refreshToken exists
    │       │
    │       └─> Call _authApiService.refreshToken(refreshToken)
    │           │
    │           ├─> [SUCCESS] API trả về new tokens
    │           │   │
    │           │   └─> Call _authService.updateToken()
    │           │       │
    │           │       ├─> [SUCCESS]
    │           │       │   ├─> Save new token → SharedPreferences
    │           │       │   ├─> Save new refreshToken → SharedPreferences
    │           │       │   ├─> Update tokenNotifier.value
    │           │       │   │
    │           │       │   └─> Show SnackBar: "Đã làm mới token thành công!" (màu xanh)
    │           │       │
    │           │       └─> [FAIL]
    │           │           └─> No action
    │           │
    │           └─> [FAIL] API throws exception
    │               │
    │               └─> Show SnackBar: "Làm mới thất bại: Phiên đăng nhập có thể đã hết hạn" (màu đỏ)
    │                   │
    │                   └─> Auto call _logout()
    │
    └─> Finally block
        └─> Set _isRefreshing = false
```

### 🔗 API Call Details

```
_authApiService.refreshToken()
│
├─> Endpoint: POST https://dummyjson.com/auth/refresh
│
├─> Request Body:
│   {
│     "refreshToken": "string",
│     "expiresInMins": 30
│   }
│
└─> Response Structure:
    {
      "accessToken": "string" hoặc "token": "string",
      "refreshToken": "string"
    }
```

### ✅ Kết quả thành công

```
Thành công
│
├─> Hiển thị thông tin user:
│   ├─> Avatar: User image hoặc gradient circle với icon
│   ├─> Full name (24px, bold)
│   ├─> Email (15px, xám)
│   │
│   └─> Info cards:
│       ├─> HỌ VÀ TÊN
│       ├─> EMAIL
│       ├─> GIỚI TÍNH
│       └─> TÊN ĐĂNG NHẬP
│
├─> Action buttons:
│   ├─> "Đăng xuất" (màu đỏ nhạt)
│   └─> "Refresh Token" (outlined button)
│
└─> Refresh Token Success:
    └─> SnackBar: "Đã làm mới token thành công!" (màu xanh)
```

### ❌ Kết quả lỗi

```
Lỗi
│
├─> Not Logged In
│   └─> Hiển thị empty state:
│       ├─> Icon: Profile circle (xám, 64px)
│       ├─> Text: "Chưa đăng nhập"
│       └─> Button: "Đăng nhập"
│           └─> Click → Navigate to LoginScreen
│
├─> Refresh Token Error
│   ├─> No refresh token
│   │   └─> Exception: "Không có refresh token"
│   │
│   ├─> API Error
│   │   └─> SnackBar: "Làm mới thất bại: Phiên đăng nhập có thể đã hết hạn" (màu đỏ)
│   │       └─> Auto logout → Navigate to LoginScreen
│   │
│   └─> Update Token Error
│       └─> No SnackBar, token không được update
```

### 🎨 UI Components

```
ProfileScreen UI
│
├─> Header
│   └─> AppBar: "Profile"
│
├─> Avatar Section (nếu đã đăng nhập)
│   ├─> Avatar: 100x100 circle
│   │   ├─> User image (nếu có và hợp lệ)
│   │   └─> Gradient circle với icon (nếu không có image)
│   ├─> Full name (24px, bold, đen)
│   └─> Email (15px, xám)
│
├─> Action Buttons Row
│   ├─> "Đăng xuất" button
│   │   ├─> Background: Red với opacity 0.1
│   │   ├─> Text: Red
│   │   └─> Click → Show logout confirmation dialog
│   │
│   └─> "Refresh Token" button
│       ├─> Outlined button
│       ├─> Icon: Refresh icon
│       ├─> Loading state: CircularProgressIndicator (khi _isRefreshing)
│       └─> Disabled khi _isRefreshing = true
│
└─> Info Cards
    ├─> Card: HỌ VÀ TÊN
    ├─> Card: EMAIL
    ├─> Card: GIỚI TÍNH
    └─> Card: TÊN ĐĂNG NHẬP
        └─> Mỗi card có:
            ├─> Icon (màu blue)
            ├─> Title (12px, blue, uppercase)
            └─> Value (16px, bold, đen)
```

---

## 📝 Notes

### 🛠️ Technical Stack

- **Framework**: Flutter
- **State Management**: ValueNotifiers (reactive state)
- **Local Storage**: SharedPreferences
- **API**: Dio (HTTP client)
- **API Base URL**: `https://dummyjson.com`
- **Animations**: Confetti (pháo hoa), Hero animations
- **Audio**: audioplayers package

### 🎨 Design Patterns

- **Singleton Pattern**: Tất cả services (AuthService, PointsService, SavedPostsService, TaskService)
- **Observer Pattern**: ValueNotifiers để notify state changes
- **Repository Pattern**: Services layer tách biệt business logic

### 📦 Data Storage Keys

```
SharedPreferences Keys:
│
├─> 'access_token' → JWT token
├─> 'refresh_token' → Refresh token
├─> 'user_data' → User JSON string
├─> 'saved_posts' → Saved posts JSON array
├─> 'user_points' → Points integer
├─> 'read_article_task_completed' → Boolean
└─> 'read_article_task_time' → Integer (seconds)
```

### 🔔 ValueNotifiers Summary

```
Reactive State Management:
│
├─> AuthService
│   ├─> tokenNotifier: ValueNotifier<String?>
│   └─> userNotifier: ValueNotifier<UserModel?>
│
├─> PointsService
│   └─> pointsNotifier: ValueNotifier<int>
│
├─> SavedPostsService
│   └─> savedPostsNotifier: ValueNotifier<List<PostModel>>
│
└─> TaskService
    └─> taskCompletedNotifier: ValueNotifier<bool>
```

### 🎯 Common Features

- **Error Handling**: Tất cả các chức năng đều có try-catch và error states
- **Loading States**: CupertinoActivityIndicator hoặc CircularProgressIndicator
- **Empty States**: Hiển thị icon và message khi không có dữ liệu
- **Pull to Refresh**: RefreshIndicator trên các list screens
- **SnackBar Notifications**: Floating SnackBar với màu sắc phù hợp (xanh = success, đỏ = error)
- **Hero Animations**: Smooth transitions giữa screens
- **AutomaticKeepAliveClientMixin**: Giữ state khi switch tabs

### 🎁 Reward System

- **Task**: Đọc bài viết 5 giây → Nhận 100 điểm
- **Rewards**: 6 phần thưởng với điểm yêu cầu khác nhau
- **Confetti & Sound**: Hiệu ứng khi hoàn thành task hoặc đổi thưởng thành công
