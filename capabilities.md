# Pillownote — 配置文档

生成时间：2026-09-23

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：以下配置项均为**增强功能**。不配置这些项，App 下载后即可正常使用所有核心功能（每日一问、盲答、每天 1 封枕边信、4 个组件、本地 AI 教练）。配置后可获得跨设备同步、真实推送、订阅购买等增强体验。

### 🟡 Capabilities 增强配置

#### 1. iCloud CloudKit 容器 — 双设备配对同步

**增强功能**：两台设备通过 6 位配对码真正互联（问题互见、枕边信送达对方、心情时间线同步）
**不配置的影响**：App 以本地优先模式运行，一切功能可用（含演示伴侣模式预览揭晓动画），但数据不跨设备同步
**当前状态**：已自动配置 entitlements（`iCloud.com.zzoutuo.Pillownote`）+ 优雅降级代码，未配置时自动回退本地

**已自动配置部分**：
- ✅ Xcode entitlements 已声明 iCloud CloudKit 服务与容器 ID
- ✅ `PairingService.swift` 已实现优雅降级（无 iCloud 账号时配对退化为单机模式）

**如需启用增强功能，请手动配置**：
1. 打开 [Apple Developer](https://developer.apple.com) → **Certificates, Identifiers & Profiles** → **Identifiers**
2. 点击 **"+"** 新建 App ID（或编辑已有），Bundle ID 填 `com.zzoutuo.Pillownote`
3. 勾选 **iCloud**（勾选 **CloudKit**）与 **Push Notifications**
4. 打开 [CloudKit Console](https://icloud.developer.apple.com) → 确认容器 `iCloud.com.zzoutuo.Pillownote` 已创建
5. 在 Xcode → Pillownote target → **Signing & Capabilities** 选择你的 **Team**（自动签名）
6. ⚠️ 配置完成后重新 Build 验证：真机上用两个 Apple ID 分别登录测试配对流程

#### 2. Apple Push Notifications service (APNs) — 信件到达推送

**增强功能**：对方拆信、枕边信到达时收到实时推送
**不配置的影响**：App 内仍按对方当地 7:00 用**本地通知**逐条预调度送达提醒（核心仪式不受影响）
**当前状态**：aps-environment entitlement 已声明；本地通知方案为默认

**如需启用增强功能，请手动配置**：
1. Apple Developer → **Keys** → 创建新 Key，勾选 **Apple Push Notifications service (APNs)**
2. 下载 `.p8` 密钥并记录 Key ID / Team ID（如后续接入自建推送服务用）
3. App ID 中确认 Push Notifications 已启用
4. ⚠️ 真机测试：设置 → 通知 → 允许 Pillownote

---

### 🔵 IAP StoreKit 配置（订阅类 App 必做）

**影响功能**：不在 App Store Connect 创建产品，用户无法完成真实订阅购买（本地 StoreKit 测试文件已就绪，开发期可完整测试付费流程）

**已自动配置部分**：
- ✅ `StoreService.swift`：StoreKit 2 完整集成（产品加载/购买/恢复/监听），Product ID 与 price.md 一致
- ✅ `Pillownote.storekit`：本地测试配置文件（含 7 天试用），Xcode Scheme 已关联
- ✅ Paywall 合规：价格展示、自动续订披露、Privacy Policy + Terms of Use 链接、Restore Purchases

**配置步骤**：
1. 在 App Store Connect → 你的 App → **Features** → **In-App Purchases**（订阅在 **Subscriptions**）
2. 创建订阅组 `Pillownote Plus`，按以下信息创建：

| 产品 | Reference Name | Product ID | 价格 |
|------|---------------|-----------|------|
| 月付 | Pillownote Plus Monthly | `com.zzoutuo.pillownote.plus.monthly` | $5.99/月 |
| 年付 | Pillownote Plus Annual | `com.zzoutuo.pillownote.plus.yearly` | $34.99/年（含 7 天免费试用） |

3. 另创建两个非消耗型（Non-Consumable）产品：

| 产品 | Reference Name | Product ID | 价格 |
|------|---------------|-----------|------|
| BYO 终身 | Pillownote BYO Lifetime | `com.zzoutuo.pillownote.byo.lifetime` | $29.99 买断 |
| 主题季包 | Pillownote Seasonal Themes | `com.zzoutuo.pillownote.themes.seasons` | $2.99 买断 |

4. Display Name / Description 从 `price.md` 复制（已校验 ≤35/≤55 字符）
5. 年付产品在 **Subscription Pricing** 中设置 7 天免费试用（Free Trial, 1 week）
6. ⚠️ 创建后等待 Apple 处理（通常 1-2 小时），然后真机 Sandbox 测试购买/恢复

---

### 🟢 App Store Connect 审核信息配置

**影响功能**：不配置则审核员可能无法测试 AI/订阅功能，导致 Guideline 2.1(a) 拒审风险

**配置步骤**：
1. App Store Connect → 你的 App → **App Review Information**
2. **Demo Account** 字段：粘贴 `app_review_info.md` 中 "Demo Account for Apple Review" 部分（说明 AI 在 iOS 26+ 设备免 Key 可用、旧设备走静态题库、BYO Key 可选）
3. **Notes** 字段：粘贴 `app_review_info.md` 的 Review Notes（AI BYO 合规声明、订阅产品清单、演示伴侣模式说明）
4. **Privacy Policy URL**：`https://asunnyboy861.github.io/Pillownote/privacy.html`
5. **Terms of Use (EULA)**：`https://asunnyboy861.github.io/Pillownote/terms.html`（或引用 Apple 标准 EULA 并附自定义条款链接）
6. **Support URL**：`https://asunnyboy861.github.io/Pillownote/support.html`

**`app_review_info.md` 位置**：项目根目录，已自动生成

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| App Groups | `group.com.zzoutuo.Pillownote`（App + Widgets 双 target） | ✅ 已配置 |
| iCloud (CloudKit) | entitlements 已声明容器 `iCloud.com.zzoutuo.Pillownote` | ✅ 已声明 |
| Push Notifications | aps-environment entitlement 已声明 | ✅ 已声明 |
| In-App Purchase | StoreKit 2 代码 + 本地测试配置 | ✅ 已配置 |
| 麦克风/语音识别/相机/相册 | Info.plist 用途描述已配置 | ✅ 已配置 |
| Outgoing Network (HTTPS) | 联系客服/云端 AI 需要，HTTPS 默认放行 | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers：`https://feedback-board.iocompile67692.workers.dev/api/feedback` | ✅ 已部署接入 |
| 政策页面 | GitHub Pages 已上线（Landing/Support/Privacy/Terms 全部 200） | ✅ 已部署 |
| BYO AI Key | 用户在 App 内 Settings → AI Configuration 自行粘贴，Keychain 加密存储 | ✅ 已实现 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | 12 主功能全实现（SwiftData 本地优先 + SwiftUI + MVVM） | ✅ 已完成 |
| AI 模块 | Apple Intelligence 默认端侧（iOS 26+）+ 静态题库降级 + BYO GLM Key | ✅ 已完成 |
| ContactSupportView | 7 主题磁贴 + 全字段必填 + 后端对接 | ✅ 已完成 |
| PurchaseManager | StoreKit 2 响应式绑定 + currentEntitlement 校验 | ✅ 已完成 |
| Widgets | 4 个免费组件（天数/倒计时/今日问/心情），App Group 数据共享 | ✅ 已完成 |
| QA 迭代 | Step 11 质量循环 1 轮（7 项修复）+ BYO 合规 13 项校验 | ✅ 已完成 |

### 💡 使用提示（非开发者配置，App 内操作即可）

**AI 功能**：App 默认使用 Apple Intelligence（设备端，免费、私密、无需任何配置，iPhone 15 Pro+ / iOS 26+）。不支持的设备自动降级为内置 160+ 精选题库（去重轮换），所有功能照常可用。BYO Key（Settings → AI Configuration）为可选增强，支持 z.ai / BigModel / GPT-4o 等任意兼容端点。

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub 仓库 | https://github.com/asunnyboy861/Pillownote | ✅ 已推送 |
| GitHub Pages | 4 页政策页已上线 | ✅ 已完成 |
| Landing Page | 已部署（App Store ID 为占位符，上架后替换） | ✅ 已完成 |
| App Store 元数据 | keytext.md 已生成并通过 15 项校验 | ✅ 已完成 |
| 定价配置 | price.md 已生成并校验 | ✅ 已完成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据。"Auto-Configured" 与 "Manual Configuration Required" 的内容已重组到上方 Section 一 和 Section 二。

### Analysis

基于指南 + us.md 关键词检测：
- CloudKit 同步 + CKShare 配对 → iCloud (CloudKit)
- 信件到达通知 → Push Notifications
- WidgetKit 组件 → App Groups + 扩展 target
- StoreKit 订阅/IAP → StoreKit 2
- 照片枕边信 → 相机/相册权限
- 语音信 + 转文字 → 麦克风 + 语音识别权限
- 不需要：HealthKit / 定位 / Watch / Siri

### No Configuration Needed

- HealthKit、定位、Apple Watch、Siri、Sign in with Apple — 不在范围内
- 无强制第三方 SDK：原生 StoreKit 2（RevenueCat 为可选项，未引入）

### Verification

- 构建验证通过：✅（iPhone 16 与 iPad Pro 13-inch (M5) 模拟器均构建并运行成功）
- Entitlements 配置正确：✅
- App 图标无 alpha 通道：✅
