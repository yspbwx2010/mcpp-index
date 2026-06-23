# mcpp-index artifact 发布机制 + 发布 CI 设计

**日期**: 2026-06-24
**本仓**: `mcpp-community/mcpp-index`(mcpp 的库索引,github 别名 `mcpplibs/mcpp-index`)
**目标**: 给 mcpp-index 补齐 **artifact 发布**(现为 git-only),并加"push 即发布"的 CI,
与 xim-pkgindex 统一模型;配合 mcpp 客户端的离线优先刷新。
**配套设计**:mcpp 仓 `.agents/docs/2026-06-24-offline-first-index-and-mcpp-index-publish.md`;
对照 xim-pkgindex 仓 `.agents/docs/2026-06-24-artifact-publish-mechanism.md`。

---

## 1. 现状:git-only

mcpp git-clone 本仓到 `~/.mcpp/registry/data/mcpplibs`,push 即可被 pull。问题:
- clone/pull 慢、弱网/被墙易失败;
- **没有"指针 sha"可做低成本比对**(只能 git fetch)→ mcpp build 自动刷新只能走重的 git;
- 受 mcpp 自身 index TTL 缓存影响("改了不刷"根因)。

## 2. 目标模型:artifact + 指针(对齐 xim-pkgindex)

| 路径 | 载体 |
|---|---|
| **artifact(目标默认)** | `mcpp-index-<gitsha>.tar.gz` + manifest + 指针 `mcpp-index-latest.json`,发到资源仓 |
| **git(回退)** | 本仓 github(+ 可选 gitee 镜像) |

## 3. 资源仓 + 配置(已就绪)

- **资源仓**:`xlings-res/mcpp-index`(**github GLOBAL + gitcode CN 两端都已创建**)。
  - artifact = release 资产;指针 `mcpp-index-latest.json` = 仓库文件。
  - 复用 xlings-res(mcpp 二进制本就在 `xlings-res/mcpp`),不另起 mcpp-res 组织。
- **本仓 secrets(已配置)**:`XLINGS_RES_TOKEN`(写 xlings-res)、`GITCODE_TOKEN`。

## 4. 方案:本仓加 `publish-artifact.yml`

- **触发**:`push`(paths `pkgs/**`)+ `workflow_dispatch` + 可选 `schedule`。
- **打包**:tar `pkgs/`(去 `.git`,确定性:`--sort=name --owner=0 --group=0`)→
  `mcpp-index-<gitsha>.tar.gz` + manifest(sha256/size/format_version/source_commit)。
  可直接复用/改写 xim-pkgindex 的 `build_xim_index_artifact.sh`(参数化 ARTIFACT_BASE 与默认 URL)。
- **发布**:artifact 传成 `xlings-res/mcpp-index` 的 release 资产(GH `gh release` + GitCode `gtc`,
  同名不可覆盖→新 sha 命名即免覆盖);指针 `mcpp-index-latest.json` git push 到该仓(两端)。
- **auth**:本仓已配的 `XLINGS_RES_TOKEN` + `GITCODE_TOKEN`。

**效果**:改 `pkgs/**` push → 自动重发 artifact + 移指针 → 客户端下次刷新即拿到,不必发 mcpp 版本。

## 5. mcpp 客户端侧(需配套,见 mcpp 仓文档)

1. **加 artifact 拉取**:`mcpp index update` 优先拉指针(`mcpp-index-latest.json`)+ 比 sha,
   命中跳过、未命中下 artifact;git clone 仅回退。`MCPP_INDEX_SOURCE=artifact|git|auto`(默认 auto),
   对齐 xlings 的 `XLINGS_INDEX_SOURCE`。
2. **离线优先**:`mcpp build` 不自动联网刷;首次 init 保证有索引(内置 seed 优先);
   steady-state 只读本地,缺包才提示 `mcpp index update`。
3. **指针 sha 比对**是"低成本重查"的核心 —— 命中即零下载、零 git。

## 6. 落地

1. **✅ 已实现**(PR #44,squash 合入):本仓 `.github/workflows/publish-artifact.yml`
   (push `pkgs/**` / 手动 / nightly)+ `tools/publish_mcpp_index.sh`(consolidated:build+publish+pointer)
   + vendored `tools/gtc`。内容哈希命名 `mcpp-index-<short-sha>.tar.gz`。
   - 资源仓 `xlings-res/mcpp-index`(github + gitcode 两端,gitcode 端由 `gtc repo create` 补建 + git init seed)。
   - 实测 CI(run success)+ 本地:artifact `mcpp-index-69f4b68.tar.gz` 两端**字节一致** `6ef3576e9048`,
     pointer `mcpp-index-pointers.json`(key `mcpp`)两端已推。
2. **mcpp 侧 artifact 拉取 + 离线优先**:见 mcpp 仓 `.agents/docs/2026-06-24-offline-first-...md`(WS3,待实现)。
3. 两套索引发布模型已统一(xim-pkgindex / mcpp-index 均 push 触发 → xlings-res 发 artifact + 合并/单 key 指针)。

> 注:gitcode 资源仓的 release 暂无法用 API 删除(405),误建的 probe release 需网页清理。
