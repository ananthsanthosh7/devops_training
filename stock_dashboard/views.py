from __future__ import annotations

from typing import Any

import yfinance as yf
from django.http import HttpRequest, HttpResponse
from django.shortcuts import render
from django.views.decorators.cache import cache_page


def format_change(change: float | None) -> str:
    if change is None:
        return 'N/A'
    return f'{change:+.2f}'


def format_percentage(change_pct: float | None) -> str:
    if change_pct is None:
        return 'N/A'
    return f'{change_pct:+.2f}%'


@cache_page(60)
def index(request: HttpRequest) -> HttpResponse:
    symbols = ['AAPL', 'MSFT', 'GOOG', 'TSLA', 'INFY.NS', 'TCS.NS']
    market_data: list[dict[str, Any]] = []

    for symbol in symbols:
        try:
            ticker = yf.Ticker(symbol)
            info = ticker.fast_info
            quote = ticker.info

            current_price = quote.get('regularMarketPrice') or info.get('lastPrice')
            previous_close = quote.get('regularMarketPreviousClose') or info.get('previousClose')

            if current_price is None:
                continue

            price_change = None
            change_pct = None
            if previous_close not in (None, 0):
                price_change = current_price - previous_close
                change_pct = (price_change / previous_close) * 100

            market_data.append(
                {
                    'symbol': symbol,
                    'company': quote.get('shortName', symbol),
                    'price': current_price,
                    'change': price_change,
                    'change_pct': change_pct,
                    'currency': quote.get('currency', 'USD'),
                }
            )
        except Exception:
            continue

    market_data.sort(key=lambda item: item['symbol'])
    context = {
        'market_data': market_data,
        'updated_at': 'Live feed from Yahoo Finance',
        'page_title': 'Stock Market Dashboard',
    }
    return render(request, 'dashboard/index.html', context)


def health_check(request: HttpRequest) -> HttpResponse:
    return HttpResponse('OK', content_type='text/plain')
