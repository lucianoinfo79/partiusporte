#!/usr/bin/env python3
"""PP05.8 — Qualificação de navegador real; requer playwright + Chromium."""
import argparse
import json
import re
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit, urlencode, parse_qsl

from playwright.sync_api import sync_playwright

def with_params(url, **kwargs):
    p = urlsplit(url)
    q = dict(parse_qsl(p.query, keep_blank_values=True))
    q.update(kwargs)
    return urlunsplit((p.scheme, p.netloc, p.path, urlencode(q), ""))

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--gallery-url", required=True)
    ap.add_argument("--session-id", required=True)
    ap.add_argument("--photo-id")
    ap.add_argument("--evidence-dir", default="reports/pp05_8")
    ap.add_argument("--headed", action="store_true")
    args = ap.parse_args()
    dest = Path(args.evidence_dir)
    dest.mkdir(parents=True, exist_ok=True)
    results = []
    def record(label, condition, detail=""):
        status = "PASS" if condition else "FAIL"
        results.append({"name": label, "status": status, "detail": detail})
        print(f"{status} {label}" + (f": {detail}" if detail else ""))
    with sync_playwright() as pw:
        browser = pw.chromium.launch(headless=not args.headed)
        for label, width, height in [("desktop", 1440, 900), ("mobile", 390, 844)]:
            context = browser.new_context(viewport={"width": width, "height": height},
                                          device_scale_factor=1, reduced_motion="reduce")
            page = context.new_page()
            page_errors = []
            page.on("pageerror", lambda error: page_errors.append(str(error).splitlines()[0][:160]))
            response = page.goto(args.gallery_url, wait_until="networkidle", timeout=30000)
            record(f"{label}: galeria HTTP 200", bool(response and response.status == 200),
                   f"HTTP {response.status if response else 'sem resposta'}")
            record(f"{label}: título visível", page.locator("h1").count() > 0 and page.locator("h1").first.is_visible())
            cards = page.locator(".pp-photos__card")
            count = cards.count()
            record(f"{label}: fotos publicadas", count > 0, f"cartões={count}")
            if args.photo_id:
                record(f"{label}: foto pública conhecida", args.photo_id in page.content())
            record(f"{label}: sem rolagem horizontal", page.evaluate(
                "() => document.documentElement.scrollWidth <= window.innerWidth + 2"))
            page.screenshot(path=str(dest / f"galeria_{label}.png"), full_page=True, animations="disabled")
            if count:
                open_button = page.get_by_role("button", name=re.compile("Ampliar fotografia")).first
                open_button.click()
                dialog = page.locator('dialog[data-pp05-5="protected-viewer"]')
                record(f"{label}: visualizador abre", dialog.is_visible())
                record(f"{label}: foco no botão fechar",
                       page.evaluate("() => document.activeElement?.getAttribute('aria-label')") == "Fechar visualização")
                viewer_image = dialog.locator("img")
                try:
                    viewer_image.wait_for(state="visible", timeout=10000)
                    page.wait_for_function(
                        "() => { const i=document.querySelector('dialog[data-pp05-5=\"protected-viewer\"] img'); return i && i.complete && i.naturalWidth > 0 }",
                        timeout=15000)
                    loaded = True
                except Exception:
                    loaded = False
                record(f"{label}: prévia carregada", loaded)
                record(f"{label}: navegação anterior desabilitada na primeira foto",
                       dialog.get_by_role("button", name="Fotografia anterior").is_disabled())
                page.screenshot(path=str(dest / f"visualizador_{label}.png"), animations="disabled")
                page.keyboard.press("Escape")
                record(f"{label}: Escape fecha", not dialog.is_visible())
                record(f"{label}: foco retorna ao cartão",
                       open_button.evaluate("(el) => document.activeElement === el"))
            record(f"{label}: sem exceções JavaScript", not page_errors,
                   f"exceções={len(page_errors)}")
            if label == "desktop":
                filter_url = with_params(args.gallery_url, session_id=args.session_id)
                response = page.goto(filter_url, wait_until="networkidle", timeout=30000)
                record("sessão: HTTP 200", bool(response and response.status == 200),
                       f"HTTP {response.status if response else 'sem resposta'}")
                record("sessão: seleção preservada", page.locator(
                    f'select[name="session_id"] option[value="{args.session_id}"]:checked').count() == 1)
                record("sessão: fotos publicadas", page.locator(".pp-photos__card").count() > 0)
                page.screenshot(path=str(dest / "sessao_desktop.png"), full_page=True, animations="disabled")
                # A valid UUID absent from the public options should produce an empty result,
                # or a controlled response; never treat it as a known published session.
                missing = "00000000-0000-4000-8000-000000000000"
                response = page.goto(with_params(args.gallery_url, session_id=missing),
                                     wait_until="networkidle", timeout=30000)
                record("sessão sem correspondência: HTTP 200",
                       bool(response and response.status == 200),
                       f"HTTP {response.status if response else 'sem resposta'}")
                record("sessão sem correspondência: estado vazio",
                       page.locator('[data-pp05-4="empty"]').count() == 1)
                page.screenshot(path=str(dest / "sessao_vazia_desktop.png"),
                                full_page=True, animations="disabled")
            context.close()
        browser.close()
    summary = {
        "construction": "PP05.8",
        "gallery_path": urlsplit(args.gallery_url).path,
        "checks": results,
        "passed": sum(r["status"] == "PASS" for r in results),
        "failed": sum(r["status"] == "FAIL" for r in results),
        "manual_visual_approval": "PENDING",
        "not_tested": ["álbuns reais", "paginação com mais de 24 fotos", "busca por número de peito sem flag/dados"],
        "note": "Nenhuma URL assinada, token ou corpo de resposta é persistido no JSON."
    }
    (dest / "resultado.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n",
                                        encoding="utf-8")
    print(f"Resultado: {summary['passed']} PASS / {summary['failed']} FAIL")
    print(f"Evidências: {dest}")
    return 1 if summary["failed"] else 0

if __name__ == "__main__":
    raise SystemExit(main())
