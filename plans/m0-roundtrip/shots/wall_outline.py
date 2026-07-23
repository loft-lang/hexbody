import math
from PIL import Image, ImageDraw
S3=math.sqrt(3.0); t=1.0/3.0
U=(t*S3/2,t/2); V=(0.0,t); TH=t*S3/2
def P(a,b): return (a*U[0]+b*V[0], a*U[1]+b*V[1])
def corner(k): a=math.radians(30+60*k); return (math.cos(a), math.sin(a))
wid,dep=5,4; hw,hd=wid*S3/2, dep*S3/2
def ins(k,m): return 2*abs(k)<=2*wid+1 and m*m<=3*dep*dep
cells=[(2*q+(r&1),3*r) for r in range(-6,7) for q in range(-9,10) if ins(2*q+(r&1),3*r)]
cs=set(cells)
def cw(k,m): return (k*S3/2, m/2)
CORN=[(1,1),(0,2),(-1,1),(-1,-1),(0,-2),(1,-1)]
NB={(2,0):(0,5),(1,3):(1,0),(-1,3):(2,1),(-2,0):(3,2),(-1,-3):(4,3),(1,-3):(5,4)}
sides={0:[],1:[],2:[],3:[]}
for (k,m) in cells:
    for (dk,dm),(ci,cj) in NB.items():
        if (k+dk,m+dm) in cs: continue
        mx,my=(cw(k,m)[0]+cw(k+dk,m+dm)[0])/2,(cw(k,m)[1]+cw(k+dk,m+dm)[1])/2
        A=cw(CORN[ci][0]+k,CORN[ci][1]+m); B=cw(CORN[cj][0]+k,CORN[cj][1]+m)
        sides[(0 if mx>0 else 2) if abs(mx)-hw>abs(my)-hd else (1 if my>0 else 3)].append((A,B))
def tri(a,b,up): return [P(a,b),P(a+1,b),P(a,b+1)] if up else [P(a+1,b),P(a+1,b+1),P(a,b+1)]
walls=[]
for s in range(4):
    run=sides[s]
    dx=sum(b[0]-a[0] for a,b in run); dy=sum(b[1]-a[1] for a,b in run)
    L=math.hypot(dx,dy); ux,uy=dx/L,dy/L; nx,ny=-uy,ux
    mids=[((a[0]+b[0])/2,(a[1]+b[1])/2) for a,b in run]
    cx=sum(p[0] for p in mids)/len(mids); cy=sum(p[1] for p in mids)/len(mids)
    ext=[(p[0]-cx)*ux+(p[1]-cy)*uy for p in mids]
    walls.append(dict(o=(cx,cy),d=(ux,uy),n=(nx,ny),t0=min(ext)-0.35,t1=max(ext)+0.35,tris=set()))
for w in walls:
    for a in range(-30,31):
        for b in range(-40,41):
            for up in (True,False):
                v=tri(a,b,up)
                gx=sum(p[0] for p in v)/3; gy=sum(p[1] for p in v)/3
                off=(gx-w['o'][0])*w['n'][0]+(gy-w['o'][1])*w['n'][1]
                alo=(gx-w['o'][0])*w['d'][0]+(gy-w['o'][1])*w['d'][1]
                if abs(off)<=TH/2 and w['t0']<=alo<=w['t1']: w['tris'].add((a,b,up))
# THE VERTICAL strip's own outside edges give the wall width
for i,w in enumerate(walls):
    devs=[( p[0]-w['o'][0])*w['n'][0]+(p[1]-w['o'][1])*w['n'][1]
          for T in w['tris'] for p in tri(*T)]
    w['lo'],w['hi']=min(devs),max(devs)
    w['vertical'] = abs(w['d'][0])<1e-9
Wv=[w['hi']-w['lo'] for w in walls if w['vertical']]
WIDTH=sum(Wv)/len(Wv)
print(f"vertical strip width (its own outside edges) = {WIDTH:.4f} wu = {WIDTH*0.866:.4f} m")
for w in walls:
    if w['vertical']: w['f0'],w['f1']=w['lo'],w['hi']
    else:             w['f0'],w['f1']=-WIDTH/2, WIDTH/2      # same width, own trajectory
    print(f"  {'vert' if w['vertical'] else 'horz'}  faces at {w['f0']:+.4f} / {w['f1']:+.4f}"
          f"  width {w['f1']-w['f0']:.4f} wu")
# each face as an infinite line: point + direction
def face_line(w, f):
    return ((w['o'][0]+w['n'][0]*f, w['o'][1]+w['n'][1]*f), w['d'])
def isect(p1,d1,p2,d2):
    den=d1[0]*d2[1]-d1[1]*d2[0]
    if abs(den)<1e-12: return None
    s=((p2[0]-p1[0])*d2[1]-(p2[1]-p1[1])*d2[0])/den
    return (p1[0]+s*d1[0], p1[1]+s*d1[1])
def side_of(w,f):   # is this face the OUTER one? (further from origin)
    p=(w['o'][0]+w['n'][0]*f, w['o'][1]+w['n'][1]*f)
    return math.hypot(*p)
outer=[]; inner=[]
for w in walls:
    a,b=face_line(w,w['f0']), face_line(w,w['f1'])
    (outer if side_of(w,w['f0'])>side_of(w,w['f1']) else inner).append(a)
    (outer if side_of(w,w['f1'])>side_of(w,w['f0']) else inner).append(b)
def ring(lines):
    lines=sorted(lines, key=lambda L: math.atan2(L[1][1],L[1][0]))
    pts=[]
    for i in range(len(lines)):
        p=isect(lines[i][0],lines[i][1],lines[(i+1)%len(lines)][0],lines[(i+1)%len(lines)][1])
        if p: pts.append(p)
    return pts
SC=230; W,H=int(12.2*SC),int(10.0*SC); OX,OY=W//2,H//2
img=Image.new("RGB",(W,H),(252,251,249)); dr=ImageDraw.Draw(img)
def T(p): return (OX+p[0]*SC, OY-p[1]*SC)
for w in walls:
    for Tr in w['tris']: dr.polygon([T(p) for p in tri(*Tr)], fill=(244,198,150))
for a in range(-40,41):
    for b in range(-50,51):
        p0=P(a,b)
        if abs(p0[0])>5.6 or abs(p0[1])>4.5: continue
        for dd in ((1,0),(0,1),(-1,1)):
            p1=P(a+dd[0],b+dd[1])
            if abs(p1[0])>5.6 or abs(p1[1])>4.5: continue
            dr.line([T(p0),T(p1)], fill=(206,213,222), width=2)
for (k,m) in cells:
    cx,cy=cw(k,m)
    poly=[T((cx+corner(i)[0],cy+corner(i)[1])) for i in range(6)]
    dr.line(poly+[poly[0]], fill=(28,32,40), width=4)
for name,ls,col in (("outer",outer,(200,40,30)),("inner",inner,(30,90,200))):
    R=ring(ls)
    if len(R)>=3:
        dr.line([T(p) for p in R]+[T(R[0])], fill=col, width=6)
        print(f"{name} ring: {[tuple(round(v,3) for v in p) for p in R]}")
img.save("plans/m0-roundtrip/shots/wall_faces.png"); print("wrote plans/m0-roundtrip/shots/wall_faces.png")
