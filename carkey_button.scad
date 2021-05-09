l1 = 15.7-1.0;
l2 = 16.2-1.0;
w = 8.0;
d = 5.5;
pin_dia = 4.0;

d1 = 0.4;
d2 = 0.8;
d3 = 2.6;

thick = 0.8;
toll_r = 0.35;
corner_r = 1.5;

cutout_r = 10;
cutout_h = 10;
cutout_d = d2 + 0.2;

$fa = 5;
$fs = 0.1;

points_base = [ [-.5*l1, -.5*w], [-.5*l2, .5*w], [.5*l2, .5*w], [.5*l1, -.5*w]];

function prev(i, L) = (i<=0 ? len(L)-1 : i-1);
function next(i, L) = (i>=len(L)-1 ? 0 : i+1);
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function cornercut(points, rad) =
  flatten
  ([ for (b = [0 : len(points)-1])
      let (a = prev(b, points),
           c = next(b, points),
           x = points[b][0],
           y = points[b][1],
           x1 = points[a][0],
           y1 = points[a][1],
           x2 = points[c][0],
           y2 = points[c][1],
           l1 = sqrt((x-x1)*(x-x1) + (y-y1)*(y-y1)),
           l2 = sqrt((x2-x)*(x2-x) + (y2-y)*(y2-y)),
           xm1 = x + rad/l1*(x1-x),
           ym1 = y + rad/l1*(y1-y),
           xm2 = x + rad/l2*(x2-x),
           ym2 = y + rad/l2*(y2-y)
           )
      [[xm1, ym1], [xm2, ym2]]
     ]);

module base2d_stupid() {
  deltas = [[-1,-1], [-1, 1], [1, 1], [1, -1]];
  union() {
    polygon(points=cornercut(points_base, corner_r));
    for (i = [0 : 1]) {
      for (j = [0 : 1]) {
        x = points_base[i*2+j][0];
        y = points_base[i*2+j][1];
        dx = deltas[i*2+j][0];
        dy = deltas[i*2+j][1];
        translate([x - dx*corner_r, y - dy*corner_r]) {
          circle(r=corner_r);
        }
      }
    }
  }
}

module base2d() {
  deltas = [[-1,-1], [-1, 1], [1, 1], [1, -1]];
  hull() {
    for (i = [0 : 1]) {
      for (j = [0 : 1]) {
        x = points_base[i*2+j][0];
        y = points_base[i*2+j][1];
        dx = deltas[i*2+j][0];
        dy = deltas[i*2+j][1];
        translate([x - dx*corner_r, y - dy*corner_r]) {
          circle(r=corner_r);
        }
      }
    }
  }
}

linear_extrude(height=d1) {
  base2d();
}

linear_extrude(height=d2) {
  difference() {
    base2d();
    offset(r = -thick) {
      base2d();
    }
  }
}

difference() {
  linear_extrude(height=d3, convexity=10) {
    difference() {
      offset(r = -toll_r) {
        base2d();
      }
      offset(r = -(toll_r+thick)) {
        base2d();
      }
    }
  }
  translate([0, 0, cutout_r + cutout_d]) {
    rotate([90, 0, 0]) {
      cylinder(r=cutout_r, h=cutout_h, center=true);
    }
  }
}

linear_extrude(height=d) {
  circle(r=.5*pin_dia - toll_r);
}
