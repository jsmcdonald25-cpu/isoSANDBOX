# GrailISO dashboard.html — Function Manifest
**Total lines:** 7,550  
**Last scanned:** March 23, 2026

---

## SCRIPT BLOCK BOUNDARIES
| Block | Lines | Description |
|---|---|---|
| Script 1 | 19–42 | Supabase config, core helpers (_sbH, _rGet, _rPost, _rPatch) |
| Script 2 | 1245–1440 | Auth gate logic |
| Script 3 | 1535–1553 | Inline panel init |
| Script 4 | 2872–7479 | Main app (all panels, ISOVault, Vault, etc.) |
| Script 5 | 7481–7548 | PWA: Service Worker + Install Banner |

---

## HTML PANEL BOUNDARIES
| Panel | Start Line | Key ID |
|---|---|---|
| PWA meta | 4 | — |
| Sidebar overlay (mobile) | 1153 | — |
| PWA Install Banner | 1155 | — |
| Auth Gate | 1169 | — |
| Sidebar | 1445 | — |
| MAIN wrapper | 1521 | — |
| Overview panel | 1563 | #overview |
| Post ISO (5 steps) | 1565 | #post-iso |
| My ISOs | 1704 | #my-isos |
| Market Data | 1725 | #market |
| My Vault | 1732 | #my-vault |
| ISOVault Search | 1958 | #isovault |
| ISOVault Card Detail | 2065 | #card-detail |
| Slab Lab Overlay | 2181 | — |
| Catalog Upload Overlay | 2240 | — |
| Error Report Modal | 2336 | — |
| ISOTicker | 2362 | — |
| Notifications | 2404 | — |
| Leaderboard | 2415 | — |
| Account | 2453 | — |
| Global Bug Report Button | 2482 | — |
| Global Bug Report Modal | 2488 | — |
| Add to Vault Modal | 2545 | — |
| Sell/Remove Modal | 2700 | — |
| Delete Warning Modal | 2777 | — |
| Scores Bar | 2850 | — |
| PWA SW + Banner JS | 7480 | — |

---

## FUNCTION INDEX

### CORE / SUPABASE HELPERS (L19–42)
| Line | Function |
|---|---|
| 26 | `_sbH()` — build Supabase headers |
| 27 | `_rGet(tb,q)` — GET request |
| 29 | `_ivRealTable(t)` — resolve Pokemon table alias |
| 31 | `_cdCardTitle(year,brand,set,player)` |
| 39 | `_rPost(tb,b,p)` — POST request |
| 40 | `_rPatch(tb,q,b)` — PATCH request |

### AUTH (L1245–1440)
| Line | Function |
|---|---|
| 1259 | `authErr(elId, msg)` |
| 1267 | `setBtnLoading(btnId, loading, label)` |
| 1372 | `initUserProfile(user)` |
| 1434 | `logOut()` |

### NAV / ROUTING (L7173–7215)
| Line | Function |
|---|---|
| 3135 | `N(id,el)` — nav panel switcher |
| 3166 | `gS(n)` — get section |
| 7173 | `toggleNavReorder()` |
| 7199 | `_navDragStart(e)` |
| 7200 | `_navDragOver(e)` |
| 7201 | `_navDrop(e)` |
| 7213 | `_navDragEnd()` |

### POST ISO — Steps 1–5 (L3182–3580)
| Line | Function |
|---|---|
| 3182 | `isoRenderSportGrid()` |
| 3204 | `isoSelectSport(sportDef)` |
| 3227 | `selSport(el,s)` |
| 3236 | `isoSearchPlayer(q)` |
| 3243 | `_isoPlayerFetch(q)` |
| 3292 | `pickP(name,team,pos,rookie)` |
| 3304 | `loadISOPlayers()` — stub |
| 3305 | `searchP(q)` |
| 3309 | `renderCardRes()` |
| 3383 | `s3ResetPreview()` |
| 3394 | `s3SelectSet(el,key)` |
| 3416 | `s3PickVariant(el,idx,key)` |
| 3438 | `s3LoadCardImage(card)` |
| 3456 | `s3ViewInISOVault()` |
| 3483 | `pickCard(id,el)` |
| 3487 | `selGrade(el)` |
| 3491 | `updateSum()` |
| 3507 | `submitISO()` |

### MARKET / LIBRARY (L3581–3655)
| Line | Function |
|---|---|
| 3581 | `renderMkt()` |
| 3589 | `renderOvMkt()` |
| 3600 | `renderLib(filt,search)` |
| 3629 | `filterLib(q)` |
| 3630 | `libType(type,el)` |
| 3640 | `C(el)` — chip toggle |
| 3642 | `T(msg)` — toast |

### ISOTICKER (L3656–3912)
| Line | Function |
|---|---|
| 3656 | `genHistory(card)` |
| 3664 | `rnd()` — seeded RNG (nested) |
| 3678 | `buildAggregate(range)` |
| 3707 | `renderITCards()` |
| 3730 | `toggleCard(id)` |
| 3734 | `toggleAllCards(on)` |
| 3740 | `updateITHeader()` |
| 3769 | `setRange(r,el)` |
| 3776 | `drawChart()` |
| 3865 | `initChartHover()` |
| 3893 | `initISOTicker()` |

### MY VAULT — MODALS & ACQUISITION (L3913–4524)
| Line | Function |
|---|---|
| 3913 | `openVaultModal(card)` |
| 4008 | `closeVaultModal()` |
| 4019 | `openSellModal(idx, type)` |
| 4061 | `selectSellSource(src)` |
| 4070 | `handleRemoveReasonChange(val)` |
| 4075 | `closeSellModal()` |
| 4081 | `cancelDelete()` |
| 4086 | `submitSell()` |
| 4175 | `confirmDelete()` |
| 4204 | `handleUpload(input, side)` |
| 4238 | `validateSerial()` |
| 4246 | `selectAcqType(type)` |
| 4286 | `selectSource(src)` |
| 4299 | `selectRipSource(src)` |
| 4312 | `selectAcq(type)` |
| 4314 | `submitVault()` |

### MY VAULT — RENDER & GRID (L4525–4921)
| Line | Function |
|---|---|
| 4525 | `openVaultCard(idx)` |
| 4579 | `_patchVaultThumbnails(rows)` |
| 4609 | `renderMyVault()` |
| 4665 | `_renderPlayerChart(data)` |
| 4692 | `_renderBrandChart(data)` |
| 4722 | `_renderActivityFeed(data)` |
| 4756 | `_renderVaultGrid(data)` |
| 4792 | `vaultSetFeatured(idx)` |
| 4793 | `vaultIsFeatured(idx)` |
| 4794 | `vaultClearHero()` |
| 4795 | `vaultHeroClick()` |
| 4796 | `_renderVaultFavs()` — stub |
| 4798 | `_renderVaultHero()` |
| 4825 | `_updateStarVisuals()` |
| 4836 | `_initModDrag()` |
| 4846 | `_modDS(e)` — drag start |
| 4847 | `_modDO(e)` — drag over |
| 4848 | `_modDL()` — drag leave |
| 4849 | `_modDrop(e)` |
| 4861 | `_modDE()` — drag end |
| 4862 | `_saveModLayout()` |
| 4865 | `_restoreModLayout()` |
| 4873 | `_toggleMvCustomize(btn)` |
| 4881 | `filterVaultGrid(q)` |
| 4897 | `sortVaultGrid(mode)` |

### SCORES BAR / CARD TICKER (L4922–5028)
| Line | Function |
|---|---|
| 4922 | `initCardTicker()` |
| 4942 | `initScoresBar()` |
| 4963 | `showFallback(msg)` — nested |
| 4964 | `renderEvents(events, isSchedule)` — nested |
| 4986 | `loadScores()` — nested |
| 5000 | `loadSchedule()` — nested |

### CARD DETAIL — 3D VIEWER (L5029–5905)
| Line | Function |
|---|---|
| 5029 | `openCardDetail(cardId)` |
| 5079 | `_cdLoadCatalogImages(c)` |
| 5189 | `_cdGuessTable(c)` |
| 5196 | `_cdShowUploadBtn(show)` |
| 5213 | `_cdApplyOrientation(landscape)` |
| 5220 | `_cdApplyOrientationBoth(frontLandscape, backLandscape)` |
| 5243 | `_cdProbeOrientation(url, callback)` |
| 5262 | `_cdSetViewerImages(frontUrl, backUrl)` |
| 5360 | `_buildVariationPills(c)` |
| 5388 | `cdSelectVar(idx, skipShimmer)` |
| 5471 | `_cdShimmer()` |
| 5482 | `_cdApplyTransform()` |
| 5490 | `_cdReset3D()` |
| 5500 | `_cdInitRotation()` |
| 5546 | `cdFlip()` |
| 5551 | `cdToggleSpin()` |
| 5561 | `cdReset()` |
| 5565 | `openCatalogUpload()` |
| 5596 | `cdUploadShowConfirm()` |
| 5646 | `cdUploadBackToUpload()` |
| 5651 | `closeCatalogUpload()` |
| 5657 | `_readExifOrientation(buffer)` |
| 5680 | `_drawExifNormalized(img, orientation, maxW)` |
| 5708 | `handleCatalogUpload(input, side)` |
| 5751 | `submitCatalogUpload()` |

### SLAB LAB (L2938–3134)
| Line | Function |
|---|---|
| 2938 | `openSlabLab()` |
| 2961 | `closeSlabLab()` |
| 2967 | `_applySlabTransform()` |
| 2973 | `slabFlip()` |
| 2978 | `slabToggleSpin()` |
| 2989 | `slabReset()` |
| 2996 | `_initSlabRotation()` |
| 3012 | `setSlabFinish(finish)` |
| 3020 | `_updateFinishBtns()` |
| 3032 | `_buildSlabSwatches()` |
| 3038 | `_applySlabColor(idx)` |
| 3052 | `_cdUpdateSlabLabBtn()` |

### ISOVAULT ENGINE (L5906–6945)
| Line | Function |
|---|---|
| 5906 | `_ivLoadSets()` — IIFE |
| 5946 | `ivInit()` |
| 6003 | `_ivLoadCatalogCards()` |
| 6043 | `_ivPrefetchCounts()` |
| 6071 | `ivGoHome()` |
| 6078 | `ivGoSport()` |
| 6092 | `_ivShowState(state)` |
| 6101 | `_ivBreadcrumb(showSport, showSet)` |
| 6125 | `ivGoBrand()` |
| 6141 | `ivGoYear()` |
| 6158 | `ivRenderSports()` |
| 6183 | `ivSelectSport(sportId)` |
| 6193 | `_ivRenderSetBrowser()` |
| 6213 | `ivYearFilter(y, el)` |
| 6220 | `ivBrandFilter(b, el)` |
| 6227 | `_ivApplySetFilters()` |
| 6234 | `_ivRenderSetTiles(sets)` |
| 6258 | `ivSelectSet(table)` |
| 6363 | `_ivApplyCardFilters()` |
| 6382 | `_ivRenderCards()` |
| 6390 | `_ivRenderChecklist()` |
| 6442 | `_ivRenderGrid()` |
| 6482 | `_varPillColor(label)` |
| 6504 | `ivOpenCard(row)` |
| 6662 | `ivCatFilter(cat, el)` |
| 6669 | `ivFilterCards(q)` |
| 6674 | `ivSetView(view, el)` |
| 6686 | `ivAbortSearch()` |
| 6692 | `ivSearchSets(q)` |
| 6737 | `ivSearchSelectSet(table)` |
| 6743 | `ivClearSetSearch()` |
| 6752 | `ivHandleGlobalSearch(q)` |
| 6753 | `ivHandleGlobalSearchInput(q)` |
| 6754 | `ivTriggerGlobalSearch(q)` |
| 6756 | `_ivRunGlobalSearch(q)` |
| 6760 | `ivOpenGlobalResult(row)` |
| 6771 | `ivPlayerSearchType(q)` |
| 6788 | `_ivPlayerAutocomplete(q)` |
| 6837 | `ivPlayerSearchGo(playerName)` |
| 6932 | `ivPlayerSearchClear()` |

### COMMUNITY / MARKET PRICES (L6946–6987)
| Line | Function |
|---|---|
| 6946 | `openCommunityPanel()` |
| 6950 | `closeCommunityPanel()` |
| 6958 | `_ivLoadMarketPrices(table)` |

### ERROR REPORT (L6988–7060)
| Line | Function |
|---|---|
| 6988 | `openErrorReport()` |
| 7008 | `closeErrorReport()` |
| 7012 | `submitErrorReport()` |

### CARD DETAIL — LIVE MARKET + VAULT CONTEXT (L7061–7172)
| Line | Function |
|---|---|
| 7061 | `_cdLoadLiveMarket(card, variationLabel)` |
| 7129 | `_cdSetMyVaultContext(fromMyVault)` |
| 7148 | `backToVault()` |

### MY ISOS (L7234–7390)
| Line | Function |
|---|---|
| 7234 | `renderMyISOs()` |
| 7269 | `filterMyISOs(filter, el)` |
| 7276 | `_renderISOList()` |
| 7311 | `_isoTimeAgo(dateStr)` |
| 7321 | `_updateMarketPrice(card, variation, newPrice, acqType, sbHeaders, SB_REST)` |

### BUG REPORT (L7391–7479)
| Line | Function |
|---|---|
| 7391 | `openBugReport()` |
| 7414 | `closeBugReport()` |
| 7419 | `submitBugReport()` |

### PWA (L7481–7548)
| Line | Function |
|---|---|
| 7521 | `hideBanner()` — nested in install banner logic |

