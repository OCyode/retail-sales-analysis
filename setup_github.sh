#!/usr/bin/env bash
# ================================================================
#  setup_github.sh
#  Run from inside the retail-sales-analysis/ folder.
#  Creates a clean commit history and pushes to GitHub.
#
#  Prerequisites:
#    - Git installed  (git --version)
#    - GitHub account with an empty repo already created
# ================================================================

set -e

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓  $1${NC}"; }
info() { echo -e "${CYAN}➜  $1${NC}"; }
warn() { echo -e "${YELLOW}⚠  $1${NC}"; }

echo ""
echo "================================================"
echo "  Retail Sales Analysis — GitHub Setup"
echo "================================================"
echo ""

read -rp "GitHub username          : " GH_USER
read -rp "Repo name (no spaces)    : " REPO_NAME
read -rp "Your name (for git)      : " GIT_NAME
read -rp "Your email (for git)     : " GIT_EMAIL

REMOTE="https://github.com/${GH_USER}/${REPO_NAME}.git"

# ── Init ──────────────────────────────────────────────────────
info "Initialising git..."
git init
git config user.name  "$GIT_NAME"
git config user.email "$GIT_EMAIL"
ok "Git ready"

# ── Commit 1: Scaffold ────────────────────────────────────────
info "Commit 1/5: Project scaffold & config..."
git add .gitignore requirements.txt
git commit -m "chore: add project scaffold

- .gitignore covering Python, Power BI temp files, OS artefacts, IDEs
- requirements.txt with pinned dependencies (pandas, matplotlib, seaborn, openpyxl)"
ok "Commit 1 done"

# ── Commit 2: Data ────────────────────────────────────────────
info "Commit 2/5: Add source dataset..."
git add data/
git commit -m "data: add cleaned retail sales dataset (Jan-Jun 2025)

294 transactions across 3 Lagos branches (Lekki, Ikeja, Yaba).
9 products across Electronics, Groceries, and Clothing categories.
Zero nulls, zero duplicates. Ready for analysis."
ok "Commit 2 done"

# ── Commit 3: SQL ─────────────────────────────────────────────
info "Commit 3/5: Add SQL analysis..."
git add sql/
git commit -m "feat(sql): add full SQL analysis (8 sections)

Covers:
- Section 0: Table setup DDL
- Section 1: Data quality checks (nulls, duplicates, date range)
- Section 2: Executive KPIs
- Section 3: Monthly trend + MoM growth using LAG()
- Section 4: Branch scorecard + pivot + Yaba deep-dive
- Section 5: Category analysis with RANK() window functions
- Section 6: Product leaderboard + best seller per branch
- Section 7: Advanced — CTE running total, ABC classification
- Section 8: Reusable views for Power BI / Python consumption

Compatible with SQLite, PostgreSQL, and MySQL (dialect notes inline)."
ok "Commit 3 done"

# ── Commit 4: Python visuals ──────────────────────────────────
info "Commit 4/5: Add Python visualizations..."
git add python/ visuals/
git commit -m "feat(python): add visualization script + 8 charts

Script: python/visualizations.py
Charts (150 DPI, dark theme):
  01 KPI cards            — headline metrics
  02 Monthly trend        — revenue & profit line chart with peak annotation
  03 Branch performance   — grouped horizontal bar
  04 Category donut       — revenue share
  05 Product revenue      — ranked horizontal bar
  06 Margin by product    — with portfolio average reference line
  07 Stacked monthly      — revenue by branch over time
  08 Opportunity matrix   — revenue vs margin scatter with quadrant labels

All charts mirror the SQL aggregations in section 4-7."
ok "Commit 4 done"

# ── Commit 5: Docs ────────────────────────────────────────────
info "Commit 5/5: Add Power BI guide, docs, and README..."
git add powerbi/ docs/ README.md
git commit -m "docs: add README, Power BI setup guide, and analysis summary

README.md:
- Badges: SQL, Python, Pandas, Power BI
- Dashboard visual preview table
- Business questions answered
- Key findings (5 data-backed insights)
- Recommendations table with rationale
- How to run (SQL / Python / Power BI)

powerbi/dashboard_setup_guide.md:
- Load + Power Query transformation steps
- 12 DAX measures (KPIs, MoM growth, branch vs average, cumulative)
- 4-page layout spec with visual types and field mappings
- Colour palette to match Python charts

docs/analysis_summary.md:
- Full narrative writeup
- Monthly, branch, category, and product tables
- ABC classification explanation
- 5 prioritised recommendations with quantified impact"
ok "Commit 5 done"

# ── Remote + push ─────────────────────────────────────────────
info "Setting remote to: $REMOTE"
git branch -M main
git remote add origin "$REMOTE"

echo ""
warn "Before continuing, confirm your GitHub repo is:"
echo "  URL    : https://github.com/${GH_USER}/${REPO_NAME}"
echo "  Public : yes"
echo "  Empty  : yes (no README, no .gitignore initialised on GitHub)"
echo ""
read -rp "All good? Push now? (y/n): " PUSH

if [[ "$PUSH" == "y" || "$PUSH" == "Y" ]]; then
    git push -u origin main
    echo ""
    ok "Live at: https://github.com/${GH_USER}/${REPO_NAME}"
else
    warn "Skipped. Push manually when ready:"
    echo "  git push -u origin main"
fi

echo ""
echo "================================================"
echo "  AFTER PUSHING: 5-minute GitHub polish"
echo "================================================"
echo ""
echo "  1. Repo → gear icon next to About → add:"
echo "     Description : End-to-end retail sales analysis using SQL,"
echo "                   Python & Power BI. 3 Lagos branches, 6 months."
echo "     Topics      : data-analysis sql python pandas power-bi eda"
echo "                   retail-analytics portfolio-project lagos nigeria"
echo ""
echo "  2. Pin this repo on your GitHub profile"
echo ""
echo "  3. Create a Release: v1.0.0"
echo "     Title: Initial Analysis — Jan-Jun 2025"
echo "     Attach the ZIP if you want recruiters to download everything at once"
echo ""
echo "  4. Share on LinkedIn (see docs/ for post templates)"
echo ""
