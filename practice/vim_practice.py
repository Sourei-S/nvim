#!/usr/bin/env python3
# =====================================================================
#  vim_practice.py -- vim 練習用ダミーコード
# =====================================================================
#  架空の「製品カタログ組版ツール」風のコードです。
#  練習台なので、自由に壊してください。
#  お題とチートシートは vim_practice_menu.md にあります。
#
#  元に戻す: u (undo) / :e! (最後に保存した時点まで戻す)
# =====================================================================
"""Dummy catalog build pipeline for vim practice."""

import json
import os
import sys
from datetime import date

CATALOG_TITLE = "Industrial Pump Catalog 2026"
OUTPUT_DIR = "./dist"
PAGE_WIDTH_MM = 210
PAGE_HEIGHT_MM = 297
DEFAULT_DPI = 350
PAPER_NOTE = "trim: A4 (210 x 297 mm) / margins: outer (10 mm), gutter (15 mm)"
LEGAL_NOTICE = "Specifications are subject to change without notice. All trademarks are the property of their respective owners. Printed in Japan."

# --- 製品マスタ(ダミー) ----------------------------------------------
products = [
    {"id": "PMP-001", "name": "Compact Pump A100",    "price": 128000, "stock": 12},
    {"id": "PMP-002", "name": "Compact Pump A200",    "price": 156000, "stock": 8},
    {"id": "PMP-003", "name": "Standard Pump B100",   "price": 248000, "stock": 5},
    {"id": "PMP-004", "name": "Standard Pump B200",   "price": 298000, "stock": 0},
    {"id": "PMP-005", "name": "Heavy Duty Pump C100", "price": 512000, "stock": 3},
    {"id": "PMP-006", "name": "Heavy Duty Pump C200", "price": 598000, "stock": 1},
]

# --- 章立て(マクロ練習にどうぞ) --------------------------------------
chapter_01 = "Overview"
chapter_02 = "Installation"
chapter_03 = "Operation"
chapter_04 = "Maintenance"
chapter_05 = "Troubleshooting"
chapter_06 = "Specifications"

# TODO: rename legacy field "stock" to "inventory"
# TODO: split price table into a separate module
# FIXME: sold-out products should be hidden from the index page


def load_products(path):
    """JSON ファイルから製品リストを読み込む。"""
    with open(path, encoding="utf-8") as fp:
        return json.load(fp)


def format_price(price):
    """価格をカンマ区切り + 通貨表記にする。"""
    return f"{price:,} JPY"


def slugify(name):
    """製品名を URL 用スラッグに変換する。"""
    return name.lower().replace(" ", "-")


class CatalogPage:
    """カタログ 1 ページ分のダミーモデル。"""

    def __init__(self, number, title):
        self.number = number
        self.title = title
        self.blocks = []

    def add_block(self, kind, content):
        self.blocks.append({"kind": kind, "content": content})

    def render(self):
        lines = [f"--- page {self.number:02d}: {self.title} ---"]
        for block in self.blocks:
            lines.append(f"  [{block['kind']:<8}] {block['content']}")
        return "\n".join(lines)


def build_catalog(items):
    """製品リストからページ一覧を組み立てる。"""
    pages = []
    for index, item in enumerate(items, start=1):
        page = CatalogPage(index, item["name"])
        page.add_block("heading", item["name"])
        page.add_block("spec", "ID: " + item["id"])
        page.add_block("price", format_price(item["price"]))
        page.add_block("url", "/products/" + slugify(item["name"]))
        if item["stock"] == 0:
            page.add_block("notice", "Sold out")
        elif item["stock"] <= 3:
            page.add_block("notice", "Low stock")
        pages.append(page)
    return pages


def summarize(items):
    """在庫金額の合計などを集計する(カッコの対応は % で辿れる)。"""
    total_value = sum((item["price"] * max(item["stock"], 0)) for item in items)
    sold_out = [item["id"] for item in items if item["stock"] == 0]
    return {"total_value": total_value, "sold_out": sold_out, "count": len(items)}


if __name__ == "__main__":
    catalog = build_catalog(products)
    for page in catalog:
        print(page.render())
    print("-" * 60)
    print("summary:", json.dumps(summarize(products)))
    print("built on", date.today().isoformat(), "->", os.path.join(OUTPUT_DIR, "catalog.txt"))
