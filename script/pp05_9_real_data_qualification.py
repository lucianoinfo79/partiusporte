#!/usr/bin/env python3
"""PP05.9 — read-only live-data qualification for Atlas ↔ PartilProva."""
import argparse
import json
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode, urlsplit, urlunsplit, parse_qsl
from urllib.request import Request, urlopen

def request(url, query=None):
    if query:
        p=urlsplit(url)
        q=dict(parse_qsl(p.query, keep_blank_values=True))
        q.update({k:str(v) for k,v in query.items()})
        url=urlunsplit((p.scheme,p.netloc,p.path,urlencode(q),""))
    try:
        with urlopen(Request(url,headers={"Accept":"application/json, text/html;q=0.8",
                                         "User-Agent":"PartilProva-PP05.9-qualification"}),
                     timeout=25) as r:
            return r.status,r.read(3_000_000)
    except HTTPError as e:
        return e.code,e.read(4096)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--atlas-url",default="http://localhost:3000")
    ap.add_argument("--partilprova-url",default="http://localhost:3001")
    ap.add_argument("--event",required=True)
    ap.add_argument("--session-id")
    ap.add_argument("--album-id")
    ap.add_argument("--bib-number")
    ap.add_argument("--per-page",type=int,default=24)
    ap.add_argument("--report",default="reports/pp05_9_real_data.json")
    args=ap.parse_args()
    api=args.atlas_url.rstrip()+"/api/public/v1/events/"+args.event+"/photos"
    gallery=args.partilprova_url.rstrip()+"/eventos/"+args.event+"/fotos"
    checks=[]
    def check(name,ok,detail=""):
        checks.append({"name":name,"status":"PASS" if ok else "FAIL","detail":detail})
        print(("PASS" if ok else "FAIL")+" "+name+(": "+detail if detail else ""))
    def skip(name,reason):
        checks.append({"name":name,"status":"SKIP","detail":reason})
        print("SKIP "+name+": "+reason)
    def fetch(params=None):
        status,body=request(api,params)
        if status!=200:
            return status,{},{}
        try:
            payload=json.loads(body)
            return status,payload.get("data",{}),payload.get("meta",{})
        except (ValueError,AttributeError):
            return status,{},{}
    def photo_ids(data):
        return {p["id"] for p in data.get("photos",[]) if isinstance(p,dict) and isinstance(p.get("id"),str)}
    status,data,meta=fetch({"page":1,"per_page":args.per_page})
    check("Atlas API publica HTTP 200",status==200,f"HTTP {status}")
    check("Evento publicado",data.get("published") is True)
    ids=photo_ids(data)
    total=meta.get("total")
    check("Metadados de paginação",isinstance(total,int) and total>=len(ids),
          f"total={total if isinstance(total,int) else 'indisponível'}")
    check("IDs públicos na primeira página",len(ids)==len(data.get("photos",[])) and bool(ids),
          f"fotos={len(ids)}")
    status_html,html=request(gallery)
    check("PartilProva galeria HTTP 200",status_html==200,f"HTTP {status_html}")
    check("Primeira foto visível no HTML",bool(ids) and any(x.encode() in html for x in ids))
    filters=data.get("filters") if isinstance(data.get("filters"),dict) else {}
    sessions=filters.get("sessions",[]) if isinstance(filters.get("sessions"),list) else []
    albums=filters.get("albums",[]) if isinstance(filters.get("albums"),list) else []
    print(f"INVENTÁRIO total_publicado={total} sessoes_publicas={len(sessions)} albuns_publicos={len(albums)}")
    if args.session_id:
        valid=any(isinstance(s,dict) and s.get("id")==args.session_id for s in sessions)
        check("Sessão disponível nas opções públicas",valid)
        ss,sd,sm=fetch({"session_id":args.session_id})
        check("Atlas filtro por sessão HTTP 200",ss==200,f"HTTP {ss}")
        hs,hh=request(gallery,{"session_id":args.session_id})
        check("PartilProva filtro por sessão HTTP 200",hs==200,f"HTTP {hs}")
        sids=photo_ids(sd)
        check("Fotografias da sessão presentes no HTML",all(x.encode() in hh for x in sids),
              f"fotos_filtradas={len(sids)}")
        check("Total da sessão coerente",isinstance(sm.get("total"),int) and sm["total"]>=len(sids))
    else:
        skip("Filtro por sessão","informe --session-id de sessão pública")
    if args.album_id:
        valid=any(isinstance(a,dict) and a.get("id")==args.album_id for a in albums)
        check("Álbum disponível nas opções públicas",valid)
        ast,ad,am=fetch({"album_id":args.album_id})
        check("Atlas filtro por álbum HTTP 200",ast==200,f"HTTP {ast}")
        hs,hh=request(gallery,{"album_id":args.album_id})
        check("PartilProva filtro por álbum HTTP 200",hs==200,f"HTTP {hs}")
        aids=photo_ids(ad)
        check("Fotos do álbum presentes no HTML",all(x.encode() in hh for x in aids),
              f"fotos_filtradas={len(aids)}")
        if args.session_id:
            both_status,both,both_meta=fetch({"album_id":args.album_id,"session_id":args.session_id})
            both_ids=photo_ids(both)
            check("Atlas filtro combinado HTTP 200",both_status==200)
            check("Filtro combinado AND",both_ids.issubset(aids & (sids if args.session_id else set())),
                  f"fotos_combinadas={len(both_ids)}")
            hs,hh=request(gallery,{"album_id":args.album_id,"session_id":args.session_id})
            check("PartilProva filtro combinado HTTP 200",hs==200)
            check("Filtro combinado visível",all(x.encode() in hh for x in both_ids))
        else:
            skip("Filtro combinado","informe --session-id também")
    else:
        skip("Filtro por álbum","não foi informado álbum público real")
        skip("Filtro combinado AND","exige álbum e sessão reais")
    if isinstance(total,int) and total>args.per_page:
        second_status,second,second_meta=fetch({"page":2,"per_page":args.per_page})
        second_ids=photo_ids(second)
        check("Atlas segunda página HTTP 200",second_status==200)
        check("Atlas segunda página não vazia",bool(second_ids))
        check("Páginas sem duplicação de IDs",ids.isdisjoint(second_ids))
        hs,hh=request(gallery,{"page":2})
        check("PartilProva segunda página HTTP 200",hs==200)
        check("Fotos da segunda página no HTML",bool(second_ids) and all(x.encode() in hh for x in second_ids))
    else:
        skip("Paginação real",f"exige pelo menos {args.per_page+1} fotografias publicadas; total={total}")
    if args.bib_number:
        bs,bd,bm=fetch({"bib_number":args.bib_number})
        check("Atlas busca por número de peito HTTP 200",bs==200,f"HTTP {bs}")
        hs,hh=request(gallery,{"bib_number":args.bib_number})
        check("PartilProva busca por número de peito HTTP 200",hs==200,f"HTTP {hs}")
        check("Fotos do número de peito no HTML",all(x.encode() in hh for x in photo_ids(bd)))
    else:
        skip("Busca por número de peito","exige número real e feature flag habilitada")
    passed=sum(x["status"]=="PASS" for x in checks)
    failed=sum(x["status"]=="FAIL" for x in checks)
    skipped=sum(x["status"]=="SKIP" for x in checks)
    result={"construction":"PP05.9","event":args.event,"inventory":{
        "published_total":total,"public_session_count":len(sessions),"public_album_count":len(albums)},
        "passed":passed,"failed":failed,"skipped":skipped,"checks":checks,
        "qualification":"FAIL" if failed else ("PARTIAL" if skipped else "PASS"),
        "privacy":"No preview URLs, tokens, API response bodies or photographs are stored"}
    dest=Path(args.report);dest.parent.mkdir(parents=True,exist_ok=True)
    dest.write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(f"RESULTADO {passed} PASS / {failed} FAIL / {skipped} SKIP — {result['qualification']}")
    print(f"RELATÓRIO {dest}")
    return 1 if failed else 0
if __name__=="__main__":
    sys.exit(main())
