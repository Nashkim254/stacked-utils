# app_kit

A repository of production-ready utilities, widgets, theming, and Stacked base classes for Flutter teams. One import eliminates the boilerplate that repeats across every Stacked project.

```dart
import 'package:app_kit/app_kit.dart';
```

---

## Table of Contents

1. [Installation](#installation)
2. [Package Structure](#package-structure)
3. [Core](#core)
   - [Result](#result)
   - [Validators](#validators)
   - [Debouncer & Throttler](#debouncer--throttler)
   - [ViewModelX Extension](#viewmodelx-extension)
   - [CommonViewModel Mixin](#commonviewmodel-mixin)
   - [PaginationMixin](#paginationmixin)
   - [Locator Helper](#locator-helper)
   - [BaseApiService](#baseapiservice)
   - [StorageService](#storageservice)
   - [ConnectivityService](#connectivityservice)
4. [Core — Extensions](#core--extensions)
   - [StringX](#stringx)
   - [DateTimeX](#datetimex)
   - [NumX / IntX](#numx--intx)
4. [UI — Constants](#ui--constants)
   - [AppColors](#appcolors)
   - [AppSpacing](#appspacing)
   - [AppRadius](#appradius)
   - [AppTextStyles](#apptextstyles)
5. [UI — Theme](#ui--theme)
   - [AppTheme](#apptheme)
6. [UI — Extensions](#ui--extensions)
   - [ContextX](#contextx)
   - [WidgetX](#widgetx)
   - [TextStyleX](#textstylex)
   - [Responsive](#responsive)
7. [UI — Shared Widgets](#ui--shared-widgets)
   - [Gap](#gap)
   - [ShowIf](#showif)
   - [BusyOverlay](#busyoverlay)
   - [EmptyState](#emptystate)
   - [ErrorView](#errorview)
   - [ShimmerBox](#shimmerbox)
   - [AppTextField](#apptextfield)
   - [AppSearchField](#appsearchfield)
   - [AppDropdown](#appdropdown)
   - [AppButton](#appbutton)
   - [AppIconButton](#appicOnbutton)
   - [AppCard](#appcard)
   - [AppListTile](#applisttile)
   - [AppNetworkImage](#appnetworkimage)
   - [AppBadge](#appbadge)
   - [AppAvatar](#appavatar)
   - [AppDivider](#appdivider)
   - [AppBottomSheet](#appbottomsheet)
   - [StatusChip](#statuschip)

---

## Installation

Add `app_kit` as a path dependency (local) or a git dependency:

```yaml
# pubspec.yaml of your app
dependencies:
  app_kit:
    path: ../utils          # local monorepo path
    # OR
    git:
      url: https://github.com/your-org/utils.git
```

Recommended font: **Inter**. Add it to your app's `pubspec.yaml` and `assets/fonts/`:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf    weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf  weight: 600
        - asset: assets/fonts/Inter-Bold.ttf      weight: 700
        - asset: assets/fonts/Inter-ExtraBold.ttf weight: 800
```

---

## Package Structure

```
lib/
├── app_kit.dart                    ← single barrel export
├── core/
│   ├── extensions/
│   │   ├── locator_helper.dart     ← locate<T>() shorthand
│   │   └── viewmodel_extensions.dart
│   ├── mixins/
│   │   └── common_viewmodel_mixin.dart
│   ├── services/
│   │   ├── base_api_service.dart
│   │   └── storage_service.dart
│   └── utils/
│       ├── result.dart
│       └── validators.dart
└── ui/
    ├── constants/
    │   ├── app_colors.dart
    │   ├── app_radius.dart
    │   ├── app_spacing.dart
    │   └── app_text_styles.dart
    ├── shared/
    │   ├── app_avatar.dart
    │   ├── app_badge.dart
    │   ├── app_bottom_sheet.dart
    │   ├── app_button.dart
    │   ├── app_card.dart
    │   ├── app_divider.dart
    │   ├── app_icon_button.dart
    │   ├── app_text_field.dart
    │   ├── busy_overlay.dart
    │   ├── empty_state.dart
    │   ├── error_view.dart
    │   ├── gap.dart
    │   ├── shimmer_box.dart
    │   ├── show_if.dart
    │   └── status_chip.dart
    ├── theme/
    │   └── app_theme.dart
    └── utils/
        ├── context_extensions.dart
        ├── responsive.dart
        ├── text_style_extensions.dart
        └── widget_extensions.dart
```

---

## Core

### Result

`lib/core/utils/result.dart`

A discriminated union that wraps service call outcomes. ViewModels receive `Result<T>` instead of catching raw exceptions.

```dart
// In a service
Future<Result<User>> getUser(String id) async {
  return safeCall(
    () => dio.get('/users/$id'),
    User.fromJson,
  );
}

// In a ViewModel
final result = await _userService.getUser(id);
result.when(
  onSuccess: (user) => _user = user,
  onFailure: (err)  => setError(err),
);

// Transform without touching the error path
final Result<String> nameResult = result.map((u) => u?.name ?? '');
```

```dart
// Chain two operations — failure short-circuits
final result = await getUser(id)
    .andThen((user) => getOrders(user!.id));

// Transform error messages
final result = await getUser(id)
    .mapError((e) => 'Could not load user: $e');
```

| Member | Description |
|---|---|
| `Result.success(data)` | Wraps a successful value |
| `Result.failure(error)` | Wraps an error string |
| `isSuccess` / `isFailure` | Boolean checks |
| `when(onSuccess, onFailure)` | Pattern-match the result |
| `fold(onSuccess, onFailure)` | Positional alias for `when` |
| `map(transform)` | Transform the success value |
| `mapError(transform)` | Transform the error message |
| `getOrNull()` | Returns data or `null` |
| `getOrElse(fallback)` | Returns data or a fallback value |
| `getOrThrow()` | Returns data or throws `StateError` |
| `andThen(next)` | Chains async `Result`-returning operations |

---

### Debouncer & Throttler

`lib/core/utils/debouncer.dart`

```dart
// In a widget or ViewModel — declare once, dispose on cleanup
final _debounce = Debouncer(delay: Duration(milliseconds: 500));
final _throttle = Throttler(interval: Duration(seconds: 1));

void onSearchChanged(String query) {
  _debounce(() => viewModel.search(query));  // waits 500 ms after last keystroke
}

void onSubmitTap() {
  _throttle(() => viewModel.submit());       // fires once per second max
}

@override
void dispose() {
  _debounce.dispose();
  _throttle.dispose();
  super.dispose();
}
```

---

### Validators

`lib/core/utils/validators.dart`

Static validators compatible with `TextFormField.validator`.

```dart
AppTextField(
  label: 'Email',
  validator: Validators.email,
)

AppTextField(
  label: 'Password',
  validator: Validators.compose([
    Validators.required,
    (v) => Validators.minLength(v, 8),
  ]),
)
```

| Method | Signature | Description |
|---|---|---|
| `required` | `(String? v)` | Non-empty check |
| `email` | `(String? v)` | Valid email format |
| `phone` | `(String? v)` | ≥10 digit phone |
| `minLength` | `(String? v, int min)` | Minimum length |
| `maxLength` | `(String? v, int max)` | Maximum length |
| `password` | `(String? v)` | ≥8 characters |
| `confirmPassword` | `(String? v, String? original)` | Match check |
| `numeric` | `(String? v)` | Parseable number |
| `url` | `(String? v)` | Valid URI |
| `compose` | `(List<validator>)` | Chains validators, returns first error |

---

### ViewModelX Extension

`lib/core/extensions/viewmodel_extensions.dart`

Extends `BaseViewModel` with a `runWithError` wrapper.

```dart
class LoginViewModel extends BaseViewModel {
  Future<void> login() => runWithError(
    () => _authService.signIn(email, password),
    fallbackMessage: 'Login failed. Please try again.',
  );

  // Scope busy state to a specific key
  Future<void> refreshToken() => runWithError(
    () => _authService.refresh(),
    busyKey: 'refresh',
  );
}
```

| Member | Description |
|---|---|
| `runWithError(fn, {fallbackMessage, busyKey})` | Runs async fn with busy + error management |
| `hasError` | True when `modelError != null` |
| `clearError()` | Clears the current error |

---

### PaginationMixin

`lib/core/mixins/pagination_mixin.dart`

```dart
class PostsViewModel extends BaseViewModel with PaginationMixin {
  final List<Post> posts = [];

  Future<void> init() => loadFirstPage(
    fetcher: (page) => _postService.getPosts(page: page, size: pageSize),
    onSuccess: (items) => posts.addAll(items),
  );

  Future<void> loadMore() => loadNextPage(
    fetcher: (page) => _postService.getPosts(page: page, size: pageSize),
    onSuccess: (items) => posts.addAll(items),
  );
}
```

In the View, trigger `loadMore()` when the user scrolls to the bottom:

```dart
NotificationListener<ScrollEndNotification>(
  onNotification: (n) {
    if (n.metrics.extentAfter == 0) viewModel.loadMore();
    return false;
  },
  child: ListView.builder(...),
)
```

| Member | Description |
|---|---|
| `currentPage` | Current page number |
| `hasMore` | Whether more pages exist |
| `isLoadingMore` | True while a next-page request is in flight |
| `pageSize` | Items per page (default 20, set before first load) |
| `loadFirstPage(fetcher, onSuccess)` | Resets and loads page 1 |
| `loadNextPage(fetcher, onSuccess)` | Appends next page; no-op when `hasMore` is false |
| `resetPagination()` | Resets to page 1 |

---

### CommonViewModel Mixin

`lib/core/mixins/common_viewmodel_mixin.dart`

Mix into any `BaseViewModel` to get pre-wired Stacked services and a unified `run()` method. The single biggest time-saver.

```dart
class HomeViewModel extends BaseViewModel with CommonViewModel {
  Future<void> loadFeed() => run(
    () async { _feed = await _feedService.fetch(); },
    errorMsg: 'Could not load feed',
  );

  Future<void> deletePost(Post post) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete post?',
      description: 'This cannot be undone.',
    );
    if (confirmed?.confirmed != true) return;

    await run(() => _feedService.delete(post.id));
    showSuccess('Post deleted');
  }
}
```

**Services available (resolved from locator automatically):**

| Property | Type |
|---|---|
| `dialogService` | `DialogService` |
| `navService` | `NavigationService` |
| `snackbarService` | `SnackbarService` |

**Methods:**

| Method | Description |
|---|---|
| `run(fn, {busyKey, errorMsg, showSnackbarOnError})` | Busy + error wrapper, returns void |
| `runAndReturn<T>(fn, {busyKey, errorMsg})` | Like `run` but returns `T?` |
| `showSuccessDialog(message)` | Success dialog |
| `showErrorDialog(message)` | Error dialog |
| `showConfirmDialog(...)` | Confirmation dialog → `DialogResponse?` |
| `showSuccess(message)` | Success snackbar |
| `showErr(message)` | Error snackbar |
| `showInfo(message)` | Info snackbar |

---

### Locator Helper

`lib/core/extensions/locator_helper.dart`

```dart
// Assign your GetIt instance once (typically in locator.dart):
locator = GetIt.instance;

// Then anywhere in the codebase:
final _authService = locate<AuthService>();   // instead of locator<AuthService>()
```

---

### BaseApiService

`lib/core/services/base_api_service.dart`

Subclass this for every API service. `safeCall` / `safeCallList` wraps Dio and returns `Result<T>` — no try/catch needed in the ViewModel.

```dart
class AuthApiService extends BaseApiService {
  AuthApiService(super.dio);

  Future<Result<AuthTokens>> login(String email, String password) =>
      safeCall(
        () => dio.post('/auth/login', data: {'email': email, 'password': password}),
        AuthTokens.fromJson,
      );

  Future<Result<List<Post>>> getPosts() =>
      safeCallList(
        () => dio.get('/posts'),
        Post.fromJson,
      );
}
```

**DioFactory** — create a production Dio instance:

```dart
final dio = DioFactory.create(
  baseUrl: Env.apiUrl,
  authToken: await storage.getString('token'),
  interceptors: [
    AuthInterceptor(() => storage.getString('token')),
    LoggingInterceptor(),   // only add in debug builds
  ],
);
```

| Interceptor | Description |
|---|---|
| `AuthInterceptor(tokenProvider)` | Injects/refreshes Bearer token on every request |
| `LoggingInterceptor` | Prints method, URL, and status to console |

**Error parsing priority:**
1. `response.data['message']`
2. `response.data['error']`
3. `response.data['detail']`
4. Human-readable string for timeout / connection errors

---

### ConnectivityService

`lib/core/services/connectivity_service.dart`

```dart
// Register in locator:
locator.registerLazySingleton<ConnectivityService>(ConnectivityService.new);

// In a ViewModel:
class HomeViewModel extends BaseViewModel with CommonViewModel {
  final _connectivity = locate<ConnectivityService>();

  Future<void> init() async {
    _connectivity.onStatusChanged.listen((online) {
      if (!online) showErr('No internet connection');
      notifyListeners();
    });
    await _connectivity.checkConnectivity();
  }

  bool get isOnline => _connectivity.isOnline;
}
```

| Member | Description |
|---|---|
| `isOnline` / `isOffline` | Synchronous current state |
| `checkConnectivity()` | Async check, updates `isOnline` |
| `onStatusChanged` | `Stream<bool>` emitting on every change |

---

### StorageService

`lib/core/services/storage_service.dart`

Typed wrapper around `SharedPreferences`.

```dart
// Register in locator:
final storage = await StorageService.init();
locator.registerSingleton<StorageService>(storage);

// Usage:
await storage.saveString('token', accessToken);
final token = storage.getString('token');

await storage.saveBool('onboarded', true);
final onboarded = storage.getBool('onboarded') ?? false;

await storage.clearAll();
await storage.clearPrefix('cart_');   // remove all keys starting with 'cart_'
```

---

## Core — Extensions

### StringX

`lib/core/extensions/string_extensions.dart`

```dart
'hello world'.titleCase        // 'Hello World'
'hello world'.capitalized      // 'Hello world'
'Long text here'.truncate(8)   // 'Long tex…'
'John Doe'.initials            // 'JD'
'08012345678'.maskPhone()      // '•••••••5678'
'4111111111111111'.maskedCard  // '•••• •••• •••• 1111'
'user@email.com'.isValidEmail  // true
'abc'.digitsOnly               // ''
'  '.nullIfEmpty               // null

// Nullable variant
String? name;
name.isNullOrEmpty             // true
name.orEmpty                   // ''
```

---

### DateTimeX

`lib/core/extensions/datetime_extensions.dart`

```dart
final dt = DateTime.now().subtract(Duration(hours: 2));

dt.timeAgo           // '2h ago'
dt.toReadableDate    // '14 Jan 2024'
dt.toReadableDateTime // '14 Jan 2024, 09:30 AM'
dt.toTimeString      // '09:30 AM'
dt.to24HourTime      // '09:30'
dt.toIso8601Date     // '2024-01-14'
dt.format('EEEE')    // 'Monday'

dt.isToday           // false
dt.isYesterday       // false
dt.isThisWeek        // bool
dt.isPast            // true
dt.startOfDay        // DateTime(2024, 1, 14, 0, 0, 0)
dt.endOfDay          // DateTime(2024, 1, 14, 23, 59, 59)
dt.addDays(7)        // DateTime + 7 days

// Nullable variant
DateTime? d;
d.timeAgoOr('Unknown')         // 'Unknown'
d.formatOr('dd/MM/yyyy')       // '—'
```

---

### NumX / IntX

`lib/core/extensions/num_extensions.dart`

```dart
1200.50.toCurrency(symbol: '₦')   // '₦1,200.50'
1200.toCurrency(symbol: '\$')      // '\$1,200.00'
1200.compact                       // '1.2k'
3_400_000.compact                  // '3.4M'
0.756.toPercent()                  // '75.6%'
0.5.toPercent(multiply: false)     // '0.5%'

30.seconds    // Duration(seconds: 30)
500.milliseconds  // Duration(milliseconds: 500)

5.isPositive  // true
0.isZero      // true

// IntX
5.padded()          // '05'
5.padded(3)         // '005'
1024.toFileSize     // '1.0 KB'
1_048_576.toFileSize // '1.0 MB'
```

---

## UI — Constants

### AppColors

`lib/ui/constants/app_colors.dart`

Universal design tokens — neutrals, semantic colors, and surfaces.
**Brand colors (primary, secondary) are not here.** Each app defines its own palette and passes it into `AppTheme` via a `ColorScheme`.

```dart
Container(color: AppColors.error)
Divider(color: AppColors.grey200)
```

| Group | Constants |
|---|---|
| Neutrals | `grey50` … `grey900` |
| Semantic | `success`, `successLight`, `warning`, `warningLight`, `error`, `errorLight`, `info`, `infoLight` |
| Surface | `surface`, `surfaceDark`, `background`, `backgroundDark`, `border`, `borderDark` |

---

### AppSpacing

`lib/ui/constants/app_spacing.dart`

```dart
Padding(padding: EdgeInsets.all(AppSpacing.md))  // 16
SizedBox(height: AppSpacing.lg)                  // 24
```

| Constant | Value |
|---|---|
| `xxs` | 2 |
| `xs` | 4 |
| `sm` | 8 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 32 |
| `xxl` | 48 |
| `xxxl` | 64 |

---

### AppRadius

`lib/ui/constants/app_radius.dart`

```dart
BorderRadius.circular(AppRadius.card)   // 16
AppRadius.buttonBR                      // BorderRadius object — use directly
```

| Constant | Value | BorderRadius shorthand |
|---|---|---|
| `xs` | 4 | `xsBR` |
| `sm` | 8 | `smBR` |
| `md` | 12 | `mdBR` |
| `lg` | 16 | `lgBR` |
| `xl` | 24 | `xlBR` |
| `button` | 12 | `buttonBR` |
| `card` | 16 | `cardBR` |
| `input` | 10 | `inputBR` |
| `full` | 999 | `fullBR` |

---

### AppTextStyles

`lib/ui/constants/app_text_styles.dart`

```dart
Text('Welcome back', style: AppTextStyles.h1)
Text('Created 2 days ago', style: AppTextStyles.caption)
```

| Style | Size | Weight |
|---|---|---|
| `displayLg` | 36 | 800 |
| `displaySm` | 28 | 700 |
| `h1` | 24 | 700 |
| `h2` | 20 | 600 |
| `h3` | 18 | 600 |
| `bodyLg` | 16 | 400 |
| `body` | 14 | 400 |
| `bodySm` | 12 | 400 |
| `label` | 13 | 500 |
| `caption` | 11 | 400 |
| `overline` | 10 | 600 |

---

## UI — Theme

### AppTheme

`lib/ui/theme/app_theme.dart`

Generates `ThemeData` from design tokens. Pass your app's `ColorScheme` to inject brand colors — all Material widgets and `app_kit` widgets inherit them automatically.

```dart
// In each app — define brand colors once:
abstract final class BrandColors {
  static const primary   = Color(0xFF1E6BFF);
  static const secondary = Color(0xFF00C896);
}

// Wire into MaterialApp:
MaterialApp(
  theme: AppTheme.light(
    colorScheme: ColorScheme.light(
      primary: BrandColors.primary,
      secondary: BrandColors.secondary,
    ),
  ),
  darkTheme: AppTheme.dark(
    colorScheme: ColorScheme.dark(
      primary: BrandColors.primary,
      secondary: BrandColors.secondary,
    ),
  ),
  themeMode: ThemeMode.system,
)
```

If no `colorScheme` is passed, Flutter's default `ColorScheme.light()` / `ColorScheme.dark()` is used — useful during prototyping.

Configured sub-themes: `ElevatedButtonTheme`, `OutlinedButtonTheme`, `TextButtonTheme`, `InputDecorationTheme`, `CardTheme`, `AppBarTheme`, `SnackBarTheme`, `DialogTheme`, `BottomSheetTheme`, `ChipTheme`, `DividerTheme`.

---

## UI — Extensions

### ContextX

`lib/ui/utils/context_extensions.dart`

```dart
context.screenWidth       // MediaQuery width
context.screenHeight
context.statusBarHeight
context.safeAreaBottom
context.isDark            // bool
context.colors            // ColorScheme
context.textTheme         // TextTheme
context.primaryColor
context.unfocus()         // dismiss keyboard
context.pop()
context.push(MyPage())
context.showSnackbar('Saved!')
```

---

### WidgetX

`lib/ui/utils/widget_extensions.dart`

```dart
Text('Hello')
  .padH(AppSpacing.md)
  .padV(AppSpacing.sm)
  .center()

MyWidget()
  .visible(viewModel.isLoggedIn)
  .opacity(0.8)
  .onTap(viewModel.handleTap)
  .clipRounded(AppRadius.card)
  .expand()
```

| Extension | Description |
|---|---|
| `padAll(v)` | `EdgeInsets.all` |
| `padH(v)` / `padV(v)` | Horizontal / vertical padding |
| `padOnly(l,r,t,b)` | Directional padding |
| `center()` | Wraps in `Center` |
| `expand([flex])` | Wraps in `Expanded` |
| `flexible([flex])` | Wraps in `Flexible` |
| `visible(bool)` | `Visibility` wrapper |
| `opacity(v)` | `Opacity` wrapper |
| `onTap(fn)` | `GestureDetector` |
| `inkWell(onTap)` | `InkWell` with optional radius |
| `clipRounded(r)` | `ClipRRect` |
| `clipOval()` | `ClipOval` |
| `sizedBox(w,h)` | `SizedBox` wrapper |
| `sliver` | `SliverToBoxAdapter` |

---

### TextStyleX

`lib/ui/utils/text_style_extensions.dart`

```dart
context.textTheme.bodyMedium!.bold.colored(AppColors.grey500)
AppTextStyles.h2.semiBold.sized(22).spaced(0.5)
```

| Extension | Description |
|---|---|
| `.bold` / `.semiBold` / `.medium` | Font weight shorthands |
| `.italic` | Italic style |
| `.underline` / `.lineThrough` | Text decorations |
| `.colored(Color)` | Change color |
| `.sized(double)` | Change font size |
| `.spaced(double)` | Letter spacing |
| `.height(double)` | Line height |

---

### Responsive

`lib/ui/utils/responsive.dart`

| Breakpoint | Width |
|---|---|
| Mobile | ≤ 599 px |
| Tablet | 600 – 1023 px |
| Desktop | ≥ 1024 px |

```dart
double padding = Responsive.resolve(context,
  mobile: 16.0,
  tablet: 32.0,
  desktop: 64.0,
);

// Widget version
ResponsiveBuilder(
  mobile:  MobileLayout(),
  tablet:  TabletLayout(),
  desktop: DesktopLayout(),
)
```

---

## UI — Shared Widgets

### Gap

`lib/ui/shared/gap.dart`

Replaces `SizedBox` everywhere.

```dart
Column(children: [
  Text('Title'),
  Gap(AppSpacing.md),    // vertical gap
  Text('Body'),
])

Row(children: [
  Icon(Icons.star),
  Gap.h(AppSpacing.xs),  // horizontal gap
  Text('4.5'),
])
```

---

### ShowIf

`lib/ui/shared/show_if.dart`

Replaces ternary noise.

```dart
ShowIf(
  condition: viewModel.isLoggedIn,
  child: ProfileSection(),
  fallback: LoginPrompt(),   // optional — defaults to SizedBox.shrink()
)
```

---

### BusyOverlay

`lib/ui/shared/busy_overlay.dart`

Overlays a spinner and blocks pointer events during loading.

```dart
BusyOverlay(
  busy: viewModel.isBusy,
  child: MyScrollableContent(),
)
```

---

### EmptyState

`lib/ui/shared/empty_state.dart`

```dart
EmptyState(
  icon: Icons.inbox_outlined,
  message: 'No transactions yet',
  subMessage: 'Your completed transactions will appear here.',
  onRetry: viewModel.load,
  retryLabel: 'Refresh',
)
```

---

### ErrorView

`lib/ui/shared/error_view.dart`

Full-page error with retry.

```dart
if (viewModel.hasError)
  ErrorView(
    message: viewModel.modelError.toString(),
    onRetry: viewModel.retry,
  )
```

---

### ShimmerBox

`lib/ui/shared/shimmer_box.dart`

Skeleton placeholder boxes and a widget extension for shimmer wrapping.

```dart
// Placeholder boxes
ShimmerBox(width: double.infinity, height: 56)
ShimmerBox(width: 80, height: 80, radius: AppRadius.full) // avatar placeholder

// Extension — swap real widget for shimmer during load
MyListTile().withShimmer(viewModel.isBusy)
```

---

### AppTextField

`lib/ui/shared/app_text_field.dart`

Unified form field — replaces all `TextFormField` boilerplate.

```dart
AppTextField(
  label: 'Email address',
  hint: 'you@example.com',
  controller: _emailCtrl,
  keyboardType: TextInputType.emailAddress,
  validator: Validators.email,
)

AppTextField(
  label: 'Password',
  obscure: true,              // auto-toggles visibility icon
  validator: Validators.password,
)

AppTextField(
  label: 'Search',
  showClearButton: true,      // shows ✕ icon when field has text
  controller: _searchCtrl,
)

AppTextField(label: 'Bio', maxLines: 4, maxLength: 300)
```

---

### AppSearchField

`lib/ui/shared/app_search_field.dart`

Pill-shaped search input with built-in debounce, clear button, and loading indicator.

```dart
AppSearchField(
  hint: 'Search products…',
  onChanged: viewModel.search,        // fires after 500 ms of inactivity
  onCleared: viewModel.clearSearch,
  isLoading: viewModel.isSearching,
  debounceDuration: Duration(milliseconds: 300),
)
```

---

### AppDropdown

`lib/ui/shared/app_dropdown.dart`

Styled dropdown that matches `AppTextField` visually and integrates with `Form`.

```dart
AppDropdown<String>(
  label: 'Country',
  value: viewModel.country,
  hint: 'Select a country',
  items: ['Nigeria', 'Ghana', 'Kenya']
      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
      .toList(),
  onChanged: viewModel.setCountry,
  validator: (v) => v == null ? 'Required' : null,
)
```

---

### AppButton

`lib/ui/shared/app_button.dart`

One button widget for all variants and states.

```dart
// Primary (default)
AppButton(label: 'Sign In', onTap: viewModel.login, busy: viewModel.isBusy)

// Variants
AppButton(label: 'Cancel', variant: ButtonVariant.outline)
AppButton(label: 'Skip',   variant: ButtonVariant.ghost)
AppButton(label: 'Delete', variant: ButtonVariant.danger)

// Sizes
AppButton(label: 'Compact', size: ButtonSize.sm)
AppButton(label: 'Large',   size: ButtonSize.lg)

// With icon
AppButton(
  label: 'Continue',
  icon: Icon(Icons.arrow_forward_rounded),
  iconRight: true,
)

// Fixed width
AppButton(label: 'OK', width: 120)
```

| Prop | Type | Default |
|---|---|---|
| `label` | `String` | required |
| `onTap` | `VoidCallback?` | `null` |
| `variant` | `ButtonVariant` | `primary` |
| `size` | `ButtonSize` | `md` |
| `busy` | `bool` | `false` |
| `disabled` | `bool` | `false` |
| `icon` | `Widget?` | `null` |
| `iconRight` | `bool` | `false` |
| `width` | `double?` | `double.infinity` |

---

### AppIconButton

`lib/ui/shared/app_icon_button.dart`

Consistent icon-only button with fixed tap target.

```dart
AppIconButton(
  icon: Icon(Icons.notifications_outlined),
  onTap: viewModel.openNotifications,
)

AppIconButton(
  icon: Icon(Icons.add),
  onTap: viewModel.create,
  outlined: true,
  size: 40,
  tooltip: 'Create new',
)
```

---

### AppListTile

`lib/ui/shared/app_list_tile.dart`

Consistent list item with leading, title, subtitle, trailing, chevron, and optional divider.

```dart
AppListTile(
  title: 'Notifications',
  leading: Icon(Icons.notifications_outlined),
  showChevron: true,
  onTap: viewModel.openNotifications,
)

AppListTile(
  title: 'John Doe',
  subtitle: 'john@example.com',
  leading: AppAvatar(name: 'John Doe', size: 40),
  trailing: StatusChip.active(),
  showDivider: true,
)
```

---

### AppNetworkImage

`lib/ui/shared/app_network_image.dart`

Cached network image with shimmer placeholder and error fallback.

```dart
AppNetworkImage(
  url: product.imageUrl,
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
  radius: AppRadius.card,
)
```

---

### AppCard

`lib/ui/shared/app_card.dart`

```dart
AppCard(
  onTap: () => viewModel.openDetail(item),
  child: ListTile(
    title: Text(item.name),
    subtitle: Text(item.date),
  ),
)

AppCard(
  padding: EdgeInsets.all(AppSpacing.lg),
  showBorder: false,
  elevation: 2,
  child: MyContent(),
)
```

---

### AppBadge

`lib/ui/shared/app_badge.dart`

Semantic color-coded badge.

```dart
AppBadge(label: 'New',      variant: BadgeVariant.primary)
AppBadge(label: 'On sale',  variant: BadgeVariant.success)
AppBadge(label: 'Expiring', variant: BadgeVariant.warning)
AppBadge(label: 'Rejected', variant: BadgeVariant.error)
AppBadge(label: 'Draft',    variant: BadgeVariant.neutral)
AppBadge(
  label: 'Info',
  variant: BadgeVariant.info,
  icon: Icon(Icons.info_outline),
)
```

---

### AppAvatar

`lib/ui/shared/app_avatar.dart`

Network avatar with automatic initials fallback and optional badge overlay.

```dart
AppAvatar(imageUrl: user.photoUrl, name: user.fullName, size: 48)

// Initials only
AppAvatar(name: 'John Doe', size: 40)

// With online indicator badge
AppAvatar(
  name: user.name,
  size: 48,
  badge: Container(
    width: 12, height: 12,
    decoration: BoxDecoration(
      color: AppColors.success,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
  ),
)
```

---

### AppDivider

`lib/ui/shared/app_divider.dart`

```dart
AppDivider()                              // plain line
AppDivider(label: 'or continue with')    // centered label
AppDivider(label: 'Filters', labelLeft: true)
```

---

### AppBottomSheet

`lib/ui/shared/app_bottom_sheet.dart`

Handles drag handle, safe area inset, and keyboard avoidance automatically.

```dart
AppBottomSheet.show(
  context,
  title: 'Sort by',
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: sortOptions.map((o) => ListTile(title: Text(o))).toList(),
  ),
);
```

---

### StatusChip

`lib/ui/shared/status_chip.dart`

Named constructors for common statuses, or pass any color for custom ones.

```dart
StatusChip.active()
StatusChip.pending()
StatusChip.inactive()
StatusChip.failed()
StatusChip.verified()

// Custom
StatusChip(label: 'Processing', color: AppColors.info)
StatusChip(label: 'Archived',   color: AppColors.grey400, dot: false)
```

---

## License

MIT
