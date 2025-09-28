<p align="center">
  <a href="https://librechat.ai">
    <img src="client/public/assets/logo.svg" height="256">
  </a>
  <h1 align="center">
    <a href="https://librechat.ai">LibreChat-OpenRouter</a>
  </h1>
</p>

> **🚀 This Fork Features Native OpenRouter Support**
>
> This fork includes full native integration for [OpenRouter](https://openrouter.ai), providing access to 100+ AI models through a single API with enterprise features:
> - ✅ **Dual Implementation Architecture** - Direct chat via `OpenRouterClient` and Agent support via `ChatOpenRouter` (LangChain)
> - 🛠️ **Native Tool/Function Calling** - Complete OpenAI-compatible tool support for all agent capabilities
> - 🤖 **Auto-Router™** - Toggle intelligent model selection with real-time model detection in streaming responses
> - 💰 **Real-time Credits Tracking** - Monitor usage directly in the UI with intelligent caching (5min credits, 1hr models)
> - 🔄 **Seamless Model Switching** - Change models mid-conversation without losing context
> - 🔒 **Zero Data Retention (ZDR)** - Privacy mode sends `X-OpenRouter-ZDR: true` header for compliant data routing
> - 🔀 **Model Fallback Chains** - Configure automatic fallback models for resilient conversations
>
> **[⚙️ Configuration](docs/configuration/pre_configured_ai/openrouter.md)** | **[✨ Features](docs/features/openrouter.md)** | **[🚀 Quick Setup](#openrouter-quick-setup)**

<p align="center">
  <a href="https://discord.librechat.ai"> 
    <img
      src="https://img.shields.io/discord/1086345563026489514?label=&logo=discord&style=for-the-badge&logoWidth=20&logoColor=white&labelColor=000000&color=blueviolet">
  </a>
  <a href="https://www.youtube.com/@LibreChat"> 
    <img
      src="https://img.shields.io/badge/YOUTUBE-red.svg?style=for-the-badge&logo=youtube&logoColor=white&labelColor=000000&logoWidth=20">
  </a>
  <a href="https://docs.librechat.ai"> 
    <img
      src="https://img.shields.io/badge/DOCS-blue.svg?style=for-the-badge&logo=read-the-docs&logoColor=white&labelColor=000000&logoWidth=20">
  </a>
  <a aria-label="Sponsors" href="https://github.com/sponsors/danny-avila">
    <img
      src="https://img.shields.io/badge/SPONSORS-brightgreen.svg?style=for-the-badge&logo=github-sponsors&logoColor=white&labelColor=000000&logoWidth=20">
  </a>
</p>

<p align="center">
<a href="https://railway.app/template/b5k2mn?referralCode=HI9hWz">
  <img src="https://railway.app/button.svg" alt="Deploy on Railway" height="30">
</a>
<a href="https://zeabur.com/templates/0X2ZY8">
  <img src="https://zeabur.com/button.svg" alt="Deploy on Zeabur" height="30"/>
</a>
<a href="https://template.cloud.sealos.io/deploy?templateName=librechat">
  <img src="https://raw.githubusercontent.com/labring-actions/templates/main/Deploy-on-Sealos.svg" alt="Deploy on Sealos" height="30">
</a>
</p>

<p align="center">
  <a href="https://www.librechat.ai/docs/translation">
    <img 
      src="https://img.shields.io/badge/dynamic/json.svg?style=for-the-badge&color=2096F3&label=locize&query=%24.translatedPercentage&url=https://api.locize.app/badgedata/4cb2598b-ed4d-469c-9b04-2ed531a8cb45&suffix=%+translated" 
      alt="Translation Progress">
  </a>
</p>


## 🚀 OpenRouter Native Integration

> **⚠️ Note: This is a proof-of-concept implementation**. While OpenRouter is now integrated as a native provider with Agent system compatibility, comprehensive testing is still ongoing.
>
> **This fork with native OpenRouter integration was developed by Sergey Kornilov (Biostochastics)**
>
> **📌 Important:** This fork requires a custom @librechat/agents package. See [Syncing with Upstream](#-syncing-with-upstream-librechat) for maintenance instructions.

### Key Features
- **🔒 Zero Data Retention (ZDR)**: Privacy toggle in navigation bar - enforce routing only through providers that guarantee no data storage
  - Shield icon toggle next to Auto-Router for quick access
  - Shield turns amber when ZDR is active
  - Automatically adds `zdr: true` to all API requests
- **📊 Real-time Credits Display**: Monitor your OpenRouter balance in the navigation bar
- **🤖 Auto-Router Toggle**: Lightning icon in nav bar for intelligent model selection
- **📚 Comprehensive Privacy Documentation**: Clear explanations for privacy policy errors and solutions

### Motivation

The existing YAML configuration approach for OpenRouter (as documented in [Issue #6763](https://github.com/danny-avila/LibreChat/issues/6763)) had a critical limitation: it was incompatible with LibreChat's Agent system. Since LibreChat routes all conversations through its agent infrastructure—not just agent-specific features—this incompatibility meant missing out on core functionality. Native provider status was necessary to enable full feature parity with other providers.

### Implementation Details

#### The Core Problem
LibreChat's architecture uses the agent system (`@librechat/agents` package) for all chat interactions. The package includes a `ChatOpenRouter` class that extends `ChatOpenAI` from langchain, but getting it to work required understanding the exact configuration structure it expected.

#### Specific Changes Made

**1. Configuration Structure Matching**
The `ChatOpenRouter` class required a specific nested structure that wasn't obvious from the documentation:
```javascript
// What ChatOpenRouter actually expects:
{
  apiKey: 'sk-or-...',
  configuration: {  // Must be nested exactly like this
    baseURL: 'https://openrouter.ai/api/v1',
    defaultHeaders: {
      'HTTP-Referer': 'http://localhost:3080',
      'X-Title': 'LibreChat'
    }
  }
}
```
Initial attempts placed `baseURL` at the root level or used different nesting, causing all requests to route to OpenAI's API instead.

**2. Provider Registration and Mapping**
- Modified `/api/server/services/Endpoints/index.js` to map OpenRouter to its own initialization function (`initOpenRouter`) rather than the generic `initCustom`
- Added multiple mapping entries to handle case variations and different property names used throughout the codebase

**3. Initialization Flow (`/api/server/services/Endpoints/openrouter/initialize.js`)**
- When `optionsOnly=true` (agent mode), returns configuration formatted for `ChatOpenRouter`
- When `optionsOnly=false` (direct client mode), instantiates `OpenRouterClient` for non-agent operations
- Handles both user-provided and environment-configured API keys

**4. Frontend Registry Fix**
The frontend was throwing `TypeError: undefined is not an object (evaluating 'e.key')` because OpenRouter wasn't registered in `/client/src/components/Endpoints/Settings/settings.ts`. Added the registration to fix the undefined reference.

**5. Credits Tracking and Auto Router Toggle Feature**
- Implemented `/api/endpoints/openrouter/credits` endpoint
- Added caching layer (5-minute TTL) to avoid excessive API calls
- Created unified control bar with credits display and Auto Router toggle
- **Auto Router Toggle Implementation**:
  - Toggle positioned next to credits for prominent visibility
  - When enabled, automatically sets model to `openrouter/auto`
  - Disables model dropdown with clear "Auto Router Active" message
  - State persists via Recoil atom with localStorage
  - Visual feedback with green lightning icon when active
  - Responsive design - compact on mobile, full on desktop

### Auto Router Toggle Technical Implementation

**Files Modified for Auto Router Feature:**
1. `/client/src/components/Nav/OpenRouterCredits.tsx`
   - Extended to include Auto Router toggle alongside credits
   - Added Switch component with Zap icon for visual feedback
   - Implemented responsive layout with divider separator

2. `/client/src/components/Input/ModelSelect/OpenRouter.tsx`
   - Added conditional rendering based on `openRouterAutoRouterEnabledState`
   - When enabled, displays disabled state with "Auto Router Active" message
   - Prevents manual model selection when Auto Router is active

3. `/client/src/store/openrouter.ts`
   - Already contained `openRouterAutoRouterEnabledState` atom with localStorage persistence
   - `openRouterConfigSelector` automatically sets model to `openrouter/auto` when enabled

4. `/client/src/locales/en/translation.json`
   - Added localization keys for Auto Router UI elements
   - Includes toggle label, tooltip, and disabled state messages

### Caveats and Issues Encountered

1. **API Routing Confusion**: The most time-consuming issue was requests being sent to `https://api.openai.com` instead of `https://openrouter.ai/api/v1`. This happened because the configuration structure wasn't matching what `ChatOpenAI` (parent class) expected.

2. **Multiple Provider Names**: OpenRouter is referenced differently across the codebase (`openrouter`, `OPENROUTER`, `EModelEndpoint.openrouter`), requiring multiple mapping entries.

3. **Agent System Dependency**: Initially attempted to make OpenRouter work independently of the agent system, but discovered this was architecturally impossible given LibreChat's design.

4. **Debugging Challenges**: The actual configuration being passed to `ChatOpenRouter` wasn't logged by default, making it difficult to identify the structure mismatch. Added extensive logging to trace the configuration flow.

### Current Features
- **✅ Full Agent Compatibility**: Required for any chat functionality in LibreChat
- **✅ Credits Tracking**: Real-time balance monitoring with intelligent caching
- **✅ Model Selection**: Access to 100+ models through OpenRouter's unified API
- **✅ Proper API Routing**: Requests correctly sent to OpenRouter's endpoints
- **✅ Environment Configuration**: Support for API keys and site attribution headers

### OpenRouter Quick Setup
1. Get your API key from [OpenRouter](https://openrouter.ai/keys)
2. Add to your `.env` file:
   ```bash
   OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxx
   OPENROUTER_SITE_URL=http://localhost:3080  # Optional
   OPENROUTER_SITE_NAME=LibreChat             # Optional
   ```
3. Select OpenRouter from the provider dropdown in LibreChat
4. Choose from 100+ available models or use Auto Router for intelligent model selection
5. Enable ZDR (Zero Data Retention) via the shield icon for privacy-compliant routing

### Technical Implementation
- **Dual Architecture**:
  - `OpenRouterClient` for direct chat (extends BaseClient)
  - `ChatOpenRouter` for Agent support (via enhanced [@librechat/agents fork](https://github.com/biostochastics/librechat-agents-openrouter))
- **Auto-Router Model Detection**: Real-time parsing of streaming responses to display actual model used
- **ZDR Privacy Headers**: Automatic injection of `X-OpenRouter-ZDR: true` when privacy mode is enabled
- **Intelligent Caching**: 5-minute credits cache, 1-hour models cache to reduce API calls
- **Model Fallback**: Configure backup models for automatic failover on errors

### Dependencies
This OpenRouter implementation requires our enhanced fork of @librechat/agents:
```bash
# Install from GitHub (for production)
npm install github:biostochastics/librechat-agents-openrouter#main
```
The fork adds auto-router detection and ZDR support to the agent system.

### Docker Build Instructions

**Important**: Due to Docker Hub rate limiting (100 pulls/6hrs for anonymous users), we use a multi-stage build with GitHub Container Registry:

```bash
# Build the Docker image with OpenRouter support
docker compose build --no-cache api

# Or if you encounter authentication issues:
# 1. Ensure you have the ghcr.io/danny-avila/librechat-dev:latest image
docker pull ghcr.io/danny-avila/librechat-dev:latest

# 2. Build using our enhanced Dockerfile
docker compose build api
```

The Dockerfile uses:
- **Multi-stage build** for optimized image size
- **ghcr.io base image** to bypass Docker Hub authentication
- **Git installation** for GitHub package dependencies
- **Proper npm configuration** for workspace and GitHub packages

[Full Configuration Guide →](docs/configuration/pre_configured_ai/openrouter.md) | [Features Documentation →](docs/features/openrouter.md)

## 🪶 All-In-One AI Conversations with LibreChat

LibreChat brings together the future of assistant AIs with the revolutionary technology of OpenAI's ChatGPT. Celebrating the original styling, LibreChat gives you the ability to integrate multiple AI models. It also integrates and enhances original client features such as conversation and message search, prompt templates and plugins.

With LibreChat, you no longer need to opt for ChatGPT Plus and can instead use free or pay-per-call APIs. We welcome contributions, cloning, and forking to enhance the capabilities of this advanced chatbot platform.

[![Watch the video](https://raw.githubusercontent.com/LibreChat-AI/librechat.ai/main/public/images/changelog/v0.7.6.gif)](https://www.youtube.com/watch?v=ilfwGQtJNlI)

Click on the thumbnail to open the video☝️

---

## 🌐 Resources

**GitHub Repo:**
  - **RAG API:** [github.com/danny-avila/rag_api](https://github.com/danny-avila/rag_api)
  - **Website:** [github.com/LibreChat-AI/librechat.ai](https://github.com/LibreChat-AI/librechat.ai)

**Other:**
  - **Website:** [librechat.ai](https://librechat.ai)
  - **Documentation:** [librechat.ai/docs](https://librechat.ai/docs)
  - **Blog:** [librechat.ai/blog](https://librechat.ai/blog)

---

## 📝 Changelog

Keep up with the latest updates by visiting the releases page and notes:
- [Releases](https://github.com/danny-avila/LibreChat/releases)
- [Changelog](https://www.librechat.ai/changelog) 

**⚠️ Please consult the [changelog](https://www.librechat.ai/changelog) for breaking changes before updating.**

---

## ⭐ Star History

<p align="center">
  <a href="https://star-history.com/#danny-avila/LibreChat&Date">
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=danny-avila/LibreChat&type=Date&theme=dark" onerror="this.src='https://api.star-history.com/svg?repos=danny-avila/LibreChat&type=Date'" />
  </a>
</p>
<p align="center">
  <a href="https://trendshift.io/repositories/4685" target="_blank" style="padding: 10px;">
    <img src="https://trendshift.io/api/badge/repositories/4685" alt="danny-avila%2FLibreChat | Trendshift" style="width: 250px; height: 55px;" width="250" height="55"/>
  </a>
  <a href="https://runacap.com/ross-index/q1-24/" target="_blank" rel="noopener" style="margin-left: 20px;">
    <img style="width: 260px; height: 56px" src="https://runacap.com/wp-content/uploads/2024/04/ROSS_badge_white_Q1_2024.svg" alt="ROSS Index - Fastest Growing Open-Source Startups in Q1 2024 | Runa Capital" width="260" height="56"/>
  </a>
</p>

---

## ✨ Contributions

Contributions, suggestions, bug reports and fixes are welcome!

For new features, components, or extensions, please open an issue and discuss before sending a PR.

If you'd like to help translate LibreChat into your language, we'd love your contribution! Improving our translations not only makes LibreChat more accessible to users around the world but also enhances the overall user experience. Please check out our [Translation Guide](https://www.librechat.ai/docs/translation).

---

## 💖 This project exists in its current state thanks to all the people who contribute

<a href="https://github.com/danny-avila/LibreChat/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=danny-avila/LibreChat" />
</a>

---

## 🎉 Special Thanks

We thank [Locize](https://locize.com) for their translation management tools that support multiple languages in LibreChat.

<p align="center">
  <a href="https://locize.com" target="_blank" rel="noopener noreferrer">
    <img src="https://github.com/user-attachments/assets/d6b70894-6064-475e-bb65-92a9e23e0077" alt="Locize Logo" height="50">
  </a>
</p>

---

## 🔄 Syncing with Upstream LibreChat

### Keeping Your Fork Updated

This fork maintains compatibility with upstream LibreChat while preserving OpenRouter features. Follow these steps to sync:

#### Quick Sync Script
```bash
# Use the provided sync script (stash it first if not committed)
./sync-with-upstream.sh
```

#### Manual Sync Process
```bash
# 1. Add upstream remote (if not already added)
git remote add upstream https://github.com/danny-avila/LibreChat.git

# 2. Fetch latest upstream changes
git fetch upstream main

# 3. Merge upstream (preserves your OpenRouter features)
git merge upstream/main

# 4. Resolve conflicts (keep your @librechat/agents fork reference)
# In api/package.json, keep:
# "@librechat/agents": "github:biostochastics/librechat-agents-openrouter#main"

# 5. Fix Docker build issues on ARM64 (M1/M2 Macs)
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
docker compose build api
```

### Common Issues & Solutions

#### Docker Build Fails on ARM64
**Error:** `Cannot find module @rollup/rollup-linux-arm64-musl`

**Solution:**
```bash
# Regenerate package-lock.json with correct architecture
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
docker compose build api
```

#### Peer Dependency Conflicts
**Solution:** Always use `--legacy-peer-deps` flag when installing:
```bash
npm install --legacy-peer-deps
```

#### Test Failures After Merge
**Expected:** Tests may fail due to the custom @librechat/agents fork. This doesn't affect functionality.

---

## 🚀 Fork Attribution

**This fork featuring native OpenRouter integration was developed by:**

### Sergey Kornilov (Biostochastics)
- GitHub: [@biostochastics](https://github.com/biostochastics)
- Implementation of native OpenRouter provider support
- Full Agent system compatibility for OpenRouter
- Real-time credits tracking integration
- Auto Router toggle
- Upstream sync maintenance guide

The OpenRouter native integration enables access to 100+ AI models through a single API with enterprise features, solving the limitation where YAML configuration was incompatible with LibreChat's Agent system.
