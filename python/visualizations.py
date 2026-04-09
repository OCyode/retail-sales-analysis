"""
Nigerian Retail Sales — Python Visualizations
Author : Data Analyst Portfolio Project
Tools  : pandas, matplotlib, seaborn
Run    : python python/visualizations.py
Output : saves all charts to visuals/
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.ticker as mticker
import seaborn as sns
import numpy as np
import warnings, os
warnings.filterwarnings('ignore')

# ── Config ─────────────────────────────────────────────────────────────────────
OUT = os.path.join(os.path.dirname(__file__), '..', 'visuals')
os.makedirs(OUT, exist_ok=True)

C = {
    'bg':      '#0F172A',
    'card':    '#1E293B',
    'border':  '#334155',
    'text':    '#F1F5F9',
    'sub':     '#94A3B8',
    'blue':    '#38BDF8',
    'indigo':  '#818CF8',
    'green':   '#34D399',
    'orange':  '#FB923C',
    'pink':    '#F472B6',
}
BRANCH_CLR   = {'Lekki': C['blue'],  'Ikeja': C['indigo'], 'Yaba': C['green']}
CATEGORY_CLR = {'Electronics': C['blue'], 'Groceries': C['green'], 'Clothing': C['pink']}

plt.rcParams.update({
    'figure.facecolor':  C['bg'],
    'axes.facecolor':    C['card'],
    'axes.edgecolor':    C['border'],
    'axes.labelcolor':   C['text'],
    'axes.titlecolor':   C['text'],
    'xtick.color':       C['sub'],
    'ytick.color':       C['sub'],
    'text.color':        C['text'],
    'grid.color':        C['border'],
    'grid.linewidth':    0.6,
    'font.family':       'DejaVu Sans',
    'legend.facecolor':  C['card'],
    'legend.edgecolor':  C['border'],
})

def save(fig, name):
    path = os.path.join(OUT, name)
    fig.savefig(path, dpi=150, bbox_inches='tight', facecolor=C['bg'])
    plt.close(fig)
    print(f'  saved → {name}')

# ── Load & prep ─────────────────────────────────────────────────────────────────
df = pd.read_excel(
    os.path.join(os.path.dirname(__file__), '..', 'data', 'retail_sales_cleaned.xlsx')
)
df['margin_%'] = df['margin_%'] * 100
df['month']    = df['date'].dt.to_period('M').dt.to_timestamp()
df['month_lbl']= df['date'].dt.strftime('%b %Y')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 1 — Executive KPI Cards
# ══════════════════════════════════════════════════════════════════════════════
total_rev    = df['revenue'].sum()
total_profit = df['profit'].sum()
avg_margin   = df['margin_%'].mean()
total_txns   = len(df)

fig, axes = plt.subplots(1, 4, figsize=(18, 3.8))
fig.patch.set_facecolor(C['bg'])
kpis = [
    ('Total Revenue',     f'₦{total_rev/1e6:.1f}M',    C['blue']),
    ('Total Profit',      f'₦{total_profit/1e6:.1f}M', C['green']),
    ('Avg Gross Margin',  f'{avg_margin:.1f}%',          C['indigo']),
    ('Transactions',      f'{total_txns:,}',              C['orange']),
]
for ax, (label, val, col) in zip(axes, kpis):
    ax.set_facecolor(C['card'])
    for sp in ax.spines.values():
        sp.set_edgecolor(col)
        sp.set_linewidth(2.5)
    ax.set_xticks([]); ax.set_yticks([])
    ax.text(0.5, 0.65, val,   ha='center', va='center',
            fontsize=27, fontweight='bold', color=col, transform=ax.transAxes)
    ax.text(0.5, 0.28, label, ha='center', va='center',
            fontsize=11, color=C['sub'], transform=ax.transAxes)
plt.tight_layout(pad=1.5)
save(fig, '01_kpi_cards.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 2 — Monthly Revenue & Profit Trend
# ══════════════════════════════════════════════════════════════════════════════
monthly = df.groupby('month')[['revenue', 'profit']].sum().reset_index()
monthly['lbl'] = monthly['month'].dt.strftime('%b %Y')

fig, ax = plt.subplots(figsize=(14, 5))
ax.plot(monthly['lbl'], monthly['revenue']/1e6, marker='o', color=C['blue'],
        linewidth=2.5, markersize=8, label='Revenue', zorder=3)
ax.fill_between(monthly['lbl'], monthly['revenue']/1e6, alpha=0.1, color=C['blue'])
ax.plot(monthly['lbl'], monthly['profit']/1e6, marker='s', color=C['green'],
        linewidth=2.5, markersize=8, label='Profit', zorder=3)
ax.fill_between(monthly['lbl'], monthly['profit']/1e6, alpha=0.1, color=C['green'])

# Annotate peak
peak_idx = monthly['revenue'].idxmax()
ax.annotate(
    f"Peak: ₦{monthly.loc[peak_idx,'revenue']/1e6:.1f}M",
    xy=(monthly.loc[peak_idx,'lbl'], monthly.loc[peak_idx,'revenue']/1e6),
    xytext=(0, 18), textcoords='offset points',
    ha='center', fontsize=9, color=C['orange'],
    arrowprops=dict(arrowstyle='->', color=C['orange'], lw=1.2)
)

ax.set_title('Monthly Revenue & Profit  (Jan – Jun 2025)', fontsize=14, pad=14)
ax.set_ylabel('Amount (₦ Millions)', fontsize=11)
ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₦{x:.0f}M'))
ax.grid(axis='y', linestyle='--', alpha=0.45)
ax.legend(fontsize=11)
plt.tight_layout()
save(fig, '02_monthly_trend.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 3 — Branch Performance: Revenue vs Profit (Grouped Horizontal Bar)
# ══════════════════════════════════════════════════════════════════════════════
br = df.groupby('branch').agg(revenue=('revenue','sum'), profit=('profit','sum')).sort_values('revenue')
y  = np.arange(len(br))

fig, ax = plt.subplots(figsize=(11, 4))
ax.barh(y + 0.2, br['revenue']/1e6, 0.38,
        color=[BRANCH_CLR[b] for b in br.index], alpha=0.9, label='Revenue')
ax.barh(y - 0.2, br['profit']/1e6,  0.38,
        color=[BRANCH_CLR[b] for b in br.index], alpha=0.45, label='Profit')
ax.set_yticks(y)
ax.set_yticklabels(br.index, fontsize=12)
for i, (branch, row) in enumerate(br.iterrows()):
    ax.text(row['revenue']/1e6 + 0.4, i + 0.2,
            f'₦{row["revenue"]/1e6:.1f}M', va='center', fontsize=10, color=C['text'])
ax.set_title('Branch Performance: Revenue vs Profit', fontsize=14, pad=14)
ax.set_xlabel('Amount (₦ Millions)', fontsize=11)
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₦{x:.0f}M'))
ax.grid(axis='x', linestyle='--', alpha=0.45)
ax.legend(fontsize=11)
plt.tight_layout()
save(fig, '03_branch_performance.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 4 — Revenue Share by Category (Donut)
# ══════════════════════════════════════════════════════════════════════════════
cat = df.groupby('category')['revenue'].sum()
colors = [CATEGORY_CLR[c] for c in cat.index]

fig, ax = plt.subplots(figsize=(8, 7))
wedges, texts, autotexts = ax.pie(
    cat, labels=cat.index, autopct='%1.1f%%',
    colors=colors, startangle=140,
    wedgeprops=dict(width=0.52, edgecolor=C['bg'], linewidth=2.5),
    textprops=dict(color=C['text'], fontsize=12),
    pctdistance=0.76,
)
for at in autotexts:
    at.set_fontweight('bold'); at.set_fontsize(11)
ax.text(0, 0, f'₦{cat.sum()/1e6:.1f}M\nTotal',
        ha='center', va='center', fontsize=13, fontweight='bold', color=C['text'])
ax.set_title('Revenue Share by Category', fontsize=14, pad=14)
plt.tight_layout()
save(fig, '04_category_donut.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 5 — Revenue by Product
# ══════════════════════════════════════════════════════════════════════════════
prod = df.groupby(['product_name','category'])['revenue'].sum().reset_index().sort_values('revenue', ascending=True)
bar_colors = [CATEGORY_CLR[c] for c in prod['category']]

fig, ax = plt.subplots(figsize=(12, 6))
bars = ax.barh(prod['product_name'], prod['revenue']/1e6,
               color=bar_colors, alpha=0.9, edgecolor=C['bg'])
for bar in bars:
    ax.text(bar.get_width() + 0.3, bar.get_y() + bar.get_height()/2,
            f'₦{bar.get_width():.1f}M', va='center', fontsize=10, color=C['text'])
ax.set_title('Revenue by Product', fontsize=14, pad=14)
ax.set_xlabel('Revenue (₦ Millions)', fontsize=11)
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₦{x:.0f}M'))
ax.grid(axis='x', linestyle='--', alpha=0.45)
legend_patches = [mpatches.Patch(color=CATEGORY_CLR[c], label=c) for c in CATEGORY_CLR]
ax.legend(handles=legend_patches, fontsize=10, title='Category', title_fontsize=10)
plt.tight_layout()
save(fig, '05_product_revenue.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 6 — Gross Margin % by Product (with portfolio average line)
# ══════════════════════════════════════════════════════════════════════════════
margins = df.groupby(['product_name','category'])['margin_%'].mean().reset_index().sort_values('margin_%', ascending=True)
bar_colors6 = [CATEGORY_CLR[c] for c in margins['category']]
avg_m = margins['margin_%'].mean()

fig, ax = plt.subplots(figsize=(12, 5.5))
ax.barh(margins['product_name'], margins['margin_%'],
        color=bar_colors6, alpha=0.85, edgecolor=C['bg'])
ax.axvline(avg_m, color=C['orange'], linestyle='--', linewidth=1.8,
           label=f'Portfolio Avg: {avg_m:.1f}%')
for _, row in margins.iterrows():
    ax.text(row['margin_%'] + 0.4,
            list(margins['product_name']).index(row['product_name']),
            f'{row["margin_%"]:.1f}%', va='center', fontsize=10, color=C['text'])
ax.set_title('Average Gross Margin % by Product', fontsize=14, pad=14)
ax.set_xlabel('Gross Margin (%)', fontsize=11)
ax.grid(axis='x', linestyle='--', alpha=0.45)
legend_patches = [mpatches.Patch(color=CATEGORY_CLR[c], label=c) for c in CATEGORY_CLR]
ax.legend(handles=legend_patches + [mpatches.Patch(color=C['orange'],
          label=f'Portfolio Avg ({avg_m:.1f}%)')], fontsize=10)
plt.tight_layout()
save(fig, '06_margin_by_product.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 7 — Stacked Monthly Revenue by Branch
# ══════════════════════════════════════════════════════════════════════════════
mb = df.pivot_table(index='month', columns='branch', values='revenue', aggfunc='sum').fillna(0)
mb.index = mb.index.strftime('%b %Y')

fig, ax = plt.subplots(figsize=(14, 5.5))
bottom = np.zeros(len(mb))
for branch, col in BRANCH_CLR.items():
    if branch in mb.columns:
        vals = mb[branch].values / 1e6
        ax.bar(mb.index, vals, bottom=bottom, color=col, label=branch,
               alpha=0.88, edgecolor=C['bg'], linewidth=0.5)
        bottom += vals
ax.set_title('Monthly Revenue by Branch  (Stacked)', fontsize=14, pad=14)
ax.set_ylabel('Revenue (₦ Millions)', fontsize=11)
ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₦{x:.0f}M'))
ax.grid(axis='y', linestyle='--', alpha=0.45)
ax.legend(fontsize=11)
plt.tight_layout()
save(fig, '07_stacked_branch_monthly.png')


# ══════════════════════════════════════════════════════════════════════════════
# CHART 8 — Revenue vs Margin Scatter (Opportunity Quadrant)
# ══════════════════════════════════════════════════════════════════════════════
prod_scatter = df.groupby(['product_name','category']).agg(
    revenue=('revenue','sum'), margin=('margin_%','mean')
).reset_index()

fig, ax = plt.subplots(figsize=(11, 7))
for _, row in prod_scatter.iterrows():
    ax.scatter(row['revenue']/1e6, row['margin'],
               color=CATEGORY_CLR[row['category']], s=180, zorder=3, alpha=0.9)
    ax.annotate(row['product_name'],
                xy=(row['revenue']/1e6, row['margin']),
                xytext=(6, 4), textcoords='offset points',
                fontsize=9, color=C['text'])

# Quadrant lines
med_rev  = prod_scatter['revenue'].median() / 1e6
med_mar  = prod_scatter['margin'].median()
ax.axvline(med_rev, color=C['border'], linestyle='--', linewidth=1.2)
ax.axhline(med_mar, color=C['border'], linestyle='--', linewidth=1.2)

# Quadrant labels
ax.text(0.02, 0.97, 'High Margin\nLow Revenue\n→ Grow these',
        transform=ax.transAxes, fontsize=8.5, va='top', color=C['orange'],
        bbox=dict(boxstyle='round,pad=0.3', facecolor=C['card'], edgecolor=C['orange'], alpha=0.8))
ax.text(0.58, 0.97, 'High Margin\nHigh Revenue\n→ Protect these',
        transform=ax.transAxes, fontsize=8.5, va='top', color=C['green'],
        bbox=dict(boxstyle='round,pad=0.3', facecolor=C['card'], edgecolor=C['green'], alpha=0.8))
ax.text(0.02, 0.22, 'Low Margin\nLow Revenue\n→ Review',
        transform=ax.transAxes, fontsize=8.5, va='top', color=C['sub'],
        bbox=dict(boxstyle='round,pad=0.3', facecolor=C['card'], edgecolor=C['border'], alpha=0.8))
ax.text(0.58, 0.22, 'Low Margin\nHigh Revenue\n→ Optimise costs',
        transform=ax.transAxes, fontsize=8.5, va='top', color=C['indigo'],
        bbox=dict(boxstyle='round,pad=0.3', facecolor=C['card'], edgecolor=C['indigo'], alpha=0.8))

legend_patches = [mpatches.Patch(color=CATEGORY_CLR[c], label=c) for c in CATEGORY_CLR]
ax.legend(handles=legend_patches, fontsize=10)
ax.set_title('Product Opportunity Matrix: Revenue vs Margin', fontsize=14, pad=14)
ax.set_xlabel('Total Revenue (₦ Millions)', fontsize=11)
ax.set_ylabel('Avg Gross Margin (%)', fontsize=11)
ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₦{x:.0f}M'))
ax.grid(linestyle='--', alpha=0.35)
plt.tight_layout()
save(fig, '08_opportunity_matrix.png')


print(f'\nAll 8 charts saved to: {os.path.abspath(OUT)}')
