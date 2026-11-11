#!/usr/bin/env python3
"""PP05.7: read-only HTML/HTTP gallery qualification, no external dependencies."""
import argparse, json, re, urllib.request, urllib.parse, urllib.error
from html.parser import HTMLParser
from pathlib import Path

class Scan(HTMLParser):
    def __init__(self):
        super().__init__(); self.tags=[]; self.text=[]
    def handle_starttag(self, tag, attrs): self.tags.append((tag,dict(attrs)))
    def handle_data(self, data): self.text.append(data)

def fetch(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'PP05.7-Qualification/1.0'}),timeout=20) as r:
            return r.status,r.read(3_000_000).decode('utf-8','replace'),r.headers.get('content-type','')
    except urllib.error.HTTPError as e: return e.code,'',e.headers.get('content-type','')
    except (urllib.error.URLError,ValueError,TimeoutError) as e: return 0,'',type(e).__name__

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--gallery-url',required=True,help='URL real da galeria PartilProva')
    p.add_argument('--photo-id',help='UUID público da foto conhecida; opcional')
    p.add_argument('--session-id',help='UUID público de sessão para teste de filtro; opcional')
    p.add_argument('--bib',help='Número de peito real; opcional')
    p.add_argument('--evidence',default='reports/pp05_7_gallery_qualification.json')
    a=p.parse_args(); results=[]
    def check(name,ok,detail=''):
        results.append({'check':name,'status':'PASS' if ok else 'FAIL','detail':detail});print(('PASS' if ok else 'FAIL')+' '+name+((': '+detail) if detail else ''))
    def inspect(url):
        status,body,ctype=fetch(url); h=Scan();h.feed(body); return status,body,ctype,h
    base=a.gallery_url
    status,body,ctype,h=inspect(base)
    check('Galeria HTTP 200',status==200,'HTTP '+str(status))
    check('Galeria HTML', 'text/html' in ctype)
    check('Título e navegação', any(t=='h1' for t,x in h.tags) and any(t=='nav' for t,x in h.tags))
    cards=[x for t,x in h.tags if t=='article' and 'pp-photos__card' in x.get('class','')]
    check('Cartões de fotografias presentes',len(cards)>0,'cartões='+str(len(cards)))
    check('Visualizador protegido disponível',any(t=='dialog' and x.get('data-pp05-5')=='protected-viewer' for t,x in h.tags))
    check('Acessibilidade: ampliar e fechar',any(t=='button' and x.get('aria-label','').startswith('Ampliar fotografia') for t,x in h.tags) and any(t=='button' and x.get('aria-label')=='Fechar visualização' for t,x in h.tags))
    previews=[x for t,x in h.tags if t=='img' and 'Prévia protegida de foto da prova' in x.get('alt','')]
    check('Prévia com texto alternativo',bool(previews))
    check('Referer restrito nas prévias',bool(previews) and all(x.get('referrerpolicy')=='no-referrer' for x in previews))
    if a.photo_id: check('Fotografia pública presente no HTML',a.photo_id in body)
    if a.session_id:
        url=base+('&' if '?' in base else '?')+urllib.parse.urlencode({'session_id':a.session_id})
        st,b,ct,sh=inspect(url)
        check('Filtro de sessão HTTP 200',st==200,'HTTP '+str(st))
        check('Filtro de sessão mantém galeria',any(t=='h1' for t,x in sh.tags))
    if a.bib:
        url=base+('&' if '?' in base else '?')+urllib.parse.urlencode({'bib_number':a.bib})
        st,b,ct,bh=inspect(url)
        check('Busca por peito HTTP 200',st==200,'HTTP '+str(st))
        check('Busca por peito entrega HTML', 'text/html' in ct)
    evidence={'construction':'PP05.7','gallery_path':urllib.parse.urlsplit(base).path,'checks':results,'passed':sum(x['status']=='PASS' for x in results),'failed':sum(x['status']=='FAIL' for x in results),'manual_browser_qualification':'PENDING'}
    path=Path(a.evidence);path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(evidence,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Evidência sem URLs assinadas: '+str(path));return 1 if evidence['failed'] else 0
if __name__=='__main__': raise SystemExit(main())
