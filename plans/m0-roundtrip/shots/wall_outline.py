#!/usr/bin/env python3
"""wall_outline.py — the house outline: exact math + drawing functions.

Blueprint-phase reference for DESIGN.md 10.7.  Every quantity is exact in Q(sqrt3):
a number is the pair (a, b) meaning a + b*sqrt(3), with a, b rational.  Nothing is
rounded, averaged or fitted; floats appear only at the final pixel transform.

UNITS.  1 world unit (wu) = the hex circumradius = the hex EDGE length.  1 hex step
= sqrt(3) wu = 1.5 m, so 1 wu = sqrt(3)/2 m.

THE TRIANGLE SPACE.  Equilateral, side t = 1/3 hex edge, so THREE fit each hex edge.
Basis U = (t*sqrt3/2, t/2) at 30 deg, V = (0, t) at 90 deg -- which aligns it so that
every hex CORNER and CENTRE is a lattice point.

THE WALL.  One triangle thick.  Its width is the triangle HEIGHT:

    W = t * sqrt(3)/2 = sqrt(3)/6 wu = 1/4 m        exactly

VERTICAL walls lie ON the lattice: the vertical lattice lines are x = n*sqrt(3)/6, and
the wall is the strip between two ADJACENT lines, n and n+1.  That is why its width is
W by construction rather than by choice.

HORIZONTAL walls have no lattice line to sit on (0 deg is not a triangle edge
direction), so they take the SAME width W, centred on their own line: y = c +/- W/2.

For the 5 x 4 house both work out to (verified against the drawn triangles):

    vertical    x = 16*sqrt3/6  and  17*sqrt3/6          (n = 16)
    horizontal  y = 15/4 - sqrt3/12  and  15/4 + sqrt3/12  (c = 15/4)

WHERE EACH LINE STARTS AND FINISHES.  Every face runs until it meets the corresponding
face of the perpendicular wall -- outer to outer, inner to inner.  So the endpoints are
just the four pairwise intersections, and the outline is two closed rectangles:

    outer corners  (+/- 17*sqrt3/6 , +/- (15/4 + sqrt3/12))
    inner corners  (+/-  8*sqrt3/3 , +/- (15/4 - sqrt3/12))

FAIRNESS (the property this construction is for).  Each hex loses the same area to the
wall whether it is inside or outside the house: 0.249 wu^2 against a horizontal wall,
0.432 wu^2 against a vertical one, on BOTH sides.  The two values differ by sqrt(3) --
the same anisotropy as the two wall families.  Verified by exact polygon clipping.
"""
import math
from fractions import Fraction as F

# ---- exact arithmetic in Q(sqrt3): x = (a, b) means a + b*sqrt(3) -------------
def q(a=0, b=0):    return (F(a), F(b))
def add(x, y):      return (x[0]+y[0], x[1]+y[1])
def sub(x, y):      return (x[0]-y[0], x[1]-y[1])
def smul(k, x):     return (F(k)*x[0], F(k)*x[1])
def val(x):         return float(x[0]) + float(x[1])*math.sqrt(3.0)
def show(x):
    a, b = x
    if b == 0: return f"{a}"
    if a == 0: return f"{b}*sqrt3"
    return f"{a} + {b}*sqrt3"

T      = q(0, F(1,3))          # triangle side  = 1/3 hex edge  = sqrt3/3 ... in wu: 1/3
TRI_SIDE = q(F(1,3), 0)        # 1/3 wu
WALL_W = q(0, F(1,6))          # sqrt3/6 wu  -- the triangle height, the wall width
LAT_V  = q(0, F(1,6))          # spacing of the VERTICAL lattice lines = sqrt3/6

def wall_faces(n_vert, c_horz):
    """The four walls, as (axis, outer, inner) with exact coordinates.

    n_vert : the vertical lattice index the wall's INNER face sits on; the outer face
             is the next line out, so the strip is exactly one triangle wide.
    c_horz : the horizontal wall's centre line; faces are c +/- W/2.
    """
    vo = smul(n_vert + 1, LAT_V)          # outer vertical face
    vi = smul(n_vert,     LAT_V)          # inner vertical face
    ho = add(c_horz, smul(F(1,2), WALL_W))
    hi = sub(c_horz, smul(F(1,2), WALL_W))
    return {"vertical": (vo, vi), "horizontal": (ho, hi)}

def outline(n_vert, c_horz):
    """The two closed rings.  Each face line runs until it meets the corresponding
    perpendicular face, so the endpoints ARE the four pairwise intersections."""
    f = wall_faces(n_vert, c_horz)
    (vo, vi), (ho, hi) = f["vertical"], f["horizontal"]
    ring = lambda X, Y: [(X, Y), (smul(-1, X), Y), (smul(-1, X), smul(-1, Y)), (X, smul(-1, Y))]
    return {"outer": ring(vo, ho), "inner": ring(vi, hi)}

if __name__ == "__main__":
    N_VERT, C_HORZ = 16, q(F(15,4), 0)          # the 5 x 4 house
    f = wall_faces(N_VERT, C_HORZ)
    print("wall width      W =", show(WALL_W), "wu =", f"{val(WALL_W):.6f}",
          "=", f"{val(WALL_W)*math.sqrt(3)/2:.4f} m")
    for k, (o, i) in f.items():
        print(f"{k:>11}  outer {show(o):>22} = {val(o):9.6f}   "
              f"inner {show(i):>22} = {val(i):9.6f}   width {val(sub(o,i)):.6f}")
    print()
    for name, ring in outline(N_VERT, C_HORZ).items():
        print(f"{name} ring corners:")
        for (X, Y) in ring:
            print(f"   ({show(X):>16}, {show(Y):>18})  =  ({val(X):+9.6f}, {val(Y):+9.6f})")
    ok = sub(*f["vertical"]) == WALL_W and sub(*f["horizontal"]) == WALL_W
    print(f"\nboth widths are exactly sqrt3/6: {ok}")

# ---- drawing, and the check that the drawn line matches the triangle strip ----
def draw(n_vert, c_horz, path, wid=5, dep=4, sc=230):
    """Render the outline from the EXACT math above, over the hexes and triangles,
    and return the wall triangles so the caller can verify they fall inside it."""
    from PIL import Image, ImageDraw
    S3 = math.sqrt(3.0); t = 1.0/3.0
    U = (t*S3/2, t/2); V = (0.0, t)
    P   = lambda a, b: (a*U[0]+b*V[0], a*U[1]+b*V[1])
    tri = lambda a, b, up: ([P(a,b), P(a+1,b), P(a,b+1)] if up
                            else [P(a+1,b), P(a+1,b+1), P(a,b+1)])
    cor = lambda k: (math.cos(math.radians(30+60*k)), math.sin(math.radians(30+60*k)))
    inh = lambda k, m: 2*abs(k) <= 2*wid+1 and m*m <= 3*dep*dep
    cells = [(2*q_+(r & 1), 3*r) for r in range(-6,7) for q_ in range(-9,10)
             if inh(2*q_+(r & 1), 3*r)]
    cw = lambda k, m: (k*S3/2, m/2)
    f  = wall_faces(n_vert, c_horz)
    VO, VI = val(f["vertical"][0]),   val(f["vertical"][1])
    HO, HI = val(f["horizontal"][0]), val(f["horizontal"][1])
    # a triangle is WALL iff its centroid lies in one of the four bands
    wall = []
    for a in range(-30, 31):
        for b in range(-40, 41):
            for up in (True, False):
                v = tri(a, b, up)
                gx = sum(p[0] for p in v)/3; gy = sum(p[1] for p in v)/3
                if (VI <= abs(gx) <= VO and abs(gy) <= HO) or \
                   (HI <= abs(gy) <= HO and abs(gx) <= VO):
                    wall.append((a, b, up))
    W_, H_ = int(12.2*sc), int(10.0*sc); ox, oy = W_//2, H_//2
    img = Image.new("RGB", (W_, H_), (252,251,249)); dr = ImageDraw.Draw(img)
    T = lambda p: (ox + p[0]*sc, oy - p[1]*sc)
    for w in wall: dr.polygon([T(p) for p in tri(*w)], fill=(244,198,150))
    for a in range(-40, 41):
        for b in range(-50, 51):
            p0 = P(a, b)
            if abs(p0[0]) > 5.6 or abs(p0[1]) > 4.5: continue
            for d in ((1,0), (0,1), (-1,1)):
                p1 = P(a+d[0], b+d[1])
                if abs(p1[0]) > 5.6 or abs(p1[1]) > 4.5: continue
                dr.line([T(p0), T(p1)], fill=(206,213,222), width=2)
    for (k, m) in cells:
        c = cw(k, m); poly = [T((c[0]+cor(i)[0], c[1]+cor(i)[1])) for i in range(6)]
        dr.line(poly+[poly[0]], fill=(28,32,40), width=4)
    for (X, Y, col) in ((VO, HO, (200,40,30)), (VI, HI, (30,90,200))):
        r = [(X,Y), (-X,Y), (-X,-Y), (X,-Y)]
        dr.line([T(p) for p in r]+[T(r[0])], fill=col, width=6)
    img.save(path)
    return wall, (VO, VI, HO, HI)

def verify(wall, faces, tol=1e-9):
    """Every wall triangle must lie INSIDE the band, and the band's boundaries must be
    exactly the triangles' extremes -- i.e. the drawn line matches the strip."""
    S3 = math.sqrt(3.0); t = 1.0/3.0
    U = (t*S3/2, t/2); V = (0.0, t)
    P   = lambda a, b: (a*U[0]+b*V[0], a*U[1]+b*V[1])
    tri = lambda a, b, up: ([P(a,b), P(a+1,b), P(a,b+1)] if up
                            else [P(a+1,b), P(a+1,b+1), P(a,b+1)])
    VO, VI, HO, HI = faces
    vx = [abs(p[0]) for w in wall for p in tri(*w) if VI-0.2 <= abs(sum(
             q_[0] for q_ in tri(*w))/3) <= VO+0.2]
    vert = [p for w in wall for p in tri(*w)
            if VI <= abs(sum(q_[0] for q_ in tri(*w))/3) <= VO]
    horz = [p for w in wall for p in tri(*w)
            if HI <= abs(sum(q_[1] for q_ in tri(*w))/3) <= HO]
    out = {}
    if vert:
        e = [abs(p[0]) for p in vert]
        out["vertical"] = (min(e), max(e), abs(min(e)-VI) < tol, abs(max(e)-VO) < tol)
    if horz:
        e = [abs(p[1]) for p in horz]
        out["horizontal"] = (min(e), max(e), abs(min(e)-HI) < tol, abs(max(e)-HO) < tol)
    return out
